function retval = tolower (s)

  if (nargin != 1)
    error ('t = tolower (s)');
  endif

  retval = lower (s);
