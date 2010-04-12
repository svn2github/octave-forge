md5="e8d63fef65bf65f530ba20de198dfd32";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{W} =} wgt1o (@var{vl}, @var{vh}, @var{fc})
Obtenga la descripci@'on de espacio de primer orden que pondera 
la funci@'on.

Ponderar la funci@'on es necesario para el
@iftex
@tex
$ { \cal H }_2 / { \cal H }_\infty $
@end tex
@end iftex
@ifinfo
H-2/H-infinity
@end ifinfo
diseñar el procedimiento.
Estas funciones son parte de la planta aumentada @var{P}
(revise @command{hinfdemo} para una aplicaci@'on de ejemplo).
@strong{Entradas}
@table @var
@item vl
adelante a las frecuencias bajas.
@item vh
adelante a las frecuencias altas.
@item fc
La frecuencia de esquina (en Hz, @strong{not} en rad/sec)
@end table

@strong{Salidas}
@table @var
@item W
Funci@'on ponderada, dada en forma de estructura de datos de sistema.
@end table
@end deftypefn
