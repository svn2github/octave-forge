md5="cc0e46f9349460daee446b0aee7dc8c9";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{c}, @var{maxsize}, @var{endian}] =} computer ()
Imprime o retorna una cadena de la forma @var{cpu}-@var{vendor}-@var{os}
que identifica el tipo de PC donde Octave está siendo ejecutado. Si se 
invoca con un argumento de salida, el valor se retorna en lugar de imprimirse. Por ejemplo,

@example
@group
computer ()
@print{} i586-pc-linux-gnu

x = computer ()
@result{} x = "i586-pc-linux-gnu"
@end group
@end example

Si se solicitan dos argumentos, también retorna el número máximo de elementos del arreglo.

Si se solicitan tres argumentos, también retorna el tipo ordenamiento de byte del sistema actual como un caracter (@code{"B"} para big-endian o
@code{"L"} para little-endian).
@end deftypefn
