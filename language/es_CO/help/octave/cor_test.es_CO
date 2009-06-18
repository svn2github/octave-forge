md5="b854e7ae1b356276f116df5db40e6c37";rev="5962";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} cor_test (@var{x}, @var{y}, @var{alt}, @var{method})
Prueba si dos muestras @var{x} y @var{y} vienen de poblaciones no correlacionadas.

El argumento opcional @var{alt} describe la hip@'otesis alternativa, 
y puede ser @code{"!="} o @code{"<>"} (distinto de cero),
@code{">"} (mayor que cero), o @code{"<"} (menor que cero). El valor 
predeterminado es el caso de dos lados.

El argumento opcional @var{method} especifica sobre cual 
coeficiente de correlaci@'on se aplicar@'a la prueba. Si @var{method} es
@code{"pearson"} (predeterminado), se usa el coeficiente de correlaci@'on Producto 
momento de Pearson. En este caso, los datos deverian venir 
de una distribuci@'on normal bivariada. En otro caso, los otros dos 
m@'etodos ofrecen alternativas no param@'etricas. Si @var{method} es
@code{"kendall"}, se usa el rango de correlaci@'on tau de Kendall. Si
@var{method} es @code{"spearman"}, se usa el rango de correlaci@'on rho de Spearman.  
Solo es necesario el primer caracter.

La salida es una estructura con los siguientes elementos:

@table @var
@item pval
El valor p de la prueba.
@item stat
EL valor del estad@'istico de prueba.
@item dist
La distribuci@'on del estad@'istico de prueba.
@item params
Los par@'ametros de la distribuci@'on nula del estad@'istico de prueba.
@item alternative
La hip@'otesis alternativa.
@item method
El m@'etodo usado para la prueba.
@end table

Si no se suministra arumento de salida, se muestra el valor p.
@end deftypefn
