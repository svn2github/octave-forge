md5="208126302c719b9f36f6f0375cb3be64";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{y} =} circshift (@var{x}, @var{n})
Desplaza circularmente los elementos del arreglo @var{x}. @var{n} debe ser 
un vector de enteros menor o igual que el n@'umero de dimensiones en 
@var{x}. Las valores de @var{n} pueden ser positivos o negativos,
lo cual determina la direcci@'on en la cual los valores o @var{x} se van a  
desplazar. Si un elemento de @var{n} es cero, la dimensi@'on 
correspondiente de @var{x} no ser@'a desplazada. Por ejemplo

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
