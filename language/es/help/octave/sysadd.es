md5="eeefb74482e3fa647b687a418928b961";rev="6466";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {}  sysadd (@var{gsys}, @var{hsys})

Retorna @var{sys} = @var{gsys} + @var{hsys}.

@itemize @bullet
@item Termina con un error si las dimensiones de @var{gsys} y @var{hsys} 
no son compatibles.
@item Imprime un mensaje de advertencia si los estados de los sistemas 
tienen nombres id@'enticos; a los nombre duplicados se les adiciona un 
sufijo para hacerlos @'unicos.
@item Los nombres de las entradas/salidas de @var{sys} se toman de @var{gsys}.
@end itemize
@example
@group
          ________
     ----|  gsys  |---
u   |    ----------  +|
-----                (_)----> y
    |     ________   +|
     ----|  hsys  |---
          --------
@end group
@end example
@end deftypefn
