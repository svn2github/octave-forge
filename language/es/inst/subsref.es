md5="faa0d462db8ef857a8a0c27e7ab2ec9c";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} subsref (@var{val}, @var{idx})
Realiza la operación de selección de elementos con subíndices 
acorde con el subíndice especificado en @var{idx}.

Se espera que el subíndice @var{idx} sea una estructura arreglo 
con los campos @samp{type} y @samp{subs}. Los valores válidos para 
@samp{type} son @samp{"()"}, @samp{"@{@}", and @samp{"."}. El campo 
@samp{subs} puede ser @samp{":"} o un arreglo de celdas de valores 
de índices.
@seealso{subsasgn, substruct}
@end deftypefn
