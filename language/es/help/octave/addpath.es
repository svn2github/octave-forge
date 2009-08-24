md5="eb41a858ad6b637cc1c45c3fc487a0d5";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} addpath (@var{dir1}, @dots{})
@deftypefnx {Archivo de funci@'on} {} addpath (@var{dir1}, @dots{}, @var{option})
Agregue @var{dir1}, @dots{} a la ruta actual de la funci@'on de b@'usqueda. Si
@var{option} es @samp{"-begin"} o 0 (el predeterminado), anteponga el nombre 
del directorio a la ruta actual. Si @var{option} es @samp{"-end"}
o 1, anteponga el nombre del directorio a la ruta actual.

Los directorios añadido a la ruta de acceso deben existir.

@seealso{path, rmpath, genpath, pathdef, savepath, pathsep}
@end deftypefn
