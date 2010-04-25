md5="a6280a0d26fa31b7c4000f8466c7c062";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {@var{p} =} sprank (@var{s})
@cindex Rango estructural 
Calcula el rando estructural de la matriz dispersa @var{s}. Nótese 
que solo se usa la estructura de la matriz en este cálculo basado en 
la forma triangular de Dulmage-Mendelsohn. De tal forma que el rango 
numérico de la matriz @var{s} está acotado por @code{sprank (@var{s}) >=
rank (@var{s})}. Ignorando errores de punto flotante @code{sprank (@var{s}) ==
rank (@var{s})}.
@seealso{dmperm}
@end deftypefn
