OCTS = sclose.oct  connect.oct pserver.oct \
       recv.oct  reval.oct  send.oct \
       __bw_is_locked__.oct __bw_lock_file__.oct \
       __bw_unlock_file__.oct \
       __bw_prcv__.oct __bw_psend__.oct \
       select.oct


all: $(OCTS)

%.oct: %.cc
	mkoctfile -s $<

clean: ; rm *.o *.oct
