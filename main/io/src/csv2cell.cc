// Copyright (C) 2004 Laurent Mazet <mazet@crm.mot.com>
    //
    // This program is free software; you can redistribute it and/or modify it under
    // the terms of the GNU General Public License as published by the Free Software
    // Foundation; either version 3 of the License, or (at your option) any later
    // version.
    //
    // This program is distributed in the hope that it will be useful, but WITHOUT
    // ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    // FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
    // details.
    //
    // You should have received a copy of the GNU General Public License along with
    // this program; if not, see <http://www.gnu.org/licenses/>.
    
    #include <fstream>
    
    #include <octave/oct.h>
    #include <octave/Cell.h>
    
    #define MAXSTRINGLENGTH 4096
    
    DEFUN_DLD (csv2cell, args, nargout, 
              "-*- texinfo -*-\n"
              "@deftypefn {Loadable Function} {@var{c} = } csv2cell (@var{file})\n"
           "@deftypefnx {Loadable Function} {@var{c} = } csv2cell (@var{file}, @var{sep})\n"
           "@deftypefnx {Loadable Function} {@var{c} = } csv2cell (@var{file}, @var{sep}, @var{prot})\n"
           "\n"
           "Read a CSV (Comma Separated Values) file and convert it into a cell array. "
           "@var{sep} (a character value) changes the character used to separate two fields. "
           "The default value is a comma "
           "(@code{,}). @var{prot} (character value) changes the character used to protect a string. "
           "The default is a double quote (@code{\"}).\n"
           "The maximum line width of the csv file is 4092 characters.\n"
           "@end deftypefn") {
    
      /* Get arguments */
      const int nargin = args.length ();
      octave_value_list retval;
      if (nargin == 0)
        {
          error ("csv2cell: not enough input arguments");
          return retval;
        }
        
      const std::string file = args (0).string_value ();
    
      const std::string _sep = (nargin > 1) ? args (1).string_value () : ",";
      if (_sep.length() != 1)
        {
          error ("csv2cell: separator value can only be one character\n");
          return retval;
        }
      char sep = _sep[0];
    
      const std::string _prot = (nargin > 2) ? args (2).string_value () : "\"";
      if (_prot.length() != 1)
        {
          error ("csv2cell: protector value can be only one character\n");
          return retval;
        }
      char prot = _prot[0];
    
      /* Open file */
      std::ifstream fd (file.c_str ());
      if (!fd.is_open ())
        {
          error ("csv2cell: cannot open file %s for reading\n", file.c_str());
          return retval;
        }
      fd.seekg (0, std::ios::end);
      long fdend = fd.tellg ();
      fd.seekg (0, std::ios::beg);
    
      if (fd.tellg () >= fdend)
        return octave_value (Cell (0, 0));
    
      /* Buffers */
      char line [MAXSTRINGLENGTH];
      std::string str, word;
      bool inside = false;
    
      /* Read a line */
      str = "";
      fd.getline (line, MAXSTRINGLENGTH);
      while (fd.fail ())
        {
          fd.clear ();
          str += line;
          fd.getline (line, MAXSTRINGLENGTH);
        }
      str += line;
    
      /* Parse first to get number of columns */
      int nbcolumns = 0;
      for (int i = 0, len = str.length (); i <= len; i++)
        if (((i==len) || (str [i] == sep)) && (!inside))
          nbcolumns++;
        else if ((inside) && (str [i] == prot) && ((i < len) && (str [i+1] == prot)))
          ++i;
        else if (str [i] == prot)
          inside = !inside;
      
      /* Read all the file to get number of rows */
      int nbrows = 1;
      while (fd.tellg () < fdend)
        {
          fd.getline (line, MAXSTRINGLENGTH);
          while (fd.fail ())
            {
              fd.clear ();
              fd.getline (line, MAXSTRINGLENGTH);
            }
          nbrows++;
        }
    
      /* Rewind */
      fd.seekg (0, std::ios::beg);
      if (!fd.good ())
        {
          error ("csv2cell: cannot reread %s\n", file.c_str ());
          return retval;
        }
    
      /* Read all the file until the end */
      Cell c (nbrows, nbcolumns);
      for (int i = 0; i < nbrows; i++)
        {
          /* Read a line */
          str = "";
          fd.getline (line, MAXSTRINGLENGTH);
          while (fd.fail ())
            {
              fd.clear ();
              str += line;
              fd.getline (line, MAXSTRINGLENGTH);
            }
          str += line;
    
          /* Explode a line into a sub cell */
          word = "";
          inside = false;
          int j = 0;
          for (int k = 0, len = str.length (); k <= len; k++)
            {
              if (((k == len) || (str [k] == sep)) && (!inside))
                {
                  /* Check number of columns */
                  if (j == nbcolumns)
                    {
                      fd.close ();
                      error ("csv2cell: incorrect CSV file, line %d too long\n", i+1);
                      return retval;
                    }
    
                  /* Check if scalar */
                  const char *word_str = word.c_str ();
                  char *err;
                  double val = strtod (word_str, &err);
    
                  /* Store into the cell */
                  c (i, j++) = ((word == "") || (err != word_str+word.length())) ?
                               octave_value (word) : octave_value (val);
                  word = "";
                }
              else if ((inside) && (str[k]==prot) && ((k<len) && (str[k+1]==prot)))
                {
                  /* Insisde a string */
                  word += prot;
                  ++k;
                }
              else if (str[k] == prot)
                /* Changing */
                inside = !inside;
              else
                word += str[k];
            }
    
          /* Check number of columns */
          if (j != nbcolumns)
            {
              fd.close ();
              error ("csv2cell: incorrect CSV file, line %d too short\n", i+1);
              return retval;
            }
        }
    
      /* Close file */
      fd.close ();
    
      retval (0) = c;
      return retval;
    }
    