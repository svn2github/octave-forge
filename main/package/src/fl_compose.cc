/*       Copyright(C) 2011 Gianvito Pio, Piero Molino
*        Contact Email: pio.gianvito@gmail.com piero.molino@gmail.com
*        
* 	 fl-core - Fuzzy Logic Core functions for Octave
*        This file is part of fl-core.
*        
*        fl-core is free software: you can redistribute it and/or modify
*        it under the terms of the GNU Lesser General Public License as published by
*        the Free Software Foundation, either version 3 of the License, or
*        (at your option) any later version.
*        
*        fl-core is distributed in the hope that it will be useful,
*        but WITHOUT ANY WARRANTY; without even the implied warranty of
*        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*        GNU Lesser General Public License for more details.
*        
*        You should have received a copy of the GNU Lesser General Public License
*        along with fl-core.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <octave/oct.h>
#include <octave/parse.h>
#include <pthread.h>    

#define HELP \
"-*- texinfo -*-\n\
 @deftypefn{Loadable Function} {@var{res} = } fl_compose(@var{A}, @var{B}) \n\
 @deftypefnx{Loadable Function} {@var{res} = } fl_compose(@var{A}, @var{B}, @var{LOCK})\n\
 @deftypefnx{Loadable Function} {@var{res} = } fl_compose(@var{A}, @var{B}, @var{T})\n\
 @deftypefnx{Loadable Function} {@var{res} = } fl_compose(@var{A}, @var{B}, @var{T}, @var{S})\n\
 @deftypefnx{Loadable Function} {@var{res} = } fl_compose(@var{A}, @var{B}, @var{LOCK}, @var{T})\n\
 Returns the T-Norm / S-Norm composition as basic inference mechanism of Fuzzy Logic. By default, it calculates the max-min  composition.\n\n\
@var{A} and @var{B} must be matrices with conformant dimensions as in matrix product. If they are both full matrices or mixed (one full and one sparse), a full matrix will be returned. If they are both sparse matrices, a sparse matrix will be returned. However the best computation method (sparse or full) is optimally chosen at runtime.\n\n\
When true, the boolean @var{LOCK} option forces to calculate the diagonal results only and returns it as a column vector.\n\n\
The arguments @var{T} and @var{S} allows to specify a custom T-Norm and S-Norm function respectively. They can be:\n\n\
@itemize @minus \n\
@item 'min': use the minimum function (default for T-Norm);\n\n\
@item 'prod': use the product function;\n\n\
@item 'max': use the maximum function (default for S-Norm);\n\n\
@item 'sum': use the probabilistic sum function;\n\n\
@item function_handle: a user-defined function (at most 2 arguments).\n\n\
@end itemize\n\
Note that only the predefined functions are calculated rapidly and in multithread mode. Using a user-defined function as T-Norm and/or S-Norm will result in a long time calculation.\n\n\
Furthermore, no check is performed to be sure the provided functions have the T-Norm or S-Norm properties. The results will be correct as expected, but the semantic correctness is only a user responsibility.\n\
 @end deftypefn"



#define MIN_ARG 2
#define MAX_ARG 4

#define STR_MINNORM "min"
#define STR_PRONORM "prod"
#define STR_MAXNORM "max"
#define STR_SUMNORM "sum"

#define ERR_INVALIDFUNC "fl_compose: the specified T-Norm or S-Norm function is invalid!\nPlease read help for details"
#define ERR_MATRIXSIZE "fl_compose: incompatible matrices dimensions\n"
#define ERR_MATRIXTYPE "fl_compose: the first two argument must be matrices\n"



// Structure for thread arguments. Each thread will perform the computation between the start_index and end_index row.
struct threadArg
{
	int start_index;
	int end_index;
};


// Functions prototype declaration
float get_elem(float vec[], int row, int col,int numCols);
void set_elem(float vec[], int row, int col, int numCols, float elem);
int is_valid_function(octave_function *func);
void *thread_function(void *arg);
int get_available_cpus();
int assign_default_func(octave_value arg, int tnorm);
int optimal_sparse(octave_value mat_a,octave_value mat_b);

void (*compose)(octave_value_list);
void full_compose(octave_value_list args);
void sparse_compose(octave_value_list args);

float (*calc_tnorm)(float,float);
float (*calc_snorm)(float,float);

float func_min(float first, float second);
float func_prod(float first, float second);
float func_max(float first, float second);
float func_sum(float first, float second);

float func_custom_tnorm(float first, float second);
float func_custom_snorm(float first, float second);


// T-Norm and S-Norm function pointers
octave_function *tnorm;
octave_function *snorm;


// Structure for the thread arguments
struct threadArg* thread_args = NULL;

// Input and output matrices
float* a;
float* b;
float* c;

// Sparse matrix output (for sparse composition)
SparseMatrix sparseC;

// Matrices dimensions
long int rowsA,rowsB,colsA,colsB,rowsC,colsC;

// Lock option. 1 = calculation executed only for the diagonal of the matrix
int lock_option;

// The increment 
int col_index_increment;

// Number of threads that will be created
int num_threads;


// 0 = the input matrices are both full. A full output matrix will be produced.
// 1 = the input matrices are both sparse. A sparse output matrix will be produced.
int sparse_res;


// 0 = A full composition is performed. 1 = a sparse composition is performed
int sparse_composition;


// Indicate that a standard T-Norm (prod or min) and a S-Norm was specified (probabilistic sum or max)
int standard_norm;



/* Main function - Check the arguments and call the compose method */
DEFUN_DLD (fl_compose, args, nargout, HELP)
{
	int numargs = args.length();		// Arguments number
	int specified_lockoption = 0;		// 1 = the lock_option was specified in the arguments

	// Set the default values
	lock_option = 0;
	sparse_res = 0;
	sparse_composition = 0;
	standard_norm = 1;

	// Set the num_thread to the actual available CPU cores
	num_threads = get_available_cpus();

	// Set the lock_option to default value (0)
	lock_option = 0;

	// Set the computation to default (full matrices)
	compose = full_compose;

	// Set the T-Norm and S-Norm function pointer to default value (Minimum and Maximum)
	calc_tnorm = func_min;
	calc_snorm = func_max;


	// Check if the argument number is correct
	if(numargs < MIN_ARG || numargs > MAX_ARG)
	{
		print_usage();
		return octave_value_list();	
	}


	// Check if the first two arguments are matrices	
	if(!args(0).is_matrix_type() || !args(1).is_matrix_type())
	{
		error(ERR_MATRIXTYPE);
		return octave_value_list();
	}

	
	// Check if the matrices are both both sparse and set the output matrix to sparse type
	if(args(0).is_sparse_type() && args(1).is_sparse_type())		
		sparse_res = 1;


	// Analyze the third argument (can be the lock_option, a custom T-Norm or a default string for T-Norm)	
	if(numargs > 2)
	{
		// Check if the third argument is the lock_option.
		if(args(2).is_bool_scalar())			
		{
			// Get the lock_option value
			lock_option = args(2).int_value();		
			specified_lockoption = 1;
		}


		// Check if the third argument is a function
		else if(args(2).is_function_handle())		
		{
			// Check if the custom T-Norm function has at most two arguments			
			if(!is_valid_function(args(2).function_value()))	
			{		
				error(ERR_INVALIDFUNC);
				return octave_value_list();
			}
			else
			{
				// Set the custom T-Norm and force single thread mode					
				tnorm = args(2).function_value();
				calc_tnorm = func_custom_tnorm;
				num_threads = 1;	
				standard_norm = 0;	
			}	
		}

		// Check if the third argument is a string and try to assign a default T-Norm
		else if(!((args(2).is_sq_string() || args(2).is_dq_string()) && assign_default_func(args(2),1)))
		{	
			error(ERR_INVALIDFUNC);	
			return octave_value_list();
		}
	}





	// Analyze the fourth argument (can be a custom T-Norm, a default string for T-Norm or a custom S-Norm)	
	if(numargs > 3)
	{
		// Check if the fourth argument is a function
		if(args(3).is_function_handle())		
		{
			if(specified_lockoption)
			{
				// Check if the custom T-Norm function has at most two arguments			
				if(!is_valid_function(args(3).function_value()))	
				{		
					error(ERR_INVALIDFUNC);
					return octave_value_list();
				}
				else
				{
					// Set the custom T-Norm and force single thread mode					
					tnorm = args(3).function_value();
					calc_tnorm = func_custom_tnorm;
					num_threads = 1;		
				}
			}
			else
			{
				// Check if the custom S-Norm function has at most two arguments			
				if(!is_valid_function(args(3).function_value()))	
				{		
					error(ERR_INVALIDFUNC);
					return octave_value_list();
				}
				else
				{
					// Set the custom S-Norm and force single thread mode	
					snorm = args(3).function_value();
					calc_snorm = func_custom_snorm;
					num_threads = 1;
				}
			}
			standard_norm = 0;
		}
		
		// Check if the fourth argument is a string (could be a default T-Norm)
		else if (args(3).is_sq_string() || args(3).is_dq_string())
		{						
			if(specified_lockoption)
			{
				if (!assign_default_func(args(3),1))
				{
					error(ERR_INVALIDFUNC);	
					return octave_value_list();
				}
			}
			else
			{
				if (!assign_default_func(args(3),0))
				{
					error(ERR_INVALIDFUNC);	
					return octave_value_list();
				}
			}
		}
		else
		{
			error(ERR_INVALIDFUNC);	
			return octave_value_list();
		}			
	}
	
	



	// Get the dimensions of matrices	
	rowsA = args(0).matrix_value().dims()(0);
	colsA = args(0).matrix_value().dims()(1);
	rowsB = args(1).matrix_value().dims()(0);
	colsB = args(1).matrix_value().dims()(1);	
	rowsC = rowsA;
	colsC = colsB;

	// Check if the dimensions are compatible
	if(colsA != rowsB)	
	{
		error(ERR_MATRIXSIZE);
		return octave_value_list();
	}


	// If the matrices are really sparse, the S-Norm is a standard type, the lock_option is false and the matrices aren't vectors perform the sparse composition
	// (Workaround for segmentation fault caused by sparse vector transposition)
	if(standard_norm && !lock_option && rowsA != 1 && colsA != 1 && colsB != 1 && optimal_sparse(args(0),args(1)))
	{
 		compose = sparse_compose;
		sparse_composition = 1;
	}

	

		

	// If the lock_option is true, the function will return a column vector.
	// Sets proper output matrix dimensions and column index increment.
	if(lock_option)
	{
		// A column index increment = colsB let the two FOR cycle to calculate only the first element 
		col_index_increment = colsB;
		c = new float[rowsC];
		colsC = 1;
	}
	else
	{
		col_index_increment = 1;
		c = new float[rowsC*colsC];
	}			
		

	// Start the matrix composition
	compose(args);


	// Compose the output result as an octave matrix (sparse or full, same as input matrices)
	if(sparse_composition)
	{			
		if(sparse_res)		
			return octave_value(sparseC);		
		else			
			return octave_value(sparseC.matrix_value());
	}
	else
	{	
		Matrix outMatrix(rowsC,colsC);
		for(int i=0;i<rowsC;i++)
			for(int j=0;j<colsC;j++)
				outMatrix(i,j) = get_elem(c,i,j,colsC);
		
		if(sparse_res)
		{		
			SparseMatrix spMatrix = SparseMatrix(outMatrix);					
			return octave_value(spMatrix);
		}
		else					
			return octave_value(outMatrix);	
	}
	
	
	
}










// Calculate the S-Norm/T-Norm composition of full matrices (multi thread)
void full_compose(octave_value_list args)
{
	
	// Initialize the first matrix
	Matrix tempMatrix = args(0).matrix_value();
	a = new float[rowsA*colsA];
	for (int i=0; i<rowsA; i++)
		for(int j=0; j<colsA;j++)
			a[i*colsA+j] = tempMatrix(i,j);

	// Initialize the second matrix
	tempMatrix = args(1).matrix_value();
	b = new float[rowsB*colsB];
	for (int i=0; i<rowsB; i++)
		for(int j=0; j<colsB;j++)
			b[i*colsB+j] = tempMatrix(i,j);
	

	// Create the thread args array
	thread_args = new threadArg[num_threads];
		

	// Define an array of threads
	pthread_t th[num_threads];

	// If the lock_option is true, the result will be a column vector of the dimension of the diagonal 
	// (the minimum between the rows of the matrix A and the columns of the matrix B)
	if(lock_option)
	{
		rowsA = func_min(rowsA,colsB);
		rowsC = rowsA;
	}

	// Define the number interval of rows for each thread		
	int interval = rowsA / num_threads;	
			
	int i;
	// Define the threads
	for (i=0; i<num_threads; i++)
	{	
		// Set the proper row start_index and end_index in the thread argument
		thread_args[i].start_index = i*interval;
		thread_args[i].end_index = thread_args[i].start_index + interval;	

		if(i == num_threads - 1)		
			thread_args[i].end_index = rowsA;
			
		// Start the thread			
		pthread_create(&th[i],NULL,thread_function, (void *) &thread_args[i]);
	}

	void *ans1;	
	
	// Wait the results from each thread
	for(i=0; i<num_threads; i++)
		pthread_join(th[i],&ans1);
}









// Calculate the S-Norm/T-Norm composition of sparse matrices (single thread)
void sparse_compose(octave_value_list args)
{
	// Create constant versions of the input matrices to prevent them to be filled by zeros on reading.
	// a is the const reference to the transpose of a because octave sparse matrices are column compressed
	// (to cycle on the rows, we cycle on the columns of the transpose).
	SparseMatrix atmp = args(0).sparse_matrix_value();
	const SparseMatrix a = atmp.transpose();
	const SparseMatrix b = args(1).sparse_matrix_value();

	// Declare variables for the T-Norm and S-Norm values 
	float snorm_val;	
	float tnorm_val;	

	// Initialize the result sparse matrix
	sparseC = SparseMatrix((int)colsB, (int)rowsA, (int)(colsB*rowsA));

        // Initialize the number of nonzero elements in the sparse matrix c
        int nel = 0;
        sparseC.xcidx(0) = 0;

	// Calculate the composition for each element
        for (int i = 0; i < rowsC; i++)
        {
            for(int j = 0; j < colsC; j++)
            {
                
		// Get the index of the first element of the i-th column of a transpose (i-th row of a)
		// and the index of the first element of the j-th column of b
		int ka = a.cidx(i);
		int kb = b.cidx(j);
		snorm_val = 0;
	
		// Check if the values of the matrix are really not 0 (it happens if the column of a or b hasn't any value)
		// because otherwise the cidx(i) or cidx(j) returns the first nonzero element of the previous column
		if(a(a.ridx(ka),i)!=0 && b(b.ridx(kb),j)!=0)
		{
			// Cicle on the i-th column of a transpose (i-th row of a) and j-th column of b
			// From a.cidx(i) to a.cidx(i+1)-1 there are all the nonzero elements of the column i of a transpose (i-th row of a)
			// From b.cidx(j) to b.cidx(j+1)-1 there are all the nonzero elements of the column j of b
			while ((ka <= (a.cidx(i+1)-1)) && (kb <= (b.cidx(j+1)-1)))
			{
								
				// If a.ridx(ka) == b.ridx(kb) is true, then there's a nonzero value on the same row
				// so there's a k for that a'(k, i) (equals to a(i, k)) and b(k, j) are both nonzero
				if (a.ridx(ka) == b.ridx(kb))
				{
					tnorm_val = calc_tnorm(a.data(ka), b.data(kb));	
					snorm_val = calc_snorm(snorm_val, tnorm_val);
					ka++;
					kb++;
				}

				// If a.ridx(ka) == b.ridx(kb) ka should become the index of the next nonzero element on the i column of a 
				// transpose (i row of a)
				else if (a.ridx(ka) < b.ridx(kb))			
					ka++;
				// If a.ridx(ka) > b.ridx(kb) kb should become the index of the next nonzero element on the j column of b
				else
					kb++;
			}
		}

                if (snorm_val != 0)
                {
                    // Equivalent to sparseC(i, j) = snorm_val;
                    sparseC.xridx(nel) = j;
                    sparseC.xdata(nel++) = snorm_val;
                }
            }
            sparseC.xcidx(i+1) = nel;
        }
	
	// Compress the result sparse matrix because it is initialized with a number of nonzero element probably greater than the real one
	sparseC.maybe_compress();
	
	// Transpose the result
	sparseC = sparseC.transpose();
}








/* Function executed by each thread */
void *thread_function(void *arg)
{
	// Get the structure from the thread arguments
	struct threadArg *thread_args;
	thread_args = (struct threadArg *) arg;

	// Declare variables for the T-Norm and S-Norm values 
	float snorm_val;	
	float tnorm_val;	
	
	// Get the row start_index and end_index 
	int start_index = thread_args->start_index;
	int end_index = thread_args->end_index;
	

	// Calculate the composition for the specified rows (between start_index and end_index)
	for (int i=start_index; i<end_index; i++)
	{		
		for(int j=lock_option*i; j<colsB; j=j+col_index_increment)
		{
			snorm_val = calc_tnorm(get_elem(a,i,0,colsA),get_elem(b,0,j,colsB));

			for(int k=1; k<colsA; k++)
			{					
				tnorm_val = calc_tnorm(get_elem(a,i,k,colsA),get_elem(b,k,j,colsB)); 
				snorm_val = calc_snorm(snorm_val,tnorm_val);
			}	
			set_elem(c,i,j*(1-lock_option),colsC,snorm_val);
		}
	}
	return((void *)0);
}








// Check if the application of the sparse algorithm is optimal
int optimal_sparse(octave_value mat_a,octave_value mat_b)
{
	// Parameters for execution time of each algorithm (may be changed if the algorithms change)	
	const float sparse_norm_cost = 0.0000115;
	const float sparse_skip_cost = 0.000015;
	const float full_norm_cost = 0.000017;

	// Get the non-zero elements number of each matrix
	SparseMatrix tempMatrix = mat_a.sparse_matrix_value();
	long int nnzA = tempMatrix.nnz();
	tempMatrix = mat_b.sparse_matrix_value();	
	long int nnzB = tempMatrix.nnz();

	// Calculate the time for full calculation
	long int full_time = full_norm_cost*rowsC*colsC*colsA/num_threads;

	// Calculate the approximate number of calculated T-Norm/S-Norm in the sparse algorithm
	long int estimated_norm_number = nnzA*(nnzB/rowsB);

	// Calculate the approximate number of skip operations in the sparse algorithm
	long int estimated_skip_number = nnzA*colsB + nnzB*rowsA - 2*estimated_norm_number;

	// Calculate the time for full calculation
	long int sparse_time = sparse_norm_cost*estimated_norm_number + sparse_skip_cost * estimated_skip_number;

	if(sparse_time < full_time)
		return 1;
	else
		return 0;
}





/* Returns 1 if an octave_function FUNC has at most 2 arguments. */
int is_valid_function(octave_function *func)
{
	octave_value_list testArgs;
	testArgs(0) = 1;
	testArgs(1) = 2;
	feval(func,testArgs);
	if(error_state)
		return 0;
	else
		return 1;
}



/* Assign a default function or T-Norm or S-Norm. 
If tnorm = 0 the function will be assigned as S-Norm, else the function will be assigned as T-Norm.
Returns 0 if it fails*/
int assign_default_func(octave_value arg, int tnorm)
{
	int res = 1;	
	if(arg.string_value() == STR_PRONORM)
		if(tnorm)
			calc_tnorm = func_prod;
		else
		{
			calc_snorm = func_prod;
			standard_norm = 0;
		}
		
	else if (arg.string_value() == STR_MAXNORM)
		if(tnorm)
		{
			calc_tnorm = func_max;
			standard_norm = 0;
		}
		else
			calc_snorm = func_max;
	else if (arg.string_value() == STR_SUMNORM)
		if(tnorm)
		{
			calc_tnorm = func_sum;
			standard_norm = 0;
		}
		else
			calc_snorm = func_sum;
	else if(arg.string_value() == STR_MINNORM)
	{
		if(!tnorm)
			standard_norm = 0;
	}
	else
		res = 0;
	return res;
}

	








/* Calculate the minimum between the two values */
float func_min(float first, float second)
{	
	if(first < second)
		return first;
	else
		return second;
}



/* Calculate the product between the two values */
float func_prod(float first, float second)
{	
	return first*second;
}



/* Calculate the Maximum between the two values */
float func_max(float first, float second)
{	
	if(first > second)
		return first;
	else
		return second;
}



/* Calculate the probabilistic sum between the two values */
float func_sum(float first, float second)
{	
	return first+second-(first*second);
}



/* Calculate a custom T-Norm between the two values */
float func_custom_tnorm(float first, float second)
{	
	octave_value_list fargs;			
	fargs(0) = octave_value(first);
	fargs(1) = octave_value(second);
	return feval(tnorm,fargs)(0).float_value();
}



/* Calculate a custom S-Norm between the two values */
float func_custom_snorm(float first, float second)
{	
	octave_value_list fargs;			
	fargs(0) = octave_value(first);
	fargs(1) = octave_value(second);
	return feval(snorm,fargs)(0).float_value();
}










/* Get the current cpu cores number */
int get_available_cpus()
{
	#ifdef WIN32	
		SYSTEM_INFO sysinfo;
		GetSystemInfo( &sysinfo );
		return sysinfo.dwNumberOfProcessors;
	#else
		return sysconf( _SC_NPROCESSORS_ONLN);
	#endif
}









/* Get the (i,j)-th element from the vector vec. The column number of the original matrix (numCols) is required */
float get_elem(float vec[], int row, int col,int numCols)
{
	return vec[row*numCols+col];
}



/* Set the (i,j)-th element from the vector vec. The column number of the original matrix (numCols) is required */
void set_elem(float vec[], int row, int col, int numCols, float elem)
{
	vec[row*numCols+col] = elem;
	return;
}
