md5="310973415530efaa490f2b59b633552a";rev="6461";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} localtime (@var{t})
Dado un valor retornado por @code{time} (o cualquier entero no negativo), 
retorna una estructuta de tiempo correspondiente a la hora local. 

@example
@group
localtime (time ())
     @result{} @{
           usec = 0
           year = 97
           mon = 1
           mday = 17
           sec = 6
           zone = CST
           min = 15
           wday = 1
           hour = 1
           isdst = 0
           yday = 47
         @}
@end group
@end example
@seealso{strftime, strptime, gmtime, mktime, time, now, date, clock, datenum, datestr, datevec, calendar, weekday}
@end deftypefn
