md5="fdaa5eb73fd60f52ae0495e950f9a2d1";rev="6420";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {[@var{tm_struct}, @var{nchars}] =} strptime (@var{str}, @var{fmt})
Convierte la cadena @var{str} en la estructura de tiempo @var{tm_struct} 
bajo el control de la cadena de formato @var{fmt}. 

Si @var{fmt} no coincide, la variable @var{nchars} es 0; en otro caso, se 
asigna el valor de la @'ultima posici@'on que coincid@'io m@'as 1. 

Es recomendable verificar el valor del @'indice a menos que est@'e 
absolutamente seguro de que la cadena ser@'a analizada correctamente. 
@seealso{strftime, localtime, gmtime, mktime, time, now, date, clock, datenum, datestr, datevec, calendar, weekday}
@end deftypefn
