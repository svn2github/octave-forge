## Copyright (C) 2002 Etienne Grossmann.  All rights reserved.
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by the
## Free Software Foundation; either version 2, or (at your option) any
## later version.
##
## This is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
## for more details.

## read_options is a script that can be called to read options from
## within a function. Variables in the function's namespace, with same
## name as the options will be set. read_options stops reading options
## as soon as it reads an argument that it does not recognize.
##
## nargin   : Should be set to the number of remaining arguments.
##
## opt0     : A single-space-separated string of boolean options. Should
##            be padded with a single space at both extremities.
##             Default is " ".
##
## opt1     : String of options taking one argument. Default is " ".
##
## filename : Name of the function, for verbose output or griping.
##            Default is "unknown_func"
##
## verbose  : in {0,1} : be more or less verbose. Default is 0.
##
## opt_quiet: in {0,1} : If set, read_options will gripe when it
##            encounters an unknown option. Otherwise, it just returns
##
## Also,  read_options  sets some variables that can be accessed from
## the calling function :
##
## last_option_name : The name of the last option name, OR whatever
##                    unrecognized argument that caused read_options to
##                    stop reading the arguments (if any).
##
## last_option_value: The value of the last option taking a single
##                    argument (if any).
## 
## option_number    : The number of arguments that have been read.
##
## read_options assumes that a script called from a function is executed
## as if its code was written within the function body. (like a #define
## in C). I don't think this feature is documented in octave, so it
## might stop working on some versions of octave. Works with 2.1.19.

#  if exist("filename","var")!=1  , filename="unkown_func" ; end
#  if exist("verbose","var")!=1   , verbose=0 ; end
#  if exist("opt0","var")!=1      , opt0=" "  ; end
#  if exist("opt1","var")!=1      , opt1=" "  ; end
# if exist("opt_quiet","var")!=1 , opt_quiet=0  ; end
if exist("filename")!=1  , filename="unkown_func" ; end
if exist("verbose")!=1   , verbose=0 ; end
if exist("opt0")!=1      , opt0=" "  ; end
if exist("opt1")!=1      , opt1=" "  ; end
if exist("opt_quiet")!=1 , opt_quiet=0  ; end

## opt0 
## opt1
## Commented 2000/08/13 ... break anything?
## va_start() ;
nargin_orig = nargin ;
option_number = 0 ;
## igncnt = 0 ;
while nargin>0 ,
  last_option_name = va_arg() ;
  ## opt0
  nargin-- ;
  option_number++ ;
  if ! isstr(last_option_name) ,
    if ! opt_quiet ,
      printf("%s : Non-string option : \n",filename) ;
      keyboard
    else
      if verbose,
	printf("read_options : ignoring non-string option number %d\n",\
	       option_number) ;
	## last_option_name 
      end
    end
    ## ignopt(++igncnt) = option_number ;
    ## if opt_quit_early, break ; end
    break ;
  end
  read_options_foo = [" ",last_option_name," "] ;
  ## keyboard
  if index(opt1,read_options_foo) ,
    
    last_option_value = va_arg() ;		#nargin-- ;
    ## last_option_value
    nargin-- ;
    option_number++ ;
    eval([last_option_name,"=last_option_value;"]) ;

    if verbose
      printf ("%s : Read option : %s.\n",filename,last_option_name);
    end

  elseif index(opt0,read_options_foo) ,
    eval([last_option_name,"=1;"]) ;
    if verbose 
      printf ("%s : Read boolean option : %s\n",filename,last_option_name);
    end

  else
    if ! opt_quiet ,
      printf("%s : Unknown option : %s\n",filename,last_option_name) ;
      keyboard
    else
      if verbose,
	printf("read_options : ignoring option number %d, '%s'\n",\
	       option_number,last_option_name) ;
	last_option_name 
      end

    end
    ## ignopt(++igncnt) = option_number ;
    ## if opt_quit_early, break ; end
    break
  end
end
