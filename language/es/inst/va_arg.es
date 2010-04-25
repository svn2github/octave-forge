md5="d8025c7094c863c3a353ea8490b6adf5";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} va_arg ()
Retorna el valor del siguiente argumento disponible y mueve el 
apuntador interno al siguiente argumento. Es un error llamar 
@code{va_arg} cuando no hay más argumentos disponibles, o en 
una función que no ha sido declarada para tomar un número 
variable de parámetros. 
@end deftypefn
