md5="a2c14608227d3a1656b570a6e9ed34ab";rev="6433";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {[@var{ofcn}, @var{odata}] =} input_event_hook (@var{fcn}, @var{data})
Dado el nombre de una funci@'on como una cadena y cualquier valor de objeto 
de Octave, instala @var{fcn} como una funci@'on a llamar peri@'odicamente, 
cuando Octave est@'a esperando por una entrada. La funci@'on deber@'ia tener 
la forma 

@example
@var{fcn} (@var{data})
@end example

Si se omite @var{data}, llama la funci@'on sin argumentos. Si se omiten 
@var{fcn} y @var{data}, limpia el gancho. En todos los casos, retorna el 
nombre de la funci@'on gancho anterior y los datos del usuario.
@end deftypefn
