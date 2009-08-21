md5="4ef505a06bbfaaa5ecf69f0298e30c23";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} disp (@var{x})
Muestra el valor de @var{x}. Por ejemplo,

@example
disp ("El valor de pi es:"), disp (pi)

     @print{} El valor de pi es:
     @print{} 3.1416
@end example

@noindent
N@'otese que la salida de @code{disp} siempre finaliza con una l@'inea nueva.

Si se solicita un valor de salida, @code{disp} no imprime nada y
retorna la salida con formato en una cadena.
@seealso{fdisp}
@end deftypefn
