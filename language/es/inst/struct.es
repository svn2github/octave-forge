md5="1f891358f7415a7c12af7f6297219359";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} struct ("field", @var{value}, "field", @var{value}, @dots{})
Crea una estructura e inicializa su valor.

Si los valores son arreglos de celdas, crea una estructura arreglo e 
inicializa sus valores. Las dimensiones de cada celda del arreglo deben 
coincidir. Celdas singleton y valores distintos a celdas son repetidos 
de tal forma que completan el arreglo por completo. Si las celdas están 
vacias, crea una estructura arreglo vacia con los nombres de campos 
especificados.
@end deftypefn
