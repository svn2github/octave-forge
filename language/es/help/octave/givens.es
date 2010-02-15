md5="8dcb40c8469c5ce9e5fef1ad81c68cc9";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {@var{g} =} givens (@var{x}, @var{y})
@deftypefnx {Funci@'on cargable} {[@var{c}, @var{s}] =} givens (@var{x}, @var{y})
@ifinfo
Retorna una matriz ortogonal 2 por 2
@code{@var{g} = [@var{c} @var{s}; -@var{s}' @var{c}]} de tal manera que
@code{@var{g} [@var{x}; @var{y}] = [*; 0]} con @var{x} y @var{y} escalares.
@end ifinfo

por ejemplo,

@example
@group
Dados (1, 1)
     @result{}   0.70711   0.70711
         -0.70711   0.70711
@end group
@end example
@end deftypefn