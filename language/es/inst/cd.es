md5="c9ecbcadb72f75f3d276dd642f5a3124";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deffn {Comando} cd dir
@deffnx {Comando} chdir dir
Cambia el directorio de trabajo actual a @var{dir}. Si @var{dir} se 
omite, el directorio actual se cambia por el directorio de usuario. 
Por ejemplo,

@example
cd ~/octave
@end example

@noindent
Cambia el directorio de trabajo actual a @file{~/octave}. Si el
directorio no existe, se muestra un mensaje de error y no se cambia el
directorio de trabajo.
@seealso{mkdir, rmdir, dir}
@end deffn
