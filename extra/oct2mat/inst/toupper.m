function retval = toupper (s)

  if (nargin != 1)
    error ('t = toupper (s)');
  endif

  retval = upper (s);
