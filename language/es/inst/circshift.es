md5="208126302c719b9f36f6f0375cb3be64";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{y} =} circshift (@var{x}, @var{n})
Desplaza circularmente los elementos del arreglo @var{x}. @var{n} debe ser 
un vector de enteros menor o igual que el número de dimensiones en 
@var{x}. Las valores de @var{n} pueden ser positivos o negativos,
lo cual determina la dirección en la cual los valores o @var{x} se van a  
desplazar. Si un elemento de @var{n} es cero, la dimensión 
correspondiente de @var{x} no será desplazada. Por ejemplo

@example
@group
x = [1, 2, 3; 4, 5, 6; 7, 8, 9];
circshift (x, 1)
@result{}  7, 8, 9
    1, 2, 3
    4, 5, 6
circshift (x, -2)
@result{}  7, 8, 9
    1, 2, 3
    4, 5, 6
circshift (x, [0,1])
@result{}  3, 1, 2
    6, 4, 5
    9, 7, 8
@end group
@end example
@seealso {permute, ipermute, shiftdim}
@end deftypefn
