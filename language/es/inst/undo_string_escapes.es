md5="caeab413a545d3ef868db8cdc9b95901";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} undo_string_escapes (@var{s})
Convierte caracteres especiales de vuelta en cadenas a sus formas de
escape. Por ejemplo, la expresión

@example
bell = "\a";
@end example

@noindent
asigna el valor del carácter de alerta (control-g, código ASCII 7)
a la variable de cadena @code{bell}. Si se imprime esta cadena, el sistema
hará sonar la campana de la terminal (si es posible). Este es 
normalmente el resultado deseado. Sin embargo, a veces es útil ser capaz
de imprimir la representación original de la cadena, con los caracteres
especiales reemplazados por sus secuencias de escape. Por ejemplo,

@example
octave:13> undo_string_escapes (bell)
ans = \a
@end example

@noindent
sustituye el carácter de alerta no imprimibles con su representación
imprimible.
@end deftypefn