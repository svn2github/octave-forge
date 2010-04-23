md5="327ddad2b90f8b1685e49b13c801b718";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{str} =} datestr (@var{date}, [@var{f}, [@var{p}]])
Cambia el formato de la fecha/hora de acuerdo con el formato @code{f} y retorna 
el resultado en @var{str}. @var{date} es número de fecha serial (véase 
@code{datenum}) o un vector de fecha (véase @code{datevec}). El valor de 
@var{date} puede ser una cadena o un arreglo de celdas de cadenas.

El parámetro @var{f} puede ser un entero el cual corresponde con uno de los 
códigos en la tabla a continuación, o una cadena de formato de fecha.

El parámetro @var{p} es el a@~{n}o del siglo inicial en el cual los dos 
dígitos del a@~{n}o serán interpretados. Si no se especifica, el valor 
predeterminado es el a@~{n}o actual menos 50.

Por ejemplo, el formato de la fecha 730736.65149 (2000-09-07 15:38:09.0934) 
será modificado de la siguiente forma:

@multitable @columnfractions 0.1 0.45 0.35
@headitem Código @tab Formato @tab Ejemplo
@item  0 @tab dd-mmm-yyyy HH:MM:SS   @tab 07-Sep-2000 15:38:09
@item  1 @tab dd-mmm-yyyy            @tab 07-Sep-2000
@item  2 @tab mm/dd/yy               @tab 09/07/00
@item  3 @tab mmm                    @tab Sep
@item  4 @tab m                      @tab S
@item  5 @tab mm                     @tab 09
@item  6 @tab mm/dd                  @tab 09/07
@item  7 @tab dd                     @tab 07
@item  8 @tab ddd                    @tab Thu
@item  9 @tab d                      @tab T
@item 10 @tab yyyy                   @tab 2000
@item 11 @tab yy                     @tab 00
@item 12 @tab mmmyy                  @tab Sep00
@item 13 @tab HH:MM:SS               @tab 15:38:09
@item 14 @tab HH:MM:SS PM            @tab 03:38:09 PM
@item 15 @tab HH:MM                  @tab 15:38
@item 16 @tab HH:MM PM               @tab 03:38 PM
@item 17 @tab QQ-YY                  @tab Q3-00
@item 18 @tab QQ                     @tab Q3
@item 19 @tab dd/mm                  @tab 13/03
@item 20 @tab dd/mm/yy               @tab 13/03/95
@item 21 @tab mmm.dd.yyyy HH:MM:SS   @tab Mar.03.1962 13:53:06
@item 22 @tab mmm.dd.yyyy            @tab Mar.03.1962
@item 23 @tab mm/dd/yyyy             @tab 03/13/1962
@item 24 @tab dd/mm/yyyy             @tab 12/03/1962
@item 25 @tab yy/mm/dd               @tab 95/03/13
@item 26 @tab yyyy/mm/dd             @tab 1995/03/13
@item 27 @tab QQ-YYYY                @tab Q4-2132
@item 28 @tab mmmyyyy                @tab Mar2047
@item 29 @tab yyyymmdd               @tab 20470313
@item 30 @tab yyyymmddTHHMMSS        @tab 20470313T132603
@item 31 @tab yyyy-mm-dd HH:MM:SS    @tab 1047-03-13 13:26:03
@end multitable

Si @var{f} es una cadena de formato, se reconocen los siguientes símbolos:

@multitable @columnfractions 0.1 0.7 0.2
@headitem Símbolo @tab Descripción @tab Ejemplo
@item yyyy @tab A@~{n}o completo                             @tab 2005
@item yy   @tab A@~{n}o con dos dígitos                    @tab 05
@item mmmm @tab Nombre del mes completo                      @tab December
@item mmm  @tab Nombre del mes abreviado                     @tab Dec
@item mm   @tab Número del mes (con ceros)                 @tab 01, 08, 12
@item m    @tab Primera letra del nombre del mes (mayús.)  @tab D
@item dddd @tab Nombre del día completo                    @tab Sunday
@item ddd  @tab Nombre del día abreviado                   @tab Sun
@item dd   @tab Número del día del mes (con ceros)       @tab 11
@item d    @tab Primera letra del nombre del día (mayús.)@tab S
@item HH   @tab Hora del día, con ceros si está en PM    @tab 09:00
@item      @tab y sin ceros en otro caso                     @tab 9:00 AM
@item MM   @tab Minuto de la hora (con ceros)                @tab 10:05
@item SS   @tab Secondo del minuto (con ceros)               @tab 10:05:03
@item PM   @tab Usar formato de 12 horas                     @tab 11:30 PM
@end multitable

Si no se especifica @var{f} o es @code{-1}, usa 0, 1 o 16,
dependiendo en si la porción de la fecha o la porción de la hora de 
@var{date} está vacia.

Si no se especifica @var{p}, se inicializa con el a@~{n}o actual menos 50.

Si se da una matriz o un arreglo de celdas de fechas, se retorna un vector de 
cadenas de fechas.

@seealso{datenum, datevec, date, clock, now, datetick}
@end deftypefn
