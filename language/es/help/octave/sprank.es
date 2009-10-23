md5="a6280a0d26fa31b7c4000f8466c7c062";rev="6367";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {@var{p} =} sprank (@var{s})
@cindex Rango estructural 
Calcula el rando estructural de la matriz dispersa @var{s}. N@'otese 
que solo se usa la estructura de la matriz en este c@'alculo basado en 
la forma triangular de Dulmage-Mendelsohn. De tal forma que el rango 
num@'erico de la matriz @var{s} est@'a acotado por @code{sprank (@var{s}) >=
rank (@var{s})}. Ignorando errores de punto flotante @code{sprank (@var{s}) ==
rank (@var{s})}.
@seealso{dmperm}
@end deftypefn
