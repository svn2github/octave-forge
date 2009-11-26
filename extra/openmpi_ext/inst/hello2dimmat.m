# Please add the oct files openmpi_ext folder 
# For instance 
h = genpath("/home/corradin/working_directory/octave-forge/extra/openmpi_ext/");
addpath(h);
clear h;
  MPI_SUCCESS =0;
  MPI_Init();

  CW = octave_comm_make("MPI_COMM_WORLD");
  my_rank = MPI_Comm_rank(CW);
  p = MPI_Comm_size(CW);
  mytag = 48;


 
  if (my_rank != 0)
#        Generate a random matrix
       message=rand(90,90);
#        load message
#       rankvect is the vector containing the list of rank  destination process
     rankvect = 0;
     [info] = MPI_Send(message,rankvect,mytag,CW);
  else
        for source = 1:p-1
          disp("We are at rank 0 that is master etc..");
          [messager, info] = MPI_Recv(source,mytag,CW);
          
#	You could also save each result and make comparisons if you don't trust MPI
          disp("Rank 0 is the master receiving ... :");
            if (info == MPI_SUCCESS)
              disp('OK!');
          endif
          endfor
  end   


   MPI_Finalize();
