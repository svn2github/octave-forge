md5="8298c622c88ea5c91bc0b56c44705bed";rev="6241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} errorbar (@var{args})
Produce gr@'aficas de dos dimensiones con barras de error. Son 
posibles varias combinaciones de argumentos. La forma m@'as simple es 

@example
errorbar (@var{y}, @var{ey})
@end example

@noindent
donde el primer argumento se toma como el conjunto de coordenadas de @var{y} 
y el segundo argumento @var{ey} se toma como los errores de los valores de 
@var{y}. Las coordenadas de @var{x} son los @'indices de los elementos, 
comenzando con 1.

Si es dan m@'as de dos argumentos, se interpretan como 

@example
errorbar (@var{x}, @var{y}, @dots{}, @var{fmt}, @dots{})
@end example

@noindent
donde despu@'es de @var{x} y @var{y} pueden haber hasta cuatro 
par@'amentros como @var{ey}, @var{ex}, @var{ly}, @var{uy} etc.,
dependiendo del tipo de gr@'afica. Puede aparecer cualquier n@'umero de argumentos,
entre tanto est@'en separados con una cadena de formato @var{fmt}.

Si @var{y} es una matriz, @var{x} y los par@'ametros de error deben 
ser matrices y tener la misma dimensi@'on. Las columnas de @var{y} 
se grafican en funci@'on de las correspondientes columnas de @var{x} 
y las barras de error son tomadas de las correspondientes columnas 
de los par@'ametros de error.

Si no se especifica @var{fmt}, se asume el estilo para las barras de 
error en @var{y} como ("~").

Si se suministra el argumento @var{fmt}, se interpreta como en las 
gr@'aficas normales. Adicionalmente, los siguientes estilos est@'an 
soportados por @code{errorbar}: 

@table @samp
@item ~
Establece el estilo de barras de error en @var{y} yerrorbars 
(predeterminado).

@item >
Establece el estilo de barras de error en @var{x} xerrorbars.

@item ~>
Establece el estilo de barras de error en @var{xy} xyerrorbars.

@item #
Establece el estilo de cajas box. 

@item #~
Establece el estilo de barras de error en boxxyerrorbars.

@item #~>
Establece el estilo de barras de error en boxxyerrorbars.
@end table

Ejemplos:

@example
errorbar (@var{x}, @var{y}, @var{ex}, ">")
@end example

produce una gr@'afica xerrorbar de @var{y} versus @var{x} con barras de 
error @var{x} de @var{x}-@var{ex} a @var{x}+@var{ex}.

@example
errorbar (@var{x}, @var{y1}, @var{ey}, "~",
@var{x}, @var{y2}, @var{ly}, @var{uy})
@end example

produce gr@'aficas de yerrorbar con @var{y1} y @var{y2} versus @var{x}.
Las barras de error para @var{y1} se toman desde @var{y1}-@var{ey} hasta 
@var{y1}+@var{ey}, y las barras de error para @var{y2} desde @var{y2}-@var{ly} 
hasta @var{y2}+@var{uy}.

@example
errorbar (@var{x}, @var{y}, @var{lx}, @var{ux},
@var{ly}, @var{uy}, "~>")
@end example

produce una gr@'afica de xyerrorbar para @var{y} versus @var{x} en donde 
las barras de error de @var{x} se toman desde @var{x}-@var{lx} hasta 
@var{x}+@var{ux} y las barras de error de @var{y} desde @var{y}-@var{ly} 
hasta @var{y}+@var{uy}.
@seealso{semilogxerr, semilogyerr, loglogerr}
@end deftypefn
