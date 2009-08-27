md5="ff544b55191f98c5ca05f06e3ba06fc1";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{est}, @var{v}] =} condest (@var{a}, @var{t}) 
@deftypefnx {Archivo de funci@'on} {[@var{est}, @var{v}] =} condest (@var{a}, @var{solve}, @var{solve_t}, @var{t})
@deftypefnx {Archivo de funci@'on} {[@var{est}, @var{v}] =} condest (@var{apply}, @var{apply_t}, @var{solve}, @var{solve_t}, @var{n}, @var{t})

Calcula el (norma-uno) n@'umero de condici@'on de una matriz @var{A}
usando @var{t} vectores de prueba con un estimador de norm-uno aleatorio.
Si @var{t} es mayor que 5, solo se usan 5 vetores de prueba.

Si la matriz no es expl@'icita, e.g. cuando se estima el n@'umero de 
condici@'on de @var{a} dada una factorizyci@'on LU, @code{condest} usa las
siguientes funciones:

@table @var
@item apply
@code{A*x} para una matriz @code{x} de tama@~{n}o @var{n} por @var{t}.
@item apply_t
@code{A'*x} para una matriz @code{x} de tama@~{n}o @var{n} por @var{t}.
@item solve
@code{A \ b} para una matriz @code{b} de tama@~{n}o @var{n} por @var{t}.
@item solve_t
﻿
