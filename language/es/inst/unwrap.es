md5="c8b107e8aaad45b4a53c3aa2672a6744";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{b} =} unwrap (@var{a}, @var{tol}, @var{dim})
Separa las fases de radianes a@~{n}adiendo múltiplos de @code{2*pi} 
según sea el caso para remover los saltos mayores que @var{tol}. El 
valor predetermiando de @var{tol} @code{pi}. 

La función @code{unwrap} separa las fases a lo largo de la primera dimensión 
no singleton de @var{a}, a menos que se suministre el argumento opcional 
@var{dim}, en cuyo caso los datos se separan a lo largo de esta dimensión.
@end deftypefn
