md5="c8b107e8aaad45b4a53c3aa2672a6744";rev="6301";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{b} =} unwrap (@var{a}, @var{tol}, @var{dim})
Separa las fases de radianes a@~{n}adiendo m@'ultiplos de @code{2*pi} 
seg@'un sea el caso para remover los saltos mayores que @var{tol}. El 
valor predetermiando de @var{tol} @code{pi}. 

La funci@'on @code{unwrap} separa las fases a lo largo de la primera dimensi@'on 
no singleton de @var{a}, a menos que se suministre el argumento opcional 
@var{dim}, en cuyo caso los datos se separan a lo largo de esta dimensi@'on.
@end deftypefn
