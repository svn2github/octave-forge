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

[i,j,s,m,n]= spfind(S);

eval(sprintf('gset nokey'))
eval(sprintf('gset yrange [1:%d] reverse',m))
eval(sprintf('gset xrange [1:%d] noreverse',n))

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
# Revision 1.1  2001/10/14 03:06:31  aadler
# fixed memory leak in complex sparse solve
# fixed malloc bugs for zero size allocs
#
# Revision 1.1  1998/11/16 05:01:09  andy
# Initial revision
#
#
