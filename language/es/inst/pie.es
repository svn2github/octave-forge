md5="6f8a7cb5e5dd11dbff0ddb8dcf69e798";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} pie (@var{y})
@deftypefnx {Archivo de función} {} pie (@var{y}, @var{explode})
@deftypefnx {Archivo de función} {} pie (@dots{}, @var{labels})
@deftypefnx {Archivo de función} {} pie (@var{h}, @dots{});
@deftypefnx {Archivo de función} {@var{h} =} pie (@dots{});
Producir un gráfico circular.

Llamada con un argumento vector único, produce un gráfico circular
de los elementos de @var{x}, con el tama@~{n}o de la porción determinada
por el porcentaje del tama@~{n}o de los valores de @var{x}.

La variable @var{explode} es un vector de la misma longitud de @var{x}
que si no es cero 'explota' la rebanada de la gráfica de pastel.

Si se le da @var{labels} es un conjunto de celdas de cadenas de la misma
longitud que @var{x}, dando las etiquetas de cada uno de los cortes de la
gráfica de pastel.

El valor de retorno opcional @var{h} proporciona un identificador para el
objeto de revisión.
@seealso{bar, stem}
@end deftypefn