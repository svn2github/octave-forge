md5="851aeda382fd323cce6c0bb3eef5a2b6";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deffn {Comando} format options
Reicicia o especifica el formato de salida producido por @code{disp}
y Octave.  Este comando solo afecta la representación de números
pero no como son almacenas o calculados, para cambiar la representación
interna, el valor por defecto es double utilice una de las funciones de
converción como @code{single}, @code{uint8},@code{int64} etcétera.

Por defecto, Octave muestra 5 cifras significativas en una forma legible
(opción @code{short} paridad con @code{loose} formato para matrices).
Si @code{format} es invocado sin ninguna opción, el formato es
restaurado al valor predeterminado.

Los formatos validos para los números de decimales son puestos en una
lista en la siguiente tabla.

@table @code
@item short
Ajusta el punto con 5 cifras significativas  en un campo máximo de
10 caracteres, (predetermindo).

Si Octave no consigue establecer una matriz en que las columnas se
ajusten al punto decimal y todos los números queden dentro del ancho
del campo máximo, el cambia a un formato exponecial @samp{e}.

@item long
Ajusta el punto con 15 cifras significativas  en un campo máximo de
20 caracteres.

Igual que el fotmato @samp{short}, Octave cambiará a un formato
exponencial @samp{e} si no consigue establecer una matriz apropiadamente
usando el formato actual.

@item long e
@itemx short e
Formato exponencial. El número que se representa se divide entre
una mantisa y un exponente (elevado a la 10). La mantisa tiene 5 cifras
significativas en @samp{format short} y 15 cifras en el
@samp{format long}. Por ejemplo, con el formato @samp{short e},
@code{pi} es mostrado como @code{3.1416e+00}.

@item long E
@itemx short E
Identico a @samp{format long e} o @samp{format short e} pero muestra
la salida con la @samp{E} mayúscula. Por ejemplo, con el formato
@samp{long E}, @code{pi} se muestra como @code{3.14159265358979E+00}.

@item long g
@itemx short g
Elege de forma óptima entre el punto fijo y el formato exponencial
basado en la magnitud del número. Por ejemplo, con el formato
@samp{short g}, @code{pi .^ [2; 4; 8; 16; 32]} es mostrado como

@example
@group
ans =

      3.1416
      9.8696
      97.409
      9488.5
  9.0032e+07
  8.1058e+15
@end group
@end example

@item long G
@itemx short G
Identico a @samp{format long g} o @samp{format short g} pero usa una
@samp{E} mayuscula para indicar el exponente. por ejemplo, con el formato
@samp{short G}, @code{pi .^ [2; 4; 8; 16; 32]} es mostrado como

@example
@group
ans =

      3.1416
      9.8696
      97.409
      9488.5
  9.0032E+07
  8.1058E+15
@end group
@end example

@item free
@itemx none
la salida de impresión en formato free, No intenta alinear las
columnas de las matrices en el punto decimal. Esto también hace
que los números complejos esten formateados de este modo
@samp{(0.604194,0.607088)} en lugar de este @samp{0.60419 + 0.60709i}.

Los siguientes formatos afectan todas salidas numericas (decimales y
enteros).

@item +
@itemx + @var{chars}
@itemx plus
@itemx plus @var{chars}
Imprimie el símbolo @samp{+} para los elementos de matriz no nulos y un
espacio para los elementos de la matriz que son cero. Este formato puede
ser muy útil para examinar la estructura de una matriz de gran
tamaño.

El argumento opcional @var{chars} especifica una lista de 3 caracteres
que se utilizan en los valores de impresión mayor que cero, menor que
cero e igual a cero. Por ejemplo, con el formato @samp{+ "+-."},
@code{[1, 0, -1; -1, 0, 1]} se muestra como

@example
@group
ans =

+.-
-.+
@end group
@end example

@item bank
Imprime en un formato fijo con dos espacios a la derecha del punto
decimal.

@itemx native-hex
Imprime los números en la representación hexadecimal ya que se
almacenan en memoria. Por ejemplo, en una estación de trabajo que
almacena los valores de 8 byte reales en formato IEEE con el byte
menos significativo en primer lugar, el valor de @code{pi} cuando se
imprime en formato @code{hex}() es @code{400921fb54442d18}.
Este formato sólo funciona para los valores numéricos.

@item hex
Identico a @code{native-hex}, pero siempre imprime el byte más
significativo primero.

@item native-bit
Imprime los números en la representación binaria ya que se
almacenan en memoria. Por ejemplo, el valor de @code{pi} es

@example
@group
01000000000010010010000111111011
01010100010001000010110100011000
@end group
@end example
(se muestra aquí en dos secciones de 32 bits para fines de 
composición tipográfica), cuando imprimá en formato  native-bit
en una estación de trabajo que almacena 8 valores de byte reales en 
formato IEEE con el byte menos significativo en primer lugar. Este 
formato sólo funciona para los tipos numéricos.

@item bit
Identico a @code{native-bit}, pero siempre imprime los bits más 
significativos primero.

@item compact
Elimina el espacio en blanco adicional en torno a las etiquetas de 
número de la columna.
@item loose
Insertar líneas en blanco por encima y por debajo de las etiquetas de
número de la columna (esta es la opcio@'n predeterminada).
@end table
@end deffn