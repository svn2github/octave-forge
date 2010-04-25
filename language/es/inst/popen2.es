md5="8afe8869fe678b56c517ea081befda1f";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{in}, @var{out}, @var{pid}] =} popen2 (@var{command}, @var{args})
Inicia un subproceso de comunicación de dos-vías. El nombre del
proceso viene dado por @var{command}, y @var{args} es una matriz de
cadenas que contiene las opciones para el comando. Los identificadores
de archivo para los flujos de entrada y salida del subproceso se 
devuelven en @var{in} y @var{out}. Si la ejecución del comando es
exitosa, @var{pid} contiene el ID de proceso del subproceso. De lo
contrario,@var{pid} es @minus{}1.

Por ejemplo,

@example
@group
[in, out, pid] = popen2 ("sort", "-nr");
fputs (in, "these\nare\nsome\nstrings\n");
fclose (in);
EAGAIN = errno ("EAGAIN");
done = false;
do
  s = fgets (out);
  if (ischar (s))
    fputs (stdout, s);
  elseif (errno () == EAGAIN)
    sleep (0.1);
    fclear (out);
  else
    done = true;
  endif
until (done)
fclose (out);
@print{} are
@print{} some
@print{} strings
@print{} these
@end group
@end example
@end deftypefn 