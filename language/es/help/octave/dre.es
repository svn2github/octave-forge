md5="b1f0248d812a06ac7cafa73358e278a7";rev="6231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{tvals}, @var{plist}] =} dre (@var{sys}, @var{q}, @var{r}, @var{qf}, @var{t0}, @var{tf}, @var{ptol}, @var{maxits})
Resuelve la ecuaci@'on diferencial de Riccati
@ifinfo
@example
  -d P/dt = A'P + P A - P B inv(R) B' P + Q
  P(tf) = Qf
@end example
@end ifinfo
@iftex
@tex
$$ -{dP \over dt} = A^T P+PA-PBR^{-1}B^T P+Q $$
$$ P(t_f) = Q_f $$
@end tex
@end iftex
para ek sistema @acronym{LTI} @var{sys}. La soluci@'on del 
sistema est@'andar @acronym{LTI}
@ifinfo
@example
  min int(t0, tf) ( x' Q x + u' R u ) dt + x(tf)' Qf x(tf)
@end example
@end ifinfo
@iftex
@tex
$$ \min \int_{t_0}^{t_f} x^T Q x + u^T R u dt + x(t_f)^T Q_f x(t_f) $$
@end tex
@end iftex
optimal input is
@ifinfo
@example
  u = - inv(R) B' P(t) x
@end example
@end ifinfo
@iftex
@tex
$$ u = - R^{-1} B^T P(t) x $$
@end tex
@end iftex
@strong{Entradas}
@table @var
@item sys
Estructura de datos del sistema de tiempo continuo
@item q
Penalidad de integral de estado
@item r
Penalidad de integral de entrada
@item qf
Penalidad de estado terminal
@item t0
@itemx tf
L@'imites de integraci@'on
@item ptol
Tolerancia (usada para seleccionar las muestra de tiempo; v@'ease a 
continuaci@'on); predetermiando = 0.1
@item maxits
N@'umero de iteraciones de refinamiento (predetermiando = 10)
@end table
@strong{Salidas}
@table @var
@item tvals
Valores de tiempo en donde se calcula @var{p}(@var{t}) 
@item plist
Lista de valores de @var{p}(@var{t}); @var{plist} @{ @var{i} @}
es @var{p}(@var{tvals}(@var{i}))
@end table
El valor @var{tvals} es seleccionado tal que:
@iftex
@tex
$$ \Vert plist_{i} - plist_{i-1} \Vert < ptol $$
@end tex
@end iftex
@ifinfo
@example
|| Plist@{i@} - Plist@{i-1@} || < Ptol
@end example
@end ifinfo
para cada @var{i} entre 2 y length(@var{tvals}).
@end deftypefn
