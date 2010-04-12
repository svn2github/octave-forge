md5="b866bd23733081f2e5a8dd1ff67144aa";rev="6461";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} sum (@var{x}, @var{dim})
@deftypefnx {Funci@'on incorporada} {} sum (@dots{}, 'native')
Suma los elementos a lo largo de la dimensi@'on @var{dim}. Si se 
omiete @var{dim}, el valor predetermiando es 1 (suma en sentido de 
las columnas).

Como un caso especial, si @var{x} es un vector y se omite @var{dim}, 
retorna la suma de los elementos. 

Si se suministra el argumento opcional 'native', se realiza la suma 
en el mismo tipo del argumento original, en lugar del tipo doble 
predeterminado. Por ejemplo 

@example
sum ([true, true])
  @result{} 2
sum ([true, true], 'native')
  @result{} true
@end example
@end deftypefn
