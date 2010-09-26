-*- texinfo -*-
@deffn {Comando} who options pattern @dots{}
@deffnx {Comando} whos options pattern @dots{}
Lista de símbolos definidos en la actualidad se acompañando los patrones
dados. Las siguientes son opciones válidas. Se puede reducir a un
caracter, pero no podrán combinarse

@table @code
@item -all
Lista todos los símbolos definidos en la actualidad.

@item -builtins
Lista las funciones integradas. Esto incluye todos los archivos 
compilados en la actualidad, pero no incluye todos los archivos de 
función que están en  de la ruta de búsqueda.

@item -functions
Lista funciones definidas por el usuario.

@item -long
Imprimir un listado largo, incluyendo el tipo y dimensiones de los 
símbolos. Los símbolos en la primera columna de salida de indican si
es posible redefinir el símbolo, y si es posible para que pueda ser 
despejada

@item -variables
List user-defined variables.
@end table
pPtrones válidos son iguales a los descritos para @code{clear} comando
anterior. Si no se suministran los patrones, todos los símbolos de la 
misma categoría se muestran. De forma predeterminada, el usuario sólo
se define las funciones y variables visibles en el ámbito local se
muestran.

El comando  @kbd{whos} es equivalente a @kbd{who -long}.
@end deffn
