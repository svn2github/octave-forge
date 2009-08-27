md5="888fa88df1ffbd77cc41c319dc133a3c";rev="6137";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{sys} =} jet707 ()
Crea un modelo linearizado del espacio de estados de un avi@'on Boeing 707-321 
a @var{v}=80 m/s 
@iftex
@tex
($M = 0.26$, $G_{a0} = -3^{\circ}$, ${\alpha}_0 = 4^{\circ}$, ${\kappa}= 50^{\circ}$).
@end tex
@end iftex
@ifinfo
(@var{M} = 0.26, @var{Ga0} = -3 deg, @var{alpha0} = 4 deg, @var{kappa} = 50 deg).
@end ifinfo

Entradas del sistema: (1) empuje y (2) @'angulo de elevaci@'on.

Salidas del sistema:  (1) velocidad del aire y (2) @'angulo de inclinaci@'on.

@strong{Referencia}: R. Brockhaus: @cite{Flugregelung} (Flight
Control), Springer, 1994.
@seealso{ord2}
@end deftypefn
