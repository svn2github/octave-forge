md5="0f714227a2e76931d67b73006dae6a4c";rev="7228";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} eval (@var{try}, @var{catch})
Analiza la cadena @var{try} y la evalua como si fuera un programa de 
Octave. Si falla, evalua la cadena @var{catch}.
La cadena @var{try} es evaluada en el contexto actual, 
de tal forma que cualquier resultado permanece disponible después 
de que se retorna @code{eval}.
@end deftypefn
