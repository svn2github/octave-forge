md5="cc183a9d23ee37c8e77ef7eb1090c352";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} sysout (@var{sys}, @var{opt})
Imprime la estructura de datos del sistema en el formato deseado
@table @var
@item  sys
Estructura de datos del sistema 
@item  opt
Opción de visualización 
@table @code
@item []
Formato primario del sistema (predeterminado)
@item      "ss"
Formato de espacio de estados 
@item      "tf"
Formato de función de transferencia 
@item      "zp"
Formato de polos y ceros 
@item      "all"
Todos los anteriores 
@end table
@end table
@end deftypefn
