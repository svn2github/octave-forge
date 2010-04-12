md5="faa0d462db8ef857a8a0c27e7ab2ec9c";rev="6351";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} subsref (@var{val}, @var{idx})
Realiza la operaci@'on de selecci@'on de elementos con sub@'indices 
acorde con el sub@'indice especificado en @var{idx}.

Se espera que el sub@'indice @var{idx} sea una estructura arreglo 
con los campos @samp{type} y @samp{subs}. Los valores v@'alidos para 
@samp{type} son @samp{"()"}, @samp{"@{@}", and @samp{"."}. El campo 
@samp{subs} puede ser @samp{":"} o un arreglo de celdas de valores 
de @'indices.
@seealso{subsasgn, substruct}
@end deftypefn
