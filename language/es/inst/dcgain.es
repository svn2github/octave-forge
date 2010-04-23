md5="ea7b38aaa21ea98dfe0018c267cd4a6d";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} dcgain (@var{sys}, @var{tol})
Retorna la matriz de ganacia dc. Si la ganancia dc es infinita, 
se retorna una maitrx vacia.
el argumento @var{tol} es una tolerancia opcional para el número 
de condición de la matriz @math{A} en @var{sys} (valor predetermiando 
@var{tol} = 1.0e-10)
@end deftypefn
