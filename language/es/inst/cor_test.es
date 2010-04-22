md5="b854e7ae1b356276f116df5db40e6c37";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} cor_test (@var{x}, @var{y}, @var{alt}, @var{method})
Prueba si dos muestras @var{x} y @var{y} vienen de poblaciones no correlacionadas.

El argumento opcional @var{alt} describe la hipótesis alternativa, 
y puede ser @code{"!="} o @code{"<>"} (distinto de cero),
@code{">"} (mayor que cero), o @code{"<"} (menor que cero). El valor 
predeterminado es el caso de dos lados.

El argumento opcional @var{method} especifica sobre cual 
coeficiente de correlación se aplicará la prueba. Si @var{method} es
@code{"pearson"} (predeterminado), se usa el coeficiente de correlación Producto 
momento de Pearson. En este caso, los datos deverian venir 
de una distribución normal bivariada. En otro caso, los otros dos 
métodos ofrecen alternativas no paramétricas. Si @var{method} es
@code{"kendall"}, se usa el rango de correlación tau de Kendall. Si
@var{method} es @code{"spearman"}, se usa el rango de correlación rho de Spearman.  
Solo es necesario el primer caracter.

La salida es una estructura con los siguientes elementos:

@table @var
@item pval
El valor p de la prueba.
@item stat
EL valor del estadístico de prueba.
@item dist
La distribución del estadístico de prueba.
@item params
Los parámetros de la distribución nula del estadístico de prueba.
@item alternative
La hipótesis alternativa.
@item method
El método usado para la prueba.
@end table

Si no se suministra arumento de salida, se muestra el valor p.
@end deftypefn
