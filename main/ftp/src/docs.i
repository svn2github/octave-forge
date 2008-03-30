
%docstring ftp::ftp {
@deftypefn {Loadable Function} {@var{f}} ftp (@var{host})
@deftypefnx {Loadable Function} {@var{f}} ftp (@var{host}, @var{username}, @var{password})
Connect to the FTP server @var{host} with @var{username} and @var{password}.
If @var{username} and @var{password} are not specified, user "anonymous" with no password is used.
The returned FTP object @var{f} represents the established FTP connection.
@end deftypefn
}

%docstring ftp::close {
@deftypefn {Loadable Function} ftp (@var{f})
Close the FTP connection represented by given FTP object @var{f}.
@var{f} is an FTP object returned by the ftp function.
@end deftypefn
}

%docstring ftp::cd {
@deftypefn {Loadable Function} cd (@var{f},@var{path})
Set the remote directory to @var{path} on the FTP connection @var{f}.
@var{f} is an FTP object returned by the ftp function.
@end deftypefn
}

%docstring ftp::pwd {
@deftypefn {Loadable Function} {@var{path}} pwd (@var{f})
Returns the current remote directory of the FTP connection @var{f}.
@var{f} is an FTP object returned by the ftp function.
@end deftypefn
}

%docstring ftp::ls {
@deftypefn {Loadable Function} {@var{dirlist}} ls (@var{f})
List the current directory for the FTP connection @var{f}.
@var{f} is an FTP object returned by the ftp function.
@end deftypefn
}

%docstring ftp::nlst {
@deftypefn {Loadable Function} {@var{dirlist}} nlst (@var{f})
List the current directory for the FTP connection @var{f}.
@var{f} is an FTP object returned by the ftp function.
@end deftypefn
}

%docstring ftp::dir {
@deftypefn {Loadable Function} {@var{dirlist}} dir (@var{f})
List the current directory in verbose form for the FTP connection @var{f}.
@var{f} is an FTP object returned by the ftp function.
@end deftypefn
}

%docstring ftp::rmdir {
@deftypefn {Loadable Function} rmdir (@var{f},@var{path})
Remove the remote directory @var{path}, over the FTP connection @var{f}.
@var{f} is an FTP object returned by the ftp function.
@end deftypefn
}

%docstring ftp::mkdir {
@deftypefn {Loadable Function} mkdir (@var{f},@var{path})
Create the remote directory @var{path}, over the FTP connection @var{f}.
@var{f} is an FTP object returned by the ftp function.
@end deftypefn
}

%docstring ftp::rename {
@deftypefn {Loadable Function} rename (@var{f},@var{oldname},@var{newname})
Rename/move the remote file or directory @var{oldname} to @var{newname}, 
over the FTP connection @var{f}.
@var{f} is an FTP object returned by the ftp function.
@end deftypefn
}

%docstring ftp::remove {
@deftypefn {Loadable Function} delete (@var{f},@var{path})
Delete the remote file or directory @var{path}, over the FTP connection @var{f}.
@var{f} is an FTP object returned by the ftp function.
@end deftypefn
}

%docstring ftp::mget {
@deftypefn {Loadable Function} mget (@var{f},@var{path})
@deftypefnx {Loadable Function} mget (@var{f},@var{path},@dots{},@var{target})
The first form downloads a remote file @var{path} to the current local directory.
The second form downloads a series of files given by @var{path} and subsequent 
string parameters into the local directory @var{target}.
@var{f} is an FTP object returned by the ftp function.
@end deftypefn
}

%docstring ftp::mput {
@deftypefn {Loadable Function} mput (@var{f},@var{path})
Upload the local file @var{path} into the current remote directory on the 
FTP connection @var{f}.
@var{f} is an FTP object returned by the ftp function.
@end deftypefn
}

%docstring ftp::ascii {
@deftypefn {Loadable Function} ascii (@var{f})
Put the FTP connection @var{f} into ascii mode.
@var{f} is an FTP object returned by the ftp function.
@end deftypefn
}

%docstring ftp::binary {
@deftypefn {Loadable Function} binary (@var{f})
Put the FTP connection @var{f} into binary mode.
@var{f} is an FTP object returned by the ftp function.
@end deftypefn
}
