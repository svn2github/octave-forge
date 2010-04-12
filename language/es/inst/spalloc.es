md5="1bb206e8dc6782002f44ad8937c31b3a";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{s} =} spalloc (@var{r}, @var{c}, @var{nz})
Regresa una matriz dispersa vac@'ia de tama@~{n}o @var{r}-by-@var{c}.
Como Octave cambia el tama@~{n}o de matrices dispersas en la primera
oportunidad, de modo que no necesita espacio adicional, el argumento
@var{nz} es ignorado. Esta funci@'on es provista s@'olo por razones de
compatibilidad.

Cabe se@~{n}alar que esto significa que un c@'odigo como

@example
k = 5;
nz = r * k;
s = spalloc (r, c, nz)
for j = 1:c
  idx = randperm (r);
  s (:, j) = [zeros(r - k, 1); rand(k, 1)] (idx);
endfor
@end example

Reasignar@'a a la memoria en cada paso. Por tanto, es de vital importancia
que el c@'odigo de este tipo este vectorizado tanto como sea posible.
@seealso{sparse, nzmax}
@end deftypefn