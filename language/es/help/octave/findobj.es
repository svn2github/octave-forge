md5="55d79558f2bac46301d342fa5528ec4c";rev="6834";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{h} =} findobj ()
@deftypefnx {Archivo de funci@'on} {@var{h} =} findobj (@var{propName}, @var{propValue})
@deftypefnx {Archivo de funci@'on} {@var{h} =} findobj ('-property', @var{propName})
@deftypefnx {Archivo de funci@'on} {@var{h} =} findobj ('-regexp', @var{propName},, @var{pattern})
@deftypefnx {Archivo de funci@'on} {@var{h} =} findobj ('flat', @dots{})
@deftypefnx {Archivo de funci@'on} {@var{h} =} findobj (@var{h}, @dots{})
@deftypefnx {Archivo de funci@'on} {@var{h} =} findobj (@var{h}, '-depth', @var{d}, @dots{})
Encuentra el objeto con valores de la propiedad especificada. La forma 
m@'as simple es

@example
findobj (@var{propName}, @var{propValue})
@end example

@noindent
lo cual regresa todos los objetos con la propiedad con el nombre
@var{propName}  y el valor @var{propValue}. la busqueda puede ser limitada
a un objeto en particular  o un conjunto de objetos y sus decendientes
pasando una propiedad o conjunto de propiedades @var{h} como el primer
argumento @code{findobj}.

La profundidad del la jerarqu@'ia de objetos a buscar puede ser limitada
con el argumento '-depth'. Para limitar el n@'umero de la profundidad de 
jerarqu@'ia a la b@'usquedad de @var{d} generaciones decendientes, 
el ejemplo es

@example
findobj (@var{h}, '-depth', @var{d}, @var{propName}, @var{propValue})
@end example

Especificar una profundidad @var{d} de 0, l@'imita la b@'usqueda a el 
conjunto de objetos pasado en @var{h}. Una profundidad de 0 es equivalente
al argumento '-flat'

Un operador l@'ogico podr@'ia ser a aplicado a los pares de @var{propName}
y @var{propValue}. Los operadores l@'ogicos soportados son '-and', '-or',
'-xor', '-not'.

Los objetos tambi@'en pueden ser fijados comparando una expresi@'on 
regular al valor de la propiedad, donde el valor de la propiedad 
corresponde @code{regexp (@var{propValue}, @var{pattern})} al ser 
devuelto. Finalmente los objetos pueden ser igualados solamente por 
el nombre de la propiedad, usando la opci@'on '-property'
@seealso{get,set}
@end deftypefn