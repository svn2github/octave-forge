/*
  Copyright (C) 2011 Carlo de Falco
  This software is distributed under the terms 
  the terms of the GNU/GPL licence v3
*/

#include <sparse.h>
#include <mumps_class.h>
#include <mpi.h>
  
int main (void)
{

  MPI::Init ();
  int rank = MPI::COMM_WORLD.Get_rank ();
  int size = MPI::COMM_WORLD.Get_size ();

  if (!(size > 1))
    {
      std::cout << "*****\ntest 1\n*****\n";
 
      sparse_matrix     sp; 
      p_sparse_matrix   spp; 

      std::vector<int>   i,j;
      std::vector<double>  a;

      std::vector<int>   rows,cols;

      rows.resize (2);
      rows[0] = 1; rows[1] = 2;

      cols.resize (3);
      cols[0] = 0; cols[1] = 1; cols[2] = 6;

      sp.resize (4);
  
      /*          col 0           col 1           col 2           col 3           col 4           col 5           col 6 */
      /* row 1 */ sp[1][0] = 1.0;                 sp[1][2] = 1.1; sp[1][3] = 1.3; sp[1][4] = 1.4;
      /* row 2 */ sp[2][0] = 2.0;                                                                                 sp[2][6] = 2.6;
      /* row 3 */                                                                                 sp[3][5] = 3.5;

      sp.extract_block_pointer (rows, cols, spp);

      std::cout << std::endl << "aij" << std::endl;
      spp.aij (a, i, j);
      for (int k = 0; k < spp.nnz; ++k)
        std::cout << i[k] << " "
                  << j[k] << " "
                  << a[k] << std::endl;

      std::cout << std::endl << "sparse" << std::endl;
      std::cout << spp;

      std::cout << "\n\n*****\ntest 2\n*****\n";

      sparse_matrix       lhs;
      std::vector<double> lrhs;
      std::vector<int>    ir, jc;
      std::vector<double> xa;
      std::vector<int>    rows2, cols2;
      p_sparse_matrix     llhs;

      lhs.resize (10);
      for (int k = 0; k < 10; ++k)
        lhs[k][k] = 2.0;

      for (int k = 0; k < 9; ++k)
        {
          lhs[k][k+1] = -1.0;
          lhs[k+1][k] = -1.0;
        }

      lrhs.resize (8);
      lrhs.assign (lrhs.size (), 1.0);

      rows2.resize (8); 
      cols2.resize (8);

      for (int k = 0; k < 8; ++k)
        {rows2[k] = k+1; cols2[k] = k+1;}

      lhs.extract_block_pointer (rows2, cols2, llhs);
      llhs.aij (xa, ir, jc, 1);

      mumps mumps_solver;
  
      mumps_solver.set_lhs_structure (llhs.rows (), ir, jc);
      mumps_solver.analyze ();

      // first solve
      mumps_solver.set_lhs_data (xa);
      mumps_solver.factorize ();

      mumps_solver.set_rhs (lrhs);
      mumps_solver.solve ();

      std::cout << std::endl;
      for (int k = 0; k < lrhs.size (); ++k)
        std::cout << lrhs[k] << std::endl;

      // second solve
      for (int k = 0; k < 10; ++k)
        lhs[k][k] = 4.0;

      llhs.aij_update (xa, ir, jc, 1);

      mumps_solver.set_lhs_data (xa);
      mumps_solver.factorize ();

      lrhs.assign (lrhs.size (), 1.0);

      mumps_solver.set_rhs (lrhs);
      mumps_solver.solve ();
  
      std::cout << std::endl;
      for (int k = 0; k < lrhs.size (); ++k)
        std::cout << lrhs[k] << std::endl;
      std::cout << std::endl;

      mumps_solver.cleanup ();
    }
  else if (!rank)
    std::cout << "this example can run on 1 CPU" << std::endl;

  MPI::Finalize();
  return (0);
}
