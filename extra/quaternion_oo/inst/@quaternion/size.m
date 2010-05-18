function [s, varargout] = size (a, b)

  switch (nargout)
    case {0, 1}
      switch (nargin)
        case 1
          s = size (a.w);

        case 2
          s = size (a.w, b);

        otherwise
          print_usage ();
      endswitch

    case 2
      if (nargin == 1)
        [s, varargout{1}] = size (a.w);
      else
        print_usage ();
      endif

    otherwise
      print_usage ();
  endswitch

endfunction