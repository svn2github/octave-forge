md5="2ea0435d89b80f4d941f27d805d01afd";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} strrep (@var{s}, @var{x}, @var{y})
Reemplaza todas las ocurrencias de la subcadena @var{x} de la cadena @var{s} 
con la cadena @var{y}. Por ejemplo, 

@example
strrep ("This is a test string", "is", "&%$")
@result{} "Th&%$ &%$ a test string"
@end example
@end deftypefn
