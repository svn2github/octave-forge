md5="5dd025b3cfb497dd63f8dbe5e8fa2c2d";rev="6433";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} spdiag (@var{v}, @var{k})
Retorna una matriz diagonal con el vector disperso @var{v} en la 
diagonal @var{k}. El segundo argumento es opcional. Si es positivo, 
se ubica el vector en la @var{k}-@'esima diagonal superior. Si es 
negativo, se ubica el vector en la @var{k}-@'esima diagonal inferior. 
El valor predeterminado de @var{k} es 0, en este caso se ubica el 
vector en la diagonal principal. Por ejemplo, 

@example
spdiag ([1, 2, 3], 1)
ans =

Compressed Column Sparse (rows=4, cols=4, nnz=3)
  (1 , 2) -> 1
  (2 , 3) -> 2
  (3 , 4) -> 3
@end example
@seealso{diag}
@end deftypefn
