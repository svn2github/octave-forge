md5="8f5f012bc5e5da4bab23078e0eefd670";rev="5857";by="Javier Enciso <encisomo@in.tum.de>"
 -*- texinfo -*-
@deftypefn {Funci@'on cargable} {} cellfun (@var{name}, @var{c})
@deftypefnx {Funci@'on cargable} {} cellfun ("size", @var{c}, @var{k})
@deftypefnx {Funci@'on cargable} {} cellfun ("isclass", @var{c}, @var{class})
@deftypefnx {Funci@'on cargable} {} cellfun (@var{func}, @var{c})
@deftypefnx {Funci@'on cargable} {} cellfun (@var{func}, @var{c}, @var{d})
@deftypefnx {Funci@'on cargable} {[@var{a}, @var{b}] =} cellfun (@dots{})
@deftypefnx {Funci@'on cargable} {} cellfun (@dots{}, 'ErrorHandler', @var{errfunc})
@deftypefnx {Funci@'on cargable} {} cellfun (@dots{}, 'UniformOutput', @var{val})

Evalua la funci@'on llamada @var{name} en los elementos del arreglo
@var{c}. Los elementos de @var{c} se pasan en el nombre de la 
funci@'on individualmente. La funci@'on @var{name} puede ser una de 
las funciones

@table @code
@item isempty
Retorna 1 para elementos vacios.
@item islogical
Retorna 1 para elementos l@'ogicos.
@item isreal
Retorna 1 para elementos reales.
@item length
Retorna un vector de las longitudes de los elementos de las celdas.
@item ndims
Retorna el n@'umero de dimensiones de cada elemento.
@item prodofsize
Retorna el producto de dimensiones de cada elemento.
@item size
Retorna el tama@~{n}o a lo largo de la @var{k}-@'esima dimensi@'on.
@item isclass
Retorna 1 para elementos de @var{class}.
@end table

Adicionalmente, @code{cellfun} acepta una funci@'on arbitraria @var{func}
en forma de una funci@'on en l@'inea, manejador de funci@'on, o el 
nombre de una funci@'on (en una cadena de caracteres). En caso de un 
argumento de cadena de caracteres, la funci@'on debe aceptar un solo 
argumento llamado @var{x}, y debe retarnar una cadena. La funci@'on 
puede tomar uno o m@'as argumentos, con los agumentos de entrada 
dados por @var{c}, @var{d}, etc. Igualmente, la funci@'on puede retornar uno o m@'as argumentos de salida. Por ejemplo

@example
@group
cellfun (@@atan2, @{1, 0@}, @{0, 1@})
@result{}ans = [1.57080   0.00000]
@end group
@end example

N@'otese que el argumento de salida predeterminado es un arreglo del mismo tama@~{n}o que los argumentos de entrada.

Si el par@'ametro 'UniformOutput' se establece true (predeterminado), 
la funci@'on debe retornar un solo elemento el cual ser@'a 
concatenado en el valor retornado. Si 'UniformOutput es false, las  
salidas se concatenan en un arreglo. Por ejemplo

@example
@group
cellfun ("tolower(x)", @{"Foo", "Bar", "FooBar"@},
         "UniformOutput",false)
@result{} ans = @{"foo", "bar", "foobar"@}
@end group
@end example

Dado el par@'ametro 'ErrorHandler', @var{errfunc} define una funci@'on para llamar en caso @var{func} genere un error. La forma de la funci@'on es

@example
function [@dots{}] = errfunc (@var{s}, @dots{})
@end example

donde existe un argumento de entrada adicional a @var{errfunc} 
relativo a @var{func}, dado por @var{s}. Esta es una estructura con 
los elementos 'identifier', 'message' e 'index', dando 
respectivamente el identificador del error, el mensaje de error, y 
el @'indice en los argumentos de entrada del elemento que caus@'o el 
error. Por ejemplo

@example
@group
function y = foo (s, x), y = NaN; endfunction
cellfun (@@factorial, @{-1,2@},'ErrorHandler',@@foo)
@result{} ans = [NaN 2]
@end group
@end example

@seealso{isempty, islogical, isreal, length, ndims, numel, size, isclass}
@end deftypefn
