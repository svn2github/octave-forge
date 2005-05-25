## tsearchdemo
##    example of finding points in the delaunay triangulation
##
## tsearchdemo('nearest')
##    example of finding points in the voronoi diagram
##    *** needs dsearch ***

## Author: Paul Kienzle
## This program is public domain.

function tsearchdemo(nearest)

if nargin==0, nearest = 0; endif

## generate the vertices
x = rand(15,1);
y = rand(size(x));
%x = [0.1;0.8;0.2;0.4];
%y = [0.5;0.5;0.2;0.4];
%x = [0;0;1;1;rand(5,1)];
%y = [0;1;0;1;rand(length(x)-4,1)];

## generate the triangles
t = delaunay(x,y);

## build an empty image
[xi,yi]=meshgrid(linspace(0,1,500));

## fill the triangles
if nearest
  idx = dsearch(x(:),y(:),t,xi(:),yi(:));
else
  idx = tsearch(x(:),y(:),t,xi(:),yi(:));
endif
idx(isnan(idx)) = rows(t)+1;
idx = reshape(idx,size(xi))';

## draw the vertices as a 5 by 5 'X'
[nr,nc] = size(xi);
ptx = lookup(xi(1,3:nc-3),x);
pty = lookup(yi(3:nr-3,1),y);
c = rows(t)+2;
try dfi = do_fortran_indexing;
catch dfi = 0;
end
try wfi = warn_fortran_indexing;
catch wfi = 0;
end
unwind_protect
  do_fortran_indexing = 1;
  warn_fortran_indexing = 0;
  pts = nr*pty + ptx + 1;
  idx(pts) = c;
  idx(pts+4) = c;
  idx(pts+nr+1) = c;
  idx(pts+nr+3) = c;
  idx(pts+2*nr+2) = c;
  idx(pts+3*nr+1) = c;
  idx(pts+3*nr+3) = c;
  idx(pts+4*nr) = c;
  idx(pts+4*nr+4) = c;
unwind_protect_cleanup
  do_fortran_indexing = dfi;
  warn_fortran_indexing = wfi;
end_unwind_protect


## show the image
c=colormap;
colormap([rand(rows(t),3);0.7,0.7,0.7;0,0,0]);
imagesc(idx,1);
colormap(c);

## show the corresponding diagram
if nearest
  voronoi(x,y);
else
  delaunay(x,y);
endif
