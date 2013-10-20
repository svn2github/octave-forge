## (c) http://rosettacode.org/wiki/Determine_if_a_string_is_numeric#Octave
## Content is available under GNU Free Documentation License 1.2.
## http://www.gnu.org/licenses/fdl-1.2.html

## -*- texinfo -*- 
##  @deftypefn  {Function File} {@var{r} =} __is_str_numeric (@var{a})
##
## Check if a string is a number.
##
## @end deftypefn

## Created: 2013-10-04

function r = __is_str_numeric(a)
  if ( isnumeric(a) )
    r = 1;
  else
    o = str2double(a);
    r = !isnan(o);
  endif
endfunction