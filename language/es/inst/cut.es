md5="e450ca243849b51ae6d0650f32413b5e";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} cut (@var{x}, @var{breaks})
Crea categorias de datos a partir de datos continuos o numéricos 
mediante el corte en intervalos.

Si @var{breaks} es un escalar, los datos se cortan en intervalos del 
mismo ancho. Si @var{breaks} es un vector de puntos de corte,
la categoría tendrá @code{length (@var{breaks}) - 1} grupos.

El valor retornado es un vector del mismo tama@~{n}o de @var{x} 
diciendo a que grupo pertenece cada punto en @var{x}. Los gurpo se enumeran 
desde 1 hasta el número de grupos; los puntos que están fuera del rango de 
@var{breaks} se etiquetan como @code{NaN}.
@end deftypefn
