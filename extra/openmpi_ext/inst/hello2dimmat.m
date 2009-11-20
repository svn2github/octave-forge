if not(MPI_Initialized)
   MPI_Init();
end

  my_rank = MPI_Comm_rank();
  p = MPI_Comm_size();
  mytag = 48;


 
  if (my_rank != 0)
#        Generate a random matrix
       message=rand(90,90);
#        load message
#       rankvect is the vector containing the list of rank  destination process
     rankvect = 0;
     [info] = MPI_Send(message,rankvect,mytag);
  else
        for source = 1:p-1
          disp("We are at rank 0 that is master etc..");
          [messager, info] = MPI_Recv(source,mytag);
#	You could also save each result and make comparisons if you don't trust MPI
          disp("Rank 0 is the master receiving ... :");
            if (info == true)
              disp('OK!');
          endif
          endfor
  end   


  if not(MPI_Finalized)
   MPI_Finalize();
  end
