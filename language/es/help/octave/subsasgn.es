md5="fee8c57360d253536be68b9d3773f17b";rev="6367";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} subsasgn (@var{val}, @var{idx}, @var{rhs})
Realiza la operaci@'on de asignaci@'on de sub@'indice acorde con 
el sub@'indice especificado por @var{idx}. 

Se espera que el sub@'indice @var{idx} sea una estructura de tipo 
arreglo con los campos @samp{type} y @samp{subs}. Los valores 
v@'alidos para @samp{type} son @samp{"()"}, @samp{"@{@}"}, y @samp{"."}. 
El campo @samp{subs} puede ser @samp{":"} o un arreglo de celdas de 
valores de @'indices. 
@seealso{subsref, substruct}
@end deftypefn
