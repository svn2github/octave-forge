# Sparse algorithms tests
#

mult_test: sparse_mul.oct
	echo \
	  'ALGS= 1:3;' \
	  'LOADPATH=["..:.:",LOADPATH];' \
	  'a=diag(1:4,1)+eye(5);aa=a*a;s=sparse(a);' \
	  'sz= 1e3;' \
	  'for alg= ALGS;' \
	    'ss=sparse_mul(s,s,alg);' \
	    'if all(all(ss==aa)); printf("Alg %d OK\n",alg); end;' \
	  'end;' \
	  \
	  'dd=1;for d=[1e-6,1e-5,1e-4,1e-3,1e-2,3e-2,1e-1,3e-1,5e-1];' \
	     'for alg= ALGS;' \
	        's=sprand(sz,sz,d);' \
	        't=cputime;' \
		'iters= sqrt(ceil(.01/d));' \
	        'for k=1:iters; sparse_mul(s,s,alg); end;' \
	        'tt(dd,alg) = (cputime-t)/iters;' \
	     'end; dd++;' \
	  'end; disp(tt);' \
	| octave -q


sparse_mul.oct: sparse_mul.cc
	mkoctfile -v -I.. -I../SuperLU/SRC sparse_mul.cc 

