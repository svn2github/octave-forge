md5="44e60bcb65ff330203e946094bcc4196";rev="6944";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{q} =} polygcd (@var{b}, @var{a}, @var{tol})
Encuentra el m@'aximo com@'un divisor de dos polinomios. Esto es
equivalente al polinomio multiplicado por todas ra@'ices comunes.
Junto con deconv, puede reducir el cociente de dos polinomos.
La tolerancia por defecto es

@example 
sqrt(eps).
@end example
Tenga en cuenta que es un algoritmo inestable, por lo que no lo
intentes en polinomios de gran tama@~{n}o

Example
@example
polygcd (poly(1:8), poly(3:12)) - poly(3:8)
@result{} [ 0, 0, 0, 0, 0, 0, 0 ]
deconv (poly(1:8), polygcd (poly(1:8), poly(3:12))) ...
  - poly(1:2)
@result{} [ 0, 0, 0 ]
@end example
@seealso{poly, polyinteg, polyderiv, polyreduce, roots, conv, deconv,
residue, filter, polyval, and polyvalm}
@end deftypefn