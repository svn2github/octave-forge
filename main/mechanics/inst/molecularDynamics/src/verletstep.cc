#include <octave/oct.h>
#include <octave/parse.h>

DEFUN_DLD (verletstep, args, nargout, "Verlet velocity step")
     {
       int nargin = args.length();
       octave_value_list retval;

       unsigned int fcn_str = 0;
       
       if (nargin < 5)
         print_usage ();
       else
         {
            // Allocate inputs
            octave_function *fcn;
            if (args(4).is_function_handle () || args(4).is_inline_function ())
              fcn_str = 0;
            else if (args(4).is_string ())
              fcn_str = 1; 
            else
              error ("verletstep: expected string,"," inline or function handle");

            Matrix P = args(0).array_value ();
            Matrix V = args(1).array_value ();
            Matrix M = args(2).array_value ();
            double dt = args(3).scalar_value ();
            
            dim_vector dv = P.dims();
            octave_idx_type Nparticles = dv(0);
            octave_idx_type Ndim = dv(1);

            octave_value_list newargs;
            Matrix A (dim_vector(Nparticles, Ndim),0);

            // Evaluate interaction function
            for (octave_idx_type ipart = 0; ipart < Nparticles; ipart++)
            {
              newargs(0) = P.row(ipart);
              newargs(2) = V.row(ipart);

              for (octave_idx_type jpart = ipart + 1; jpart < Nparticles; jpart++)
              {
                newargs(1) = P.row(jpart);
                newargs(3) = V.row(jpart);

                if (fcn_str)
                  retval = feval (args (4).string_value (), newargs, nargout);
                else
                {
                  fcn = args(4).function_value ();
                  if (! error_state)
                    retval = feval (fcn, newargs, nargout);
                }

                A.insert (retval(0).row_vector_value () + 
                                      A.row (ipart), ipart, 0);
                A.insert (retval(1).row_vector_value () + 
                                      A.row (jpart), jpart, 0);
                
              }
            }

            for (octave_idx_type i = 0; i < A.rows (); i++) 
              A.insert (A.row (i) / M(i), i, 0);

            // Integrate by half time step velocity and full step position
            V = V + A * dt/2;
            P = P + V * dt;

            A.fill(0);

            // Evaluate interaction function
            for (octave_idx_type ipart = 0; ipart < Nparticles; ipart++)
            {
              newargs(0) = P.row(ipart);
              newargs(2) = V.row(ipart);

              for (octave_idx_type jpart = ipart + 1; jpart < Nparticles; jpart++)
              {
                newargs(1) = P.row(jpart);
                newargs(3) = V.row(jpart);

                if (fcn_str)
                  retval = feval (args (4).string_value (), newargs, nargout);
                else
                {
                  fcn = args(4).function_value ();
                  if (! error_state)
                    retval = feval (fcn, newargs, nargout);
                }

                A.insert (retval(0).row_vector_value () + 
                                                       A.row (ipart), ipart, 0);
                A.insert (retval(1).row_vector_value () + 
                                                       A.row (jpart), jpart, 0);
                
              }
            }
            for (octave_idx_type i = 0; i < A.rows (); i++) 
              A.insert (A.row (i) / M(i), i, 0);

            // Integrate velocity for the rest of the time step
            V = V + A * dt/2;

           retval(0) = P;
           retval(1) = V;
           retval(2) = A;
       }
       
       return retval;
     }

