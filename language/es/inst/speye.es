md5="67b33986d4df8d49779ac7d821f48362";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{y} =} speye (@var{m})
@deftypefnx {Archivo de función} {@var{y} =} speye (@var{m}, @var{n})
@deftypefnx {Archivo de función} {@var{y} =} speye (@var{sz})
Retorna una matriz identidad dispersa. Esta función es significativamente 
más eficiente que @code{sparse (eye (@var{m}))} debido a que no 
se construye la matriz completa. 

Cuando se llama sin argumentos, se crea una matriz dispersa de 
@var{m} por @var{m}. En otro caso, se crea una matriz de @var{m} 
por @var{n}. Si se llama con un solo vector como argumento, se toma 
este argumento como el tama@~{n}o de la matriz que se va a crear.
@end deftypefn
