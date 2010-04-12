md5="4cc015293f6eb704edd18bb60d0beb57";rev="6241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {@var{err} =} errno ()
@deftypefnx {Funci@'on incorporada} {@var{err} =} errno (@var{val})
@deftypefnx {Funci@'on incorporada} {@var{err} =} errno (@var{name})
Retorna el valor actual de la variable dependiente del sistema @code{errno}, 
toma su valor de @var{val} y retorna el valor anterior, o retorna 
el c@'odigo de error dado por @var{name} como una cadena de caracteres, o -1
si no se encuentra @var{name}.
@end deftypefn
