md5="a57b1701ab981cbc924409dfb550c441";rev="7224";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {@var{aa} =} balance (@var{a}, @var{opt})
@deftypefnx {Función cargable} {[@var{dd}, @var{aa}] =} balance (@var{a}, @var{opt})
@deftypefnx {Función cargable} {[@var{cc}, @var{dd}, @var{aa}, @var{bb}] =} balance (@var{a}, @var{b}, @var{opt})

Calcula @code{aa = dd \ a * dd} en el cual @code{aa} es una matriz cuyas 
normas de filas y columnas son aproximadamente iguales en magnitud, y
@code{dd} = @code{p * d}, en el cual @code{p} es una matriz de permutación
y @code{d} es una matriz diagonal de potencias de dos. Esto le permite a la 
adaptación ser calculada sin redondeos. Los resultados del cálculo de 
valores propios son típicamente mejorados mediante balance inicial.

Si los cuatro valores de salida son solicitados, calcula @code{aa = cc*a*dd} y
@code{bb = cc*b*dd)}, en el cual @code{aa} y @code{bb} tienen elementos 
distintos de cero de aproximadamente la misma magnitud y @code{cc} y @code{dd}
son matrices diagonales permutadas como es @code{dd} para el problema 
de valores propios algebraico.

La opción de balance de valores propios @code{opt} puede ser una de:

@table @asis
@item @code{"N"}, @code{"n"}
Sin balance; argumentos copiados, transformaciones establecidad a la matriz identidad.

@item @code{"P"}, @code{"p"}
Permuta argumento(s) para aislar valores propios donde sea posible.

@item @code{"S"}, @code{"s"}
Escala para mejorar la precisión de los valores propios calculados.

@item @code{"B"}, @code{"b"}
Permuta y escala, en ese orden. Filas/columnas de a (y b)
que son aislados por la permuración no son escalados. Este es el comportamiento 
predeterminado.
@end table

El balance algebraico de valores propios usa las rutinas estándar @sc{Lapack}.

El problema de balance de valores propios generalizados usa el algoritmo de Ward
(SIAM Journal on Scientific and Statistical Computing, 1981).
@end deftypefn
