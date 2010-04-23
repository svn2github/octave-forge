md5="55d79558f2bac46301d342fa5528ec4c";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{h} =} findobj ()
@deftypefnx {Archivo de función} {@var{h} =} findobj (@var{propName}, @var{propValue})
@deftypefnx {Archivo de función} {@var{h} =} findobj ('-property', @var{propName})
@deftypefnx {Archivo de función} {@var{h} =} findobj ('-regexp', @var{propName},, @var{pattern})
@deftypefnx {Archivo de función} {@var{h} =} findobj ('flat', @dots{})
@deftypefnx {Archivo de función} {@var{h} =} findobj (@var{h}, @dots{})
@deftypefnx {Archivo de función} {@var{h} =} findobj (@var{h}, '-depth', @var{d}, @dots{})
Encuentra el objeto con valores de la propiedad especificada. La forma 
más simple es

@example
findobj (@var{propName}, @var{propValue})
@end example

@noindent
lo cual regresa todos los objetos con la propiedad con el nombre
@var{propName}  y el valor @var{propValue}. la busqueda puede ser limitada
a un objeto en particular  o un conjunto de objetos y sus decendientes
pasando una propiedad o conjunto de propiedades @var{h} como el primer
argumento @code{findobj}.

La profundidad del la jerarquía de objetos a buscar puede ser limitada
con el argumento '-depth'. Para limitar el número de la profundidad de 
jerarquía a la búsquedad de @var{d} generaciones decendientes, 
el ejemplo es

@example
findobj (@var{h}, '-depth', @var{d}, @var{propName}, @var{propValue})
@end example

Especificar una profundidad @var{d} de 0, límita la búsqueda a el 
conjunto de objetos pasado en @var{h}. Una profundidad de 0 es equivalente
al argumento '-flat'

Un operador lógico podría ser a aplicado a los pares de @var{propName}
y @var{propValue}. Los operadores lógicos soportados son '-and', '-or',
'-xor', '-not'.

Los objetos también pueden ser fijados comparando una expresión 
regular al valor de la propiedad, donde el valor de la propiedad 
corresponde @code{regexp (@var{propValue}, @var{pattern})} al ser 
devuelto. Finalmente los objetos pueden ser igualados solamente por 
el nombre de la propiedad, usando la opción '-property'
@seealso{get,set}
@end deftypefn