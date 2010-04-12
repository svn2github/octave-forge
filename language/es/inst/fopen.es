md5="540013b3db584e4396e7642709f88914";rev="6834";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {[@var{fid}, @var{msg}] =} fopen (@var{name}, @var{mode}, @var{arch})
@deftypefnx {Funci@'on incorporada} {@var{fid_list} =} fopen ("all")
@deftypefnx {Funci@'on incorporada} {[@var{file}, @var{mode}, @var{arch}] =} fopen (@var{fid})

La primera sobrecarga de la funci@'on @code{fopen} abre el archivo con 
en un modo espec@'ifico (lectura-escritura,lectura-solamente,etc@'etera.)
y la arquitectura de interpretaci@'on (IEEE grande endian, IEEE peque@~{n}o
endian, etc@'etera.) regresan un valor entero que puede ser usado como
referencia al archivo m@'as adelante. Si un error ocurre, @var{fid} es 
puesto @minus{}1 y @var{msg} contiene el correspondiente mensaje de error
del sistema. el @var{mode} es uno o dos caracteres que especifican si el
archivo esta abierto para lectura, escritura o ambos.

La segunda sobrecarga de la funci@'on @code{fopen} regresa un vector con
los ids correspondientes a todos los archivos abiertos actualmente, 
excluyendo los @code{stdin}, @code{stdout}, y @code{stderr} streams.

La tercera sobrecarga de la funci@'on @code{fopen} regresa la 
informaci@'on sobre el archivo abierto pasandol@'e el identificador
del archivo.

Por ejemplo,

@example
myfile = fopen ("splat.dat", "r", "ieee-le");
@end example

@noindent
Abre el archivo @file{splat.dat} para lectura. Si se necesita, un valor 
num@'erico binario ser@'a le@'ido deduc@'iendo que estos esten guardados
en el formato IEEE, el bit menos significativo es el primero, y entonces
convertirla a la reperesentaci@'on natural.

Abrir un archivo que ya est@'a abierto, simplemente lo volvera  abrir 
otra vez y regresar@'a un identificador de archivo distinto. 
No es un error abrir un archivo varias veces, aunque escribir en el 
mismo archivo a trav@'es de algunos identificadores diferentes puede
producir resultados inesperasos.

Los posibles valores para @samp{mode} podr@'ian ser

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
l@'inea en el car@'acter apropiado de f@'in de l@'inea para cada sistema
(retorno de carro y avance de l@'inea en Windows, retorno de carro en
Macintosh). El valor predeterminado sin ning@'un modo es el modo binario.

Adicionalmente, usted puede aqregar una "z" a la cadena del modo para 
abrir un archivo gzipped para leer y escribir. esto puede ser muy @'util,
tambi@'en debe abrir el archivo en el modo binario

El parametro @var{arch} es una cadena especificando el formato de datos
predeterminado para el archivo. Los valores para @var{arch} son:

@table @asis
@samp{native}
El formato de la m@'aquina actual (Este es el predeterminado)

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
Sin embargo, las conversiones actualmente est@'an soportadas para 
@samp{native}
@samp{ieee-be}, and @samp{ieee-le} formatos.
@seealso{fclose, fread, fseek}
@end deftypefn