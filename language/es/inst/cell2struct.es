md5="e1a38e4658db14061333a337660921a7";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} cell2struct (@var{cell}, @var{fields}, @var{dim})
Convierte @var{cell} en una estructura. El númeor de campos en @var{fields}
debe coincidir con el número de elementos en @var{cell} a lo largo de la dimensión @var{dim},
este es @code{numel (@var{fields}) == size (@var{cell}, @var{dim})}.

@example
@group
A = cell2struct(@{'Peter', 'Hannah', 'Robert'; 185, 170, 168@}, @{'Name','Height'@}, 1);
A(1)
@result{} ans =
      @{
        Height = 185
        Name   = Peter
      @}

@end group
@end example
@end deftypefn
