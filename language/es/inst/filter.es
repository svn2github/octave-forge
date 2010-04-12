md5="0e5affc63e823b484067389f2a54bfe0";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {y =} filter (@var{b}, @var{a}, @var{x})
@deftypefnx {Funci@'on cargable} {[@var{y}, @var{sf}] =} filter (@var{b}, @var{a}, @var{x}, @var{si})
@deftypefnx {Funci@'on cargable} {[@var{y}, @var{sf}] =} filter (@var{b}, @var{a}, @var{x}, [], @var{dim})
@deftypefnx {Funci@'on cargable} {[@var{y}, @var{sf}] =} filter (@var{b}, @var{a}, @var{x}, @var{si}, @var{dim})
Retorna la soluci@'on de la siguiente ecuaci@'on de diferencias lineal, 
invariante en el tiempo: 
@iftex
@tex
$$
\sum_{k=0}^N a_{k+1} y_{n-k} = \sum_{k=0}^M b_{k+1} x_{n-k}, \qquad
 1 \le n \le P
$$
@end tex
@end iftex
@ifinfo

@smallexample
   N                   M
  SUM a(k+1) y(n-k) = SUM b(k+1) x(n-k)      para 1<=n<=length(x)
  k=0                 k=0
@end smallexample
@end ifinfo

@noindent
donde 
@ifinfo
 N=length(a)-1 y M=length(b)-1.
@end ifinfo
@iftex
@tex
 $a \in \Re^{N-1}$, $b \in \Re^{M-1}$, y $x \in \Re^P$.
@end tex
@end iftex
sobre la primera dimensi@'on no singleton de @var{x} o sobre @var{dim} si 
se suministra. Una forma equivalente de esta ecuaci@'on es: 
@iftex
@tex
$$
y_n = -\sum_{k=1}^N c_{k+1} y_{n-k} + \sum_{k=0}^M d_{k+1} x_{n-k}, \qquad
 1 \le n \le P
$$
@end tex
@end iftex
@ifinfo

@smallexample
            N                   M
  y(n) = - SUM c(k+1) y(n-k) + SUM d(k+1) x(n-k)  para 1<=n<=length(x)
           k=1                 k=0
@end smallexample
@end ifinfo

@noindent
donde 
@ifinfo
 c = a/a(1) y d = b/a(1).
@end ifinfo
@iftex
@tex
$c = a/a_1$ y $d = b/a_1$.
@end tex
@end iftex

Si se suministra el cuarto argumento @var{si}, se toma como el 
estado inicial del sistema y el estado final se retorna como 
@var{sf}. El vector de estado es un vector columna cuya longitud es 
igual a la longitud del vector de coeficientes mas largo menos uno. 
Si no se suministra @var{si}, se asigna cero al vector de estado inicial.

En t@'erminos de la transformada z, la variable @var{y} es el resultado de 
pasar la se@~{n}al discreta @var{x} a trav@'es del sistema caracterizado por
la siguiente funci@'on racional del sistema: 
@iftex
@tex
$$
H(z) = {\displaystyle\sum_{k=0}^M d_{k+1} z^{-k}
        \over 1 + \displaystyle\sum_{k+1}^N c_{k+1} z^{-k}}
$$
@end tex
@end iftex
@ifinfo

@example
             M
            SUM d(k+1) z^(-k)
            k=0
  H(z) = ----------------------
               N
          1 + SUM c(k+1) z(-k)
              k=1
@end example
@end ifinfo
@end deftypefn
