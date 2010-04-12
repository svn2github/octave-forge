md5="a57b1701ab981cbc924409dfb550c441";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {@var{aa} =} balance (@var{a}, @var{opt})
@deftypefnx {Funci@'on cargable} {[@var{dd}, @var{aa}] =} balance (@var{a}, @var{opt})
@deftypefnx {Funci@'on cargable} {[@var{cc}, @var{dd}, @var{aa}, @var{bb}] =} balance (@var{a}, @var{b}, @var{opt})

Calcula @code{aa = dd \ a * dd} en el cual @code{aa} es una matriz cuyas 
normas de filas y columnas son aproximadamente iguales en magnitud, y
@code{dd} = @code{p * d}, en el cual @code{p} es una matriz de permutaci@'on
y @code{d} es una matriz diagonal de potencias de dos. Esto le permite a la 
adaptaci@'on ser calculada sin redondeos. Los resultados del c@'alculo de 
valores propios son t@'ipicamente mejorados mediante balance inicial.

Si los cuatro valores de salida son solicitados, calcula @code{aa = cc*a*dd} y
@code{bb = cc*b*dd)}, en el cual @code{aa} y @code{bb} tienen elementos 
distintos de cero de aproximadamente la misma magnitud y @code{cc} y @code{dd}
son matrices diagonales permutadas como es @code{dd} para el problema 
de valores propios algebraico.

La opci@'on de balance de valores propios @code{opt} puede ser una de:

@table @asis
@item @code{"N"}, @code{"n"}
Sin balance; argumentos copiados, transformaciones establecidad a la matriz identidad.

@item @code{"P"}, @code{"p"}
Permuta argumento(s) para aislar valores propios donde sea posible.

@item @code{"S"}, @code{"s"}
Escala para mejorar la precisión de los valores propios calculados.

@item @code{"B"}, @code{"b"}
Permuta y escala, en ese orden. Filas/columnas de a (y b)
que son aislados por la permuraci@'on no son escalados. Este es el comportamiento 
predeterminado.
@end table

El balance algebraico de valores propios usa las rutinas est@'andar @sc{Lapack}.

El problema de balance de valores propios generalizados usa el algoritmo de Ward
(SIAM Journal on Scientific and Statistical Computing, 1981).
@end deftypefn
