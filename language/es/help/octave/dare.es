md5="68361390818b394e88d40cd5658628aa";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{x} =} dare (@var{a}, @var{b}, @var{q}, @var{r}, @var{opt})

Retorna la soluci@'on @var{x} de la ecuac@'on algebr@'aica de Riccati de tiempo 
discreto
@iftex
@tex
$$
A^TXA - X + A^TXB  (R + B^TXB)^{-1} B^TXA + Q = 0
$$
@end tex
@end iftex
@ifinfo
@example
a' x a - x + a' x b (r + b' x b)^(-1) b' x a + q = 0
@end example
@end ifinfo
@noindent

@strong{Entradas}
@table @var
@item a
matriz de @var{n} por @var{n};

@item b
matriz de @var{n} por @var{m};

@item q
matriz de @var{n} por @var{n}, sim@'etrica semidefinida positiva, o una matriz de @var{p} por @var{n},
En el @'utimo caso se usa @math{q:=q'*q};

@item r
matriz de @var{m} por @var{m}, sim@'etrica semidefinida positiva (invertible);

@item opt
(argumento opcional; predeterminado = @code{"B"}):
Opci@'on que se pasa a @code{balance} previo a la factorizaci@'on ordenada @var{QZ}.
@end table

@strong{Salida}
@table @var
@item x
soluci@'on de @acronym{DARE}.
@end table

@strong{Method}
M@'etodo generalizado de valores propios (Van Dooren; @acronym{SIAM} J.
 Sci. Stat. Comput., Vol 2) aplicado.

V@'ease tambi@'en: Ran and Rodman, @cite{Stable Hermitian Solutions of Discrete
 Algebraic Riccati Equations}, Mathematics of Control, Signals and
 Systems, Vol 5, no 2 (1992), pp 165--194.
@seealso{balance, are}
@end deftypefn
