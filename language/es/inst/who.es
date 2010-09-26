-*- texinfo -*-
@deffn {Comando} who options pattern @dots{}
@deffnx {Comando} whos options pattern @dots{}
Lista de s�mbolos definidos en la actualidad se acompa�ando los patrones
dados. Las siguientes son opciones v�lidas. Se puede reducir a un
caracter, pero no podr�n combinarse

@table @code
@item -all
Lista todos los s�mbolos definidos en la actualidad.

@item -builtins
Lista las funciones integradas. Esto incluye todos los archivos 
compilados en la actualidad, pero no incluye todos los archivos de 
funci�n que est�n en  de la ruta de b�squeda.

@item -functions
Lista funciones definidas por el usuario.

@item -long
Imprimir un listado largo, incluyendo el tipo y dimensiones de los 
s�mbolos. Los s�mbolos en la primera columna de salida de indican si
es posible redefinir el s�mbolo, y si es posible para que pueda ser 
despejada

@item -variables
List user-defined variables.
@end table
pPtrones v�lidos son iguales a los descritos para @code{clear} comando
anterior. Si no se suministran los patrones, todos los s�mbolos de la 
misma categor�a se muestran. De forma predeterminada, el usuario s�lo
se define las funciones y variables visibles en el �mbito local se
muestran.

El comando  @kbd{whos} es equivalente a @kbd{who -long}.
@end deffn
