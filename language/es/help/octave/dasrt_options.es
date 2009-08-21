md5="db94c5decab67524642c47f0b13c66ec";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} dasrt_options (@var{opt}, @var{val})
Cuando es invocada con dos argumentos, esta funci@'on 
permite establecer los par@'ametros de la funci@'on @code{dasrt}.
Dado un argumento, @code{dasrt_options} retorna el valor de la 
opci@'on correspondiente. Si no se suministran argumentos, se muestran 
todos los nombres de las opciones disponibles y sus valores actuales.

Las opciones incluyen 

@table @code
@item "absolute tolerance"
Tolerancia absoluta. Puede ser vector o escalar. Si es un vector, debe 
coincidir con las dimensiones del vector de estados, y la tolerancia 
relativa debe ser tambi@'en un vector de la misma longitud.
@item "relative tolerance"
Tolerancia relativa. Puede ser vector o escalar. Si es un vector, debe 
coincidir con las dimensiones del vector de estados, y la tolerancia 
absoluta debe ser tambi@'en un vector de la misma longitud.

La prueba de error local aplicado en cada paso de integraci@'on es 
@example
  abs (local error in x(i)) <= ...
      rtol(i) * abs (Y(i)) + atol(i)
@end example
@item "initial step size"
Los problemas algebraico-diferenciales pueden sufrir de dificultades 
severas de escalamiento en el primer paso. Si usted sabe acerca de 
dificultades de escalamiento en su problema, es posible aliviar esta 
situaci@'on especificando la longitud del paso inicial.
@item "maximum order"
Restringe el orden m@'aximo del m@'etodo de soluci@'on. Esta opci@'on debe estar 
entre 1 y 5.
@item "maximum step size"
Ajustando la longitud m@'axima del paso se evitar@'a pasar sobre 
regiones grandes.
@item "step limit"
N@'umero m@'aximo de pasos de integraci@'on a intentar en un llamado 
sencillo al c@'odigo Fortran subyascente.
@end table
@end deftypefn
