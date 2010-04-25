md5="edb6932d7a945dc99302439eeb93cdcf";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} qcoordinate_plot (@var{qf}, @var{qb}, @var{qv})
Grafica en la figura actual un conjunto de ejes de coordenadas visto desde 
la orientación especificada por el cuaternion @var{qv}. Los ejes inerciales también 
son graficados:

@table @var
@item qf
Cuaternion de referencia (x,y,z) al inercial.
@item qb
Cuaternion de referencia al cuerpo.
@item qv
Cuaternion de referencia a la vista de ángulo.
@end table
@end deftypefn
