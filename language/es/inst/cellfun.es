md5="8f5f012bc5e5da4bab23078e0eefd670";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
 -*- texinfo -*-
@deftypefn {Función cargable} {} cellfun (@var{name}, @var{c})
@deftypefnx {Función cargable} {} cellfun ("size", @var{c}, @var{k})
@deftypefnx {Función cargable} {} cellfun ("isclass", @var{c}, @var{class})
@deftypefnx {Función cargable} {} cellfun (@var{func}, @var{c})
@deftypefnx {Función cargable} {} cellfun (@var{func}, @var{c}, @var{d})
@deftypefnx {Función cargable} {[@var{a}, @var{b}] =} cellfun (@dots{})
@deftypefnx {Función cargable} {} cellfun (@dots{}, 'ErrorHandler', @var{errfunc})
@deftypefnx {Función cargable} {} cellfun (@dots{}, 'UniformOutput', @var{val})

Evalua la función llamada @var{name} en los elementos del arreglo
@var{c}. Los elementos de @var{c} se pasan en el nombre de la 
función individualmente. La función @var{name} puede ser una de 
las funciones

@table @code
@item isempty
Retorna 1 para elementos vacios.
@item islogical
Retorna 1 para elementos lógicos.
@item isreal
Retorna 1 para elementos reales.
@item length
Retorna un vector de las longitudes de los elementos de las celdas.
@item ndims
Retorna el número de dimensiones de cada elemento.
@item prodofsize
Retorna el producto de dimensiones de cada elemento.
@item size
Retorna el tama@~{n}o a lo largo de la @var{k}-ésima dimensión.
@item isclass
Retorna 1 para elementos de @var{class}.
@end table

Adicionalmente, @code{cellfun} acepta una función arbitraria @var{func}
en forma de una función en línea, apuntador de función, o el 
nombre de una función (en una cadena de caracteres). En caso de un 
argumento de cadena de caracteres, la función debe aceptar un solo 
argumento llamado @var{x}, y debe retarnar una cadena. La función 
puede tomar uno o más argumentos, con los agumentos de entrada 
dados por @var{c}, @var{d}, etc. Igualmente, la función puede retornar uno o más argumentos de salida. Por ejemplo

@example
@group
cellfun (@@atan2, @{1, 0@}, @{0, 1@})
@result{}ans = [1.57080   0.00000]
@end group
@end example

Nótese que el argumento de salida predeterminado es un arreglo del mismo tama@~{n}o que los argumentos de entrada.

Si el parámetro 'UniformOutput' se establece true (predeterminado), 
la función debe retornar un solo elemento el cual será 
concatenado en el valor retornado. Si 'UniformOutput es false, las  
salidas se concatenan en un arreglo. Por ejemplo

@example
@group
cellfun ("tolower(x)", @{"Foo", "Bar", "FooBar"@},
         "UniformOutput",false)
@result{} ans = @{"foo", "bar", "foobar"@}
@end group
@end example

Dado el parámetro 'ErrorHandler', @var{errfunc} define una función para llamar en caso @var{func} genere un error. La forma de la función es

@example
function [@dots{}] = errfunc (@var{s}, @dots{})
@end example

donde existe un argumento de entrada adicional a @var{errfunc} 
relativo a @var{func}, dado por @var{s}. Esta es una estructura con 
los elementos 'identifier', 'message' e 'index', dando 
respectivamente el identificador del error, el mensaje de error, y 
el índice en los argumentos de entrada del elemento que causó el 
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
