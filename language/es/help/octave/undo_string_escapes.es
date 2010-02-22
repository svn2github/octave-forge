md5="caeab413a545d3ef868db8cdc9b95901";rev="6944";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} undo_string_escapes (@var{s})
Convierte caracteres especiales de vuelta en cadenas a sus formas de
escape. Por ejemplo, la expresi@'on

@example
bell = "\a";
@end example

@noindent
asigna el valor del car@'acter de alerta (control-g, c@'odigo ASCII 7)
a la variable de cadena @code{bell}. Si se imprime esta cadena, el sistema
har@'a sonar la campana de la terminal (si es posible). Este es 
normalmente el resultado deseado. Sin embargo, a veces es @'util ser capaz
de imprimir la representaci@'on original de la cadena, con los caracteres
especiales reemplazados por sus secuencias de escape. Por ejemplo,

@example
octave:13> undo_string_escapes (bell)
ans = \a
@end example

@noindent
sustituye el car@'acter de alerta no imprimibles con su representaci@'on
imprimible.
@end deftypefn