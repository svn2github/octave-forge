md5="2e0125cd9d924824a81eb4410158957e";rev="6381";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {@var{val} =} string_fill_char ()
@deftypefnx {Funci@'on incorporada} {@var{old_val} =} string_fill_char (@var{new_val})
Consulta o establece el valor de la variable interna usada como 
caracter para completar todas las filas de una matriz de caracteres 
para que todas las filas tengan la misma longitud. Debe ser un @'unico 
caracter. El valor predeterminado es @code{" "} (un espacio sencillo). 
Por ejemplo, 

@example
@group
string_fill_char ("X");
[ "these"; "are"; "strings" ]
     @result{} "theseXX"
        "areXXXX"
        "strings"
@end group
@end example
@end deftypefn
