md5="f361cd56df93c53e710e418ee1d29aca";rev="6315";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} pause (@var{seconds})
Suspende la ejecuci@'on del programa. Si se invoca sin argumentos, 
Octave espera hasta que se digita un caracter. Con un argumento num@'erico, 
detiene la ejecuci@'on por @var{seconds} segundos. Por ejemplo, la siguiente 
sentencia imprime un mensaje y luego espera 5 segundos antes de limpiar la 
pantalla.

@example
@group
fprintf (stderr, "Por favor espere...");
pause (5);
clc;
@end group
@end example
@end deftypefn
