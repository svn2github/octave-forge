md5="d4345c1e950536966db75d316fcdf3d4";rev="7332";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {[@var{val}, @var{count}] =} fread (@var{fid}, @var{size}, @var{precision}, @var{skip}, @var{arch})
leer datos binarios de tipo @var{precision} del especificado ID de archivo 
@var{fid}.

El argumento opcional @var{size} especifica la cantidad de datos para leer
y puede ser uno de 

@table @code
@item Inf
Lea tanto como sea posible, devolver un vector columna.

@item @var{nr}
Lee hasta @var{nr} elementos, devolviendo un vector columna.

@item [@var{nr}, Inf]
Lea tanto como sea posible, devolver una matriz con @var{nr} filas. Si el 
número de elementos de lectura no es un múltiplo exacto de @var{nr}, la 
última columna se rellena con ceros.

@item [@var{nr}, @var{nc}]
Lee hasta @code{@var{nr} * @var{nc}} elementos, retorna una matriz con 
@var{nr} filas. Si el número de elementos de lectura no es un múltiplo
exacto de @var{nr}, la última columna se rellena con ceros.
@end table

@noindent
Si @var{size} es omitida, un valor de @code{Inf} es asumido.

El argumento opcional @var{precision} es una cadena especificando el tipo
de datos a leer y puede ser uno de 

@table @code
@item "schar"
@itemx "signed char"
carácter con signo.

@item "uchar"
@itemx "unsigned char"
carácter sin signo.

@item "int8"
@itemx "integer*1"
entero de 8-bits con signo.

@item "int16"
@itemx "integer*2"
entero de 16-bits con signo.

@item "int32"
@itemx "integer*4"
entero de 32-bits con signo.

@item "int64"
@itemx "integer*8"
entero de 64-bits con signo.

@item "uint8"
entero de 8-bit sin signo

@item "uint16"
entero de 16-bit sin signo

@item "uint32"
entero de 32-bit sin signo

@item "uint64"
entero de 64-bit sin signo

@item "single"
@itemx "float32"
@itemx "real*4"
número de punto flotante de 32 bits.

@item "double"
@itemx "float64"
@itemx "real*8"
número de punto flotante de 64 bits.

@item "char"
@itemx "char*1"
carácter sencillo.

@item "short"
entero corto (el tamaño depende de la plataforma).

@item "int"
Entero (tamaño depende de la plataforma).

@item "long"
Entero largo (tamaño depende de la plataforma).

@item "ushort"
@itemx "unsigned short"
Entero corto sin signo (tamaño depende de la plataforma).

@item "uint"
@itemx "unsigned int"
Entero sin signo (tamaño depende de la plataforma).

@item "ulong"
@itemx "unsigned long"
Entero largo sin signo (tamaño depende de la plataforma).

@item "float"
precisión simple número de punto flotante (tamaño depende de la 
plataforma).
@end table

@noindent
La precisión predeterminada es @code{"uchar"}.

El argumento @var{precision} también puede especificar un número de
repeticiones opcionales. Por ejemplo, @samp{32*single} causa @code{fread}
para leer un bloque de 32 con precisión simple de números de punto
flotante. La lectura en bloques es útil en combinación con el argumento
@var{skip}.

El argumento @var{precision} también puede especificar una conversión
de tipos. Por ejemplo, @samp{int16=>int32} causa @code{fread} para leer
los valores de 16-bit enteros y devolver una matriz de valores enteros
de 32-bit. De forma predeterminada, @code{fread} devuelve una matriz de
doble precisión. La forma especial @samp{*TYPE} es la abreviatura de 
@samp{TYPE=>TYPE}.

La conversión y la cuenta de repeticiónes pueden ser combinadas. Por 
ejemplo, la especificación @samp{32*single=>single} causa @code{fread}
para leer bloques de precisión única con valores de punto flotante y
devolver una matriz de valores de precisión simple en lugar de la matriz
por defecto de valores de precisión doble.

El argumento opcional @var{skip} especifica el número de bytes a saltar
después de cada elemento (o bloque de elementos) que se lee. Si no se 
especifica un valor se asume 0. Si el último bloque de lectura no esta
completo, el salto final se omite. Por ejemplo,

@example
fread (f, 10, "3*single=>single", 8)
@end example

@noindent
se omite el pase final 8-byte, porque la última lectura no será un 
bloque completo de 3 valores.

El argumento opcional @var{arch} es una cadena que especifica el formato
de datos para el archivo. Los valores válidos son

@table @coden
@item "native"
El formato de la máquina actual.
@item "ieee-be"
IEEE big-endian.

@item "ieee-le"
IEEE little endian.

@item "vaxd"
VAX D formato flotante.

@item "vaxg"
VAX G formato flotante.

@item "cray"
formato flotante Cray.
@end table

@noindent
Las conversiones en la actualidad sólo se admiten para @code{"ieee-be"} y
formatos @code{"ieee-le"}.

Los datos leídos desde el archivo se devuelve en @var{val}, y el número
de valores leídos se devuelve en @code{count}
@seealso{fwrite, fopen, fclose}
@end deftypefn