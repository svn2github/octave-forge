md5="5b0190ce3a0898a03372501b5f5c3fff";rev="6944";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} hist (@var{y}, @var{x}, @var{norm})
Realizar conteos de histograma o gr@'aficos.

Con un vector como argumento de entrada, grafica un histograma de 
los valores con 10 contenedores. El rango de los contenedores  del
histograma est@'a determinado por el rango de los datos.

Dado un segundo argumento escalar, se utiliza como el n@'umero de
contenedores, Con el ancho de los contenedores como los valores
adyacentes en el vector.

Si no se proporciona tercer argumento, el histograma se normaliza
de forma que la suma de las barras es igual a @var{norm}.

Los valores extremos son agrupados en el primero y @'ultimo contenedor.

Con dos argumentos de salida, se producen los valores@var{nn} y @var{xx}
tal que @code{bar (@var{xx}, @var{nn})} gr@'afica el histograma.
@seealso{bar}
@end deftypefn