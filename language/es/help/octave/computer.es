md5="cc0e46f9349460daee446b0aee7dc8c9";rev="5942";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{c}, @var{maxsize}, @var{endian}] =} computer ()
Imprime o retorna una cadena de la forma @var{cpu}-@var{vendor}-@var{os}
que identifica el tipo de PC donde Octave est@'a siendo ejecutado. Si se 
invoca con un argumento de salida, el valor se retorna en lugar de imprimirse. Por ejemplo,

@example
@group
computer ()
@print{} i586-pc-linux-gnu

x = computer ()
@result{} x = "i586-pc-linux-gnu"
@end group
@end example

Si se solicitan dos argumentos, tambi@'en retorna el n@'umero m@'aximo de elementos del arreglo.

Si se solicitan tres argumentos, tambi@'en retorna el tipo ordenamiento de byte del sistema actual como un caracter (@code{"B"} para big-endian o
@code{"L"} para little-endian).
@end deftypefn
