md5="cc58f6cd259ed328f66a24257a701b13";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {@var{val} =} split_long_rows ()
@deftypefnx {Funci@'on incorporada} {@var{old_val} =} split_long_rows (@var{new_val})
Consulta o establece la variable interna que controla si las filas de una
matriz puede separarse cuando se muestren en una ventana terminal. Si se
separan las filas, Octave mostrar@'a la matriz en una serie de peque@~{n}as
piezas, cada una de las cuales puede caber dentro de los l@'imites de su
ancho de terminal, y cada conjunto de filas se etiqueta de manera que 
usted puede ver f@'acilmente las columnas que se mostrar@'an. Por ejemplo:

@smallexample
@group
octave:13> rand (2,10)
ans =

 Columns 1 through 6:

  0.75883  0.93290  0.40064  0.43818  0.94958  0.16467
  0.75697  0.51942  0.40031  0.61784  0.92309  0.40201

 Columns 7 through 10:

  0.90174  0.11854  0.72313  0.73326
  0.44672  0.94303  0.56564  0.82150
@end group
@end smallexample
@end deftypefn