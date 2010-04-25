md5="f6d735d81cc7e866d0d74072261e20a1";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{r}, @var{k}] =} rref (@var{a}, @var{tol})
Retorna la forma echelon de fila reducida de @var{a}. El argumento @var{tol} 
es determinado mendiante @code{eps * max (size (@var{a})) * norm (@var{a}, inf)}.

Cuando se invoca con dos argumentos, @var{k} retorna el vector de 
"variables ligadas", las cuales son aquellas columnas en donde se realizará 
la eliminación. 
@end deftypefn
