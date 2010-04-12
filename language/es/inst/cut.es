md5="e450ca243849b51ae6d0650f32413b5e";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} cut (@var{x}, @var{breaks})
Crea categorias de datos a partir de datos continuos o num@'ericos 
mediante el corte en intervalos.

Si @var{breaks} es un escalar, los datos se cortan en intervalos del 
mismo ancho. Si @var{breaks} es un vector de puntos de corte,
la categor@'ia tendr@'a @code{length (@var{breaks}) - 1} grupos.

El valor retornado es un vector del mismo tama@~{n}o de @var{x} 
diciendo a que grupo pertenece cada punto en @var{x}. Los gurpo se enumeran 
desde 1 hasta el n@'umero de grupos; los puntos que est@'an fuera del rango de 
@var{breaks} se etiquetan como @code{NaN}.
@end deftypefn
