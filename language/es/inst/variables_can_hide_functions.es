md5="6a314301c0141c68bae2062b97a435fc";rev="6377";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {@var{val} =} variables_can_hide_functions ()
@deftypefnx {Funci@'on incorporada} {@var{old_val} =} variables_can_hide_functions (@var{new_val})
Consulta o establece el valor de la variable interna que controla
si la asignaci@'on a variables puede ocultar funciones definidas 
previamente del mismo nombre. Si se establece un valor distinto 
de cero, permite oculatar los valores. El valor cero provoca que 
Octave genere un error, y un valor negativo provoca que Octave 
imprima una advertencia, pero permite la operaci@'on.
@end deftypefn
