#SPY    Visualize the sparsity structure.
#  spy(S) -> plot the sparsity pattern of sparse matrix S.    
#
#Copyright (C) 1998 Andy Adler.
#This code has no warranty whatsoever.
#You may do what you like with this code as long as you leave this copyright
#in place.  If you modify the code then include a notice saying so.
#
# $Id$
function spy(S) 

if is_matrix(S)
   [i,j,s] = find(S);
   [m,n] = size(S);
else
   [i,j,s,m,n]= spfind(S);
endif

eval(sprintf('gset nokey'))
eval(sprintf('gset yrange [0:%d] reverse',m+1))
eval(sprintf('gset xrange [0:%d] noreverse',n+1))


if (length(i)<1000)
  plot(j,i,'*');
else
  plot(j,i,'.');
endif

#TODO: we should sore the reverse state so we don't undo it
gset yrange [0:1] noreverse
axis;

#
# $Log$
# Revision 1.3  2002/08/02 17:35:57  pkienzle
# Make xy range a little bit bigger so that points don't fall right on the
# boundary (thanks to Victor Eijkhout <eijkhout@cs.utk.edu> for the patch)
#
# Revision 1.2  2002/08/01 17:10:24  pkienzle
# handle dense matrices as well
#
# Revision 1.1  2001/10/14 03:06:31  aadler
# fixed memory leak in complex sparse solve
# fixed malloc bugs for zero size allocs
#
# Revision 1.1  1998/11/16 05:01:09  andy
# Initial revision
#
#
