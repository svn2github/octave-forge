md5="ecfb21b095d695b24af1745e542e7163";rev="6466";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{retval} =} is_detectable (@var{a}, @var{c}, @var{tol}, @var{dflg})
@deftypefnx {Archivo de funci@'on} {@var{retval} =} is_detectable (@var{sys}, @var{tol})

Prueba la detectibilidad (observabilidad de los modis inestables) 
de (@var{a}, @var{c}). 

Retorn 1 si el sistema @var{a} o la pareja (@var{a}, @var{c}) es 
detectable, 0 si no lo @'es, y -1 si el sistema tiene modos no 
observables en el eje imaginario (c@'irculo unitario para sistemas 
de tiempo discreto). 

V@'ease el comando @command{is_stabilizable} para una descripci@'on 
detallada de los argumentos y los m@'etodos computacionales.

@seealso{is_stabilizable, size, rows, columns, length, ismatrix,
isscalar, isvector}
@end deftypefn
