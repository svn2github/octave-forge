md5="ecfb21b095d695b24af1745e542e7163";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{retval} =} is_detectable (@var{a}, @var{c}, @var{tol}, @var{dflg})
@deftypefnx {Archivo de función} {@var{retval} =} is_detectable (@var{sys}, @var{tol})

Prueba la detectibilidad (observabilidad de los modis inestables) 
de (@var{a}, @var{c}). 

Retorn 1 si el sistema @var{a} o la pareja (@var{a}, @var{c}) es 
detectable, 0 si no lo és, y -1 si el sistema tiene modos no 
observables en el eje imaginario (círculo unitario para sistemas 
de tiempo discreto). 

Véase el comando @command{is_stabilizable} para una descripción 
detallada de los argumentos y los métodos computacionales.

@seealso{is_stabilizable, size, rows, columns, length, ismatrix,
isscalar, isvector}
@end deftypefn
