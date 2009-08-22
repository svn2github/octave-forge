md5="0f714227a2e76931d67b73006dae6a4c";rev="6128";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} eval (@var{try}, @var{catch})
Analiza la cadena @var{try} y la evalua como si fuera un programa de 
Octave. Si falla, evalua la cadena @var{catch}.
La cadena @var{try} es evaluada en el contexto actual, 
de tal forma que cualquier resultado permanece disponible despu@'es 
de que se retorna @code{eval}.
@end deftypefn
