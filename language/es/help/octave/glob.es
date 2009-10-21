md5="058c47d903c24f85a5d71c5ca5172395";rev="6351";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} glob (@var{pattern})
Dado un arrglo de cadenas (como arreglo de caracteres o arreglo de 
celdas) en @var{pattern}, retorna un arreglo de celdas de nombres 
de archivos uqe coinciden con cualquiera de ellos, o una arreglo de 
celdas vacio si ning@'un patron coincide. La expansi@'on de tilde 
es applicada en cada uno de los patrones antes de buscar en los 
nombres de archivo que coinciden. Por ejemplo, 

@example
@group
glob ("/vm*")
     @result{} "/vmlinuz"
@end group
@end example
@seealso{dir, ls, stat, readdir}
@end deftypefn
