md5="c50b0a3785b756df1fea12afa01378ca";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} range (@var{x})
@deftypefnx {Archivo de función} {} range (@var{x}, @var{dim})
Si @var{x} es un vector, retorna el rango, p.e., la diferencia 
entre el máximo y el mínimo, de los datos de entrada.

Si @var{x} es una matriz, hace lo mismo para cada columna de @var{x}.

Si se suministra el parámetro opcional @var{dim}, realiza esta operación 
a lo largo de la dimesión @var{dim}.
@end deftypefn
