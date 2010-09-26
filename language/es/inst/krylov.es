-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{u}, @var{h}, @var{nu}] =} krylov (@var{a}, @var{v}, @var{k}, @var{eps1}, @var{pflg})
Construya una base ortogonal @var{u} de bloque de Krylov subespacio

@example
[v a*v a^2*v ... a^(k+1)*v]
@end example

@noindent
Uso de reflexiones de Householder para protegerse contra la pérdida de
ortogonalidad.

Si @var{v} es un vector, luego @var{h} contiene la matriz Hessenberg
de tal manera que @code{a*u == u*h+rk*ek'}, en el que @code{rk =
a*u(:,k)-u*h(:,k)}, y @code{ek'} es el vector
@code{[0, 0, @dots{}, 1]} de longitud @code{k}.  De otra manera, @var{h}
no tiene sentido.

Si @var{v} es un vector y @var{k} es mayor que
@code{length(A)-1}, entonces @var{h} contiene la matriz de tal manera que
Hessenberg @code{a*u == u*h}.

El valor de @var{nu} es la dimensión de la envergadura del subespacio
de Krylov (basada en @var{eps1}).

Si @var{b} es un vector y @var{k} es mayor que @var{m-1}, entonces
@var{h} contiene la descomposición de Hessenberg @var{a}.

Los parametros opcionales @var{eps1} es el umbral de cero. El valor
predeterminado es 1e-12.

Si el parámetro opcional @var{pflg} es distinto de cero, girando fila
se utiliza para mejorar el comportamiento numérico. El valor 
predeterminado es 0.

Referencia: Hodel y Misra, "dar un giro parcial en el cálculo de 
subespacios de Krylov", que se presentará al Álgebra Lineal y sus
Aplicaciones
@end deftypefn
