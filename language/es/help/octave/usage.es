md5="004f84ee8c2092d19261b38620a78f7c";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} usage (@var{msg})
Imprimir el mensaje @var{msg}, precedido por la cadena @samp{usage: }:,
y fijar el estado de error interno de Octave de forma que el control
volver@'a al nivel superior sin evaluar m@'as comandos. Esto es @'util
para abortar de las funciones.

Despu@'es @code{usage} es evaluado, Octave imprimir@'a una funci@'on de
rastreo de todas las llamadas que conduce al mensaje de uso.

Usted debe utilizar esta funci@'on para informar sobre los problemas de
errores que resultan de una llamada a una funci@'on inadecuada, como
llamar a una funci@'on con un n@'umero incorrecto de argumentos o con
argumentos del tipo equivocado. Por ejemplo, la mayor@'ia de las 
funciones de distribuci@'on con Octave comienzan con un c@'odigo como
este

@example
@group
if (nargin != 2)
  usage ("foo (a, b)");
endif
@end group
@end example

@noindent
para comprobar el n@'umero correcto de argumentos.
@end deftypefn