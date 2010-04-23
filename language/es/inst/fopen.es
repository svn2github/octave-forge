md5="540013b3db584e4396e7642709f88914";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {[@var{fid}, @var{msg}] =} fopen (@var{name}, @var{mode}, @var{arch})
@deftypefnx {Función incorporada} {@var{fid_list} =} fopen ("all")
@deftypefnx {Función incorporada} {[@var{file}, @var{mode}, @var{arch}] =} fopen (@var{fid})

La primera sobrecarga de la función @code{fopen} abre el archivo con 
en un modo específico (lectura-escritura,lectura-solamente,etcétera.)
y la arquitectura de interpretación (IEEE grande endian, IEEE peque@~{n}o
endian, etcétera.) regresan un valor entero que puede ser usado como
referencia al archivo más adelante. Si un error ocurre, @var{fid} es 
puesto @minus{}1 y @var{msg} contiene el correspondiente mensaje de error
del sistema. el @var{mode} es uno o dos caracteres que especifican si el
archivo esta abierto para lectura, escritura o ambos.

La segunda sobrecarga de la función @code{fopen} regresa un vector con
los ids correspondientes a todos los archivos abiertos actualmente, 
excluyendo los @code{stdin}, @code{stdout}, y @code{stderr} streams.

La tercera sobrecarga de la función @code{fopen} regresa la 
información sobre el archivo abierto pasandolé el identificador
del archivo.

Por ejemplo,

@example
myfile = fopen ("splat.dat", "r", "ieee-le");
@end example

@noindent
Abre el archivo @file{splat.dat} para lectura. Si se necesita, un valor 
numérico binario será leído deducíendo que estos esten guardados
en el formato IEEE, el bit menos significativo es el primero, y entonces
convertirla a la reperesentación natural.

Abrir un archivo que ya está abierto, simplemente lo volvera  abrir 
otra vez y regresará un identificador de archivo distinto. 
No es un error abrir un archivo varias veces, aunque escribir en el 
mismo archivo a través de algunos identificadores diferentes puede
producir resultados inesperasos.

Los posibles valores para @samp{mode} podrían ser

@table @asis
@item @samp{r}
Abre el archivo para lectura.

@item @samp{w}
Abre el archivo para escritura. Los contenidos previos son descartados.

@item @samp{a}
Abre o crea un archivo para escritura en el final del archivo

@item @samp{r+}
Abre un archivo existente para lectura y escritura.

@item @samp{w+}
Abre un archivo existente para lectura y escritura. Los contenidos 
previos son descartados.

@item @samp{a+}
Abre o crea un archivo for lectura o escritura en el final del archivo
@end table

A@~{n}adir una "t" a la cadena del modo abre el archivo en modo texto o una
"b" para abrilo en modo binario. En los sistemas Windows y Macintosh, en 
modo texto lectura y escritura automaticamente convierte avances de 
línea en el carácter apropiado de fín de línea para cada sistema
(retorno de carro y avance de línea en Windows, retorno de carro en
Macintosh). El valor predeterminado sin ningún modo es el modo binario.

Adicionalmente, usted puede aqregar una "z" a la cadena del modo para 
abrir un archivo gzipped para leer y escribir. esto puede ser muy útil,
también debe abrir el archivo en el modo binario

El parametro @var{arch} es una cadena especificando el formato de datos
predeterminado para el archivo. Los valores para @var{arch} son:

@table @asis
@samp{native}
El formato de la máquina actual (Este es el predeterminado)

@samp{ieee-be}
IEEE endian formato grande.

@samp{ieee-le}
IEEE endian formato peque@~{n}o.

@samp{vaxd}
VAX D formato flotante.

@samp{vaxg}
VAX G formato flotante.

@samp{cray}
Cray formato flotante.
@end table

@noindent
Sin embargo, las conversiones actualmente están soportadas para 
@samp{native}
@samp{ieee-be}, and @samp{ieee-le} formatos.
@seealso{fclose, fread, fseek}
@end deftypefn