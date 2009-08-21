md5="f7034f57c37a9e5b02f462152bd816b5";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Variable incorporada} {@var{val} =} default_save_options ()
@deftypefnx {Variable incorporada} {@var{old_val} =} default_save_options (@var{new_val})
Consulta o establece la variable interna que especifica las opciones predeterminadas 
para el comando @code{save}, y define el formato predetermiando.
Valores t@'ipicos incluyen @code{"-ascii"}, @code{"-ascii -zip"}.
El valor predetermiando es @code{-ascii}.
@seealso{save}
@end deftypefn
