# Sparse algorithms tests
#

mult_test: sparse_mul.oct
	octave -q --eval 'LOADPATH=["..",LOADPATH];' \
	          --eval 'sparse(zeros(1)); a=sparse(diag(1:4,1));' \
	          --eval 'sparse_mul(a,a,1),sparse_mul(a,a,2),sparse(a,a,3)' 

sparse_mul.oct: sparse_mul.cc
	mkoctfile -v -I.. -I../SuperLU/SRC sparse_mul.cc 

