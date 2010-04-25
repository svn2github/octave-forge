md5="c3fd3eca91295ddeda1fc97e942b82f6";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} ones (@var{x})
@deftypefnx {Función incorporada} {} ones (@var{n}, @var{m})
@deftypefnx {Función incorporada} {} ones (@var{n}, @var{m}, @var{k}, @dots{})
@deftypefnx {Función incorporada} {} ones (@dots{}, @var{class})
Regresa una matriz o un arreglo de N-dimensiones cuyos elementos son 
todos 1. Los argumentos que se manejan son los mismos que los argumentos
para @code{eye}.

Si se necesita crear una matriz cuyos valores son todos iguales, puede
utilizar una expresión como

@example
val_matrix = val * ones (n, m)
@end example

El argumento opcional @var{class}, permite a @code{ones} retornar un arreglo
del tipo especificado, por ejemplo
@example
val = ones (n,m, "uint8")
@end example
@end deftypefn