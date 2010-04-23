md5="8dbbf0a2ddc3b9f21addebfeaa2dc4c5";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{status}, @var{msg}, @var{msgid}] =} fileattrib (@var{file})
Retorna la información acerca del archivo @var{file}. 

Si la ejecución es exitosa, @var{status} es 1, en donde @var{result} 
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
True Si el usuario (grupo; otros usuarios) tiene permiso de ejecución 
sobre @var{file}.
@end table
Si un atributo no aplica (p.e., el archivo permtenece a un sistema Unix), 
entonces se asigna NaN al campo. 

Sin argumentos de entrada, retorna la información acerca del directorio 
actual. 

Si @var{file} contiene comodines, retorna la información acerca de todos 
los archivos que coinciden.
@seealso{glob}
@end deftypefn
