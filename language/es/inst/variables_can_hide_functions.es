md5="6a314301c0141c68bae2062b97a435fc";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {@var{val} =} variables_can_hide_functions ()
@deftypefnx {Función incorporada} {@var{old_val} =} variables_can_hide_functions (@var{new_val})
Consulta o establece el valor de la variable interna que controla
si la asignación a variables puede ocultar funciones definidas 
previamente del mismo nombre. Si se establece un valor distinto 
de cero, permite oculatar los valores. El valor cero provoca que 
Octave genere un error, y un valor negativo provoca que Octave 
imprima una advertencia, pero permite la operación.
@end deftypefn
