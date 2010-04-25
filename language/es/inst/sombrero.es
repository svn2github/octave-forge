md5="64978c907e28ee97005e188de22cd962";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} sombrero (@var{n})
Produce la gráfica de sombrero en tres dimensiones usando una 
mayo de @var{n} líneas. Si se omite @var{n}, se asume el valor 
de 41. 

La función graficada es 

@example
z = sin (sqrt (x^2 + y^2)) / (sqrt (x^2 + y^2))
@end example
@seealso{surf, meshgrid, mesh}
@end deftypefn
