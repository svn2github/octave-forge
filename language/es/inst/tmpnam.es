md5="89ceea44549ad41cffad9816023351df";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} tmpnam (@var{dir}, @var{prefix})
Retorna un nombre de archivo temporal único como una cadena. 

Si se omite @var{prefix}, se usa el valor @code{"oct-"}. Si también 
se omite @var{dir}, se usa el directorio temporal para almacenar los 
archivos. Si se suministra @var{dir}, el directorio debe existir, en otro 
caso, se usa el directorio predeterminado. Debido a que el archivo no 
se ha abierto, por @code{tmpnam}, es posible (aunque relativamente 
improbable) que no esté disponible en el momento en que el programa 
intenta abrirlo. 
@seealso{tmpfile, mkstemp, P_tmpdir}
@end deftypefn
