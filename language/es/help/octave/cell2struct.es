md5="e1a38e4658db14061333a337660921a7";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} cell2struct (@var{cell}, @var{fields}, @var{dim})
Convierte @var{cell} en una estructura. El n@'umeor de campos en @var{fields}
debe coincidir con el n@'umero de elementos en @var{cell} a lo largo de la dimensi@'on @var{dim},
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
