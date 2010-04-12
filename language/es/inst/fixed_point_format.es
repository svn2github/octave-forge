md5="c165ffaa5bff156fabd2e1f12b9c8497";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {@var{val} =} fixed_point_format ()
@deftypefnx {Funci@'on incorporada} {@var{old_val} =} fixed_point_format (@var{new_val})
Consulta o establece la variable interna que controla si Octave usar@'a 
un formato a escala para imprimir valores de matrices tales que el 
elemento m@'as grande pueda ser escrito como un @'unico d@'igito con el 
factor de escala en frente de la primera l@'inea de salida. Por ejemplo, 

@example
@group
octave:1> logspace (1, 7, 5)'
ans =

  1.0e+07  *

  0.00000
  0.00003
  0.00100
  0.03162
  1.00000
@end group
@end example

@noindent
N@'otese que el primer valor aparece como cero cuando es realmente 1. Por 
esta raz@'on, se debe prestar atenci@'on cuando se va cambiar 
@code{fixed_point_format} por un valor distinto de cero.
@end deftypefn
