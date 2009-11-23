MYHOME = /home/user/
MPIINC = -I$(MYHOME)openmpi-1.3.3/include
MPILIBS = -lpthread -L$(MYHOME)openmpi-1.3.3/lib -lmpi_cxx -lmpi -lopen-rte -lopen-pal -ldl -lnsl -lutil -lm -ldl

all: MPI_Init.oct \
     MPI_Initialized.oct \
     MPI_COMM_WORLD.oct \
     MPI_Comm_rank.oct \
     MPI_Comm_size.oct \
     MPI_Finalize.oct \
     MPI_Finalized.oct \
     MPI_Send.oct \
     MPI_Recv.oct \
     MPI_Iprobe.oct \
     MPI_Probe.oct \

# Needs a better treatment
comm-util.o:
	mkoctfile -c $(MPIINC) comm-util.cc

%.oct: %.cc comm-util.o
	mkoctfile -s $(MPIINC)  $(MPILIBS) $< comm-util.o

clean:
	-rm *.o  *.oct *~
