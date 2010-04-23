md5="58f8633024b11daa2fa8e5e9ac546f4d";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} fdisp (@var{fid}, @var{x})
Muestra el valor de @var{x} en @var{fid}. Por ejemplo, 

@example
fdisp (stdout, "El valor de pi es:"), fdisp (stdout, pi)

     @print{} El valor de pi es:
     @print{} 3.1416
@end example

@noindent
Nótese que la salida de @code{fdisp} siempre finaliza con una línea nueva.
@seealso{disp}
@end deftypefn
