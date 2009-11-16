MYHOME = /home/user/
MPIINC = -I$(MYHOME)openmpi-1.3.3/include
MPILIBS = -lpthread -L$(MYHOME)openmpi-1.3.3/lib -lmpi_cxx -lmpi -lopen-rte -lopen-pal -ldl -lnsl -lutil -lm -ldl

all: MPI_Init.oct \
     MPI_Initialized.oct \
     MPI_Comm_rank.oct \
     MPI_Comm_size.oct \
     MPI_Finalize.oct \
     MPI_Finalized.oct \
     MPI_Send.oct \
     MPI_Recv.oct \
     
%.oct: %.cc
	mkoctfile -s $(MPIINC)  $(MPILIBS)   $<

clean:
	-rm *.o  *.oct *~
