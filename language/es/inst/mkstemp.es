md5="9d31c0e99fe478c991c1142d446c257d";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {[@var{fid}, @var{name}, @var{msg}] =} mkstemp (@var{template}, @var{delete})
Regresa la identificación del archivo de correspondiente a un archivo
temporal con un nombre único creado por @var{template}. Los últimos
seis caracteres de @var{template} deben ser @code{XXXXXX} y éstos son
reemplazados con una cadena elaborada con el nombre de archivo único.
El archivo es creado con el modo de lectura/escritura y los permisos son
dependientes del sistema (en sistemas GNU/Linux, los permisos serán
0600 para las versiones de glibc 2.0.7 y posteriores). El archivo se abre
con la bandera @code{O_EXCL} .

Si el argumento opcional @var{delete} se suministra y es true, el archivo
se borrará automáticamente cuando sale de Octave, o cuando la 
función @code{purge_tmp_files} se llama.

Si tiene éxito, @var{fid} es un archivo válido de identidad,  @var{name}
es el nombre de su archivo, y @ var (msg) es una cadena vacía. De lo contrario, @ var () fid es -1, @ var (nombre) está vacío, y @ var (msg) contiene un mensaje del sistema-dependenterror.

If successful, @var{fid} is a valid file ID, @var{name} is the name of
the file, and @var{msg} is an empty string.  Otherwise, @var{fid}
is -1, @var{name} is empty, and @var{msg} contains a system-dependent
error message.
@seealso{tmpfile, tmpnam, P_tmpdir}
@end deftypefn
