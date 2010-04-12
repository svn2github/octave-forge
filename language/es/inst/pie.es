md5="6f8a7cb5e5dd11dbff0ddb8dcf69e798";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} pie (@var{y})
@deftypefnx {Archivo de funci@'on} {} pie (@var{y}, @var{explode})
@deftypefnx {Archivo de funci@'on} {} pie (@dots{}, @var{labels})
@deftypefnx {Archivo de funci@'on} {} pie (@var{h}, @dots{});
@deftypefnx {Archivo de funci@'on} {@var{h} =} pie (@dots{});
Producir un gr@'afico circular.

Llamada con un argumento vector @'unico, produce un gr@'afico circular
de los elementos de @var{x}, con el tama@~{n}o de la porci@'on determinada
por el porcentaje del tama@~{n}o de los valores de @var{x}.

La variable @var{explode} es un vector de la misma longitud de @var{x}
que si no es cero 'explota' la rebanada de la gr@'afica de pastel.

Si se le da @var{labels} es un conjunto de celdas de cadenas de la misma
longitud que @var{x}, dando las etiquetas de cada uno de los cortes de la
gr@'afica de pastel.

El valor de retorno opcional @var{h} proporciona un identificador para el
objeto de revisión.
@seealso{bar, stem}
@end deftypefn