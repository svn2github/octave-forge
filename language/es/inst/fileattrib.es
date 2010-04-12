md5="8dbbf0a2ddc3b9f21addebfeaa2dc4c5";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{status}, @var{msg}, @var{msgid}] =} fileattrib (@var{file})
Retorna la informaci@'on acerca del archivo @var{file}. 

Si la ejecuci@'on es exitosa, @var{status} es 1, en donde @var{result} 
contiene un estructura con los siguientes campos: 

@table @code
@item Name
Nombre completo de @var{file}.
@item archive
True si @var{file} es un archivo (Windows).
@item system
True si @var{file} es un archivo del sistema (Windows).
@item hidden
True si @var{file} es un archivo oculto (Windows).
@item directory
True si @var{file} es un directorio.
@item UserRead
@itemx GroupRead
@itemx OtherRead
True si el usuario (grupo; otros usuarios) tiene permiso de lectura 
sobre @var{file}.
@item UserWrite
@itemx GroupWrite
@itemx OtherWrite
True si el usuario (grupo; otros usuarios) tiene permiso de escritura 
sobre @var{file}.
@item UserExecute
@itemx GroupExecute
@itemx OtherExecute
True Si el usuario (grupo; otros usuarios) tiene permiso de ejecuci@'on 
sobre @var{file}.
@end table
Si un atributo no aplica (p.e., el archivo permtenece a un sistema Unix), 
entonces se asigna NaN al campo. 

Sin argumentos de entrada, retorna la informaci@'on acerca del directorio 
actual. 

Si @var{file} contiene comodines, retorna la informaci@'on acerca de todos 
los archivos que coinciden.
@seealso{glob}
@end deftypefn
