-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{retval}, @var{pc}, @var{pf}] =} hinfsyn_chk (@var{a}, @var{b1}, @var{b2}, @var{c1}, @var{c2}, @var{d12}, @var{d21}, @var{g}, @var{ptol})
Llamado por @code{hinfsyn} para ver si el aumento de @var{g} cumple las 
condiciones previstas en el
Teorema 3 de
Doyle, Glover, Khargonekar, Francis, @cite{State Space Solutions to Standard}

@iftex
@tex
$ { \cal H }_2 $ @cite{and} $ { \cal H }_\infty $
@end tex
@end iftex
@ifinfo
@cite{H-2 and H-infinity}
@end ifinfo
@cite{Control Problems}, @acronym{IEEE} @acronym{TAC} August 1989.

@strong{Precausión:} no trate de utilizar esto en el home; ningún
argumento de control esta realizado.

@strong{Entradas}

Como retorna por @code{is_dgkf}, excepto para:
@table @var
@item g
candidato nivel de ganancia
@item ptol
 como en @code{hinfsyn}
@end table

@strong{Salidas}
@table @var
@item retval
1 si g excede la ganancia Hinf cerrada óptima del bucle,
de lo contrario 0

@item pc
solución de ``regulator'' 
@iftex
@tex
$ { \cal H }_\infty $
@end tex
@end iftex
@ifinfo
H-infinity
@end ifinfo
@acronym{ARE}
@item pf
solution of ``filter''
@iftex
@tex
$ { \cal H }_\infty $
@end tex
@end iftex
@ifinfo
H-infinity
@end ifinfo
@acronym{ARE}
@end table
No intente usar esto en su home; ningún argumento de control realizadas
@end deftypefn
