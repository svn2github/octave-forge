md5="5b0190ce3a0898a03372501b5f5c3fff";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} hist (@var{y}, @var{x}, @var{norm})
Realizar conteos de histograma o gráficos.

Con un vector como argumento de entrada, grafica un histograma de 
los valores con 10 contenedores. El rango de los contenedores  del
histograma está determinado por el rango de los datos.

Dado un segundo argumento escalar, se utiliza como el número de
contenedores, Con el ancho de los contenedores como los valores
adyacentes en el vector.

Si no se proporciona tercer argumento, el histograma se normaliza
de forma que la suma de las barras es igual a @var{norm}.

Los valores extremos son agrupados en el primero y último contenedor.

Con dos argumentos de salida, se producen los valores@var{nn} y @var{xx}
tal que @code{bar (@var{xx}, @var{nn})} gráfica el histograma.
@seealso{bar}
@end deftypefn