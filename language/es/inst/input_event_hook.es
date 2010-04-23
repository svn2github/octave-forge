md5="a2c14608227d3a1656b570a6e9ed34ab";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {[@var{ofcn}, @var{odata}] =} input_event_hook (@var{fcn}, @var{data})
Dado el nombre de una función como una cadena y cualquier valor de objeto 
de Octave, instala @var{fcn} como una función a llamar periódicamente, 
cuando Octave está esperando por una entrada. La función debería tener 
la forma 

@example
@var{fcn} (@var{data})
@end example

Si se omite @var{data}, llama la función sin argumentos. Si se omiten 
@var{fcn} y @var{data}, limpia el gancho. En todos los casos, retorna el 
nombre de la función gancho anterior y los datos del usuario.
@end deftypefn
