md5="fee8c57360d253536be68b9d3773f17b";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} subsasgn (@var{val}, @var{idx}, @var{rhs})
Realiza la operación de asignación de subíndice acorde con 
el subíndice especificado por @var{idx}. 

Se espera que el subíndice @var{idx} sea una estructura de tipo 
arreglo con los campos @samp{type} y @samp{subs}. Los valores 
válidos para @samp{type} son @samp{"()"}, @samp{"@{@}"}, y @samp{"."}. 
El campo @samp{subs} puede ser @samp{":"} o un arreglo de celdas de 
valores de índices. 
@seealso{subsref, substruct}
@end deftypefn
