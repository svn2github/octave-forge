md5="1662d299cb49caa211b0c22bffa722e1";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} tilde_expand (@var{string})
Realiza la expansi@'on de tilde en @var{string}. Si @var{string} comienza
con un car@'acter de tilde, (@samp{~}), todos los car@'acteres precedentes
a el primer slash(o todos los caracteres, si no hay slash) son tratados 
como un pos@'ible nombre de usuario, y la tilde y los siguientes caracteres
hasta la barra se sustituyen por el directorio ra@'iz del usuario llamado.
Si la tilde es seguida inmediatamente por un slash, la tilde es remplazada
por el directorio ra@'iz del usuario que ejecuta Octave. Por ejemplo,

@example
@group
tilde_expand ("~joeuser/bin")
     @result{} "/home/joeuser/bin"
tilde_expand ("~/bin")
     @result{} "/home/jwe/bin"
@end group
@end example
@end deftypefn
