md5="6f9687bc13d079fb30c6a0b09360ba53";rev="6315";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {@var{val} =} print_empty_dimensions ()
@deftypefnx {Funci@'on incorporada} {@var{old_val} =} print_empty_dimensions (@var{new_val})
Consulta o establece el valor de la variable interna que controla si 
se imprimen las dimensiones de las matrices vacias junto con el s@'imbolo 
de matriz vacia, @samp{[]}. Por ejemplo, la expresi@'on 

@example
zeros (3, 0)
@end example

@noindent
muestra 

@example
ans = [](3x0)
@end example
@end deftypefn
