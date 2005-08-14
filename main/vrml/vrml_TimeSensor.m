##  s = vrml_TimeSensor (...)   - Low-level vrml TimeSensor node
##  
##  s is a vrml node with possible fields :
##  ------------------------------------------------------------------
## TimeSensor { 
##   exposedField SFTime   cycleInterval 1       # (0,inf)
##   exposedField SFBool   enabled       TRUE
##   exposedField SFBool   loop          FALSE
##   exposedField SFTime   startTime     0       # (-inf,inf)
##   exposedField SFTime   stopTime      0       # (-inf,inf)
##   eventOut     SFTime   cycleTime
##   eventOut     SFFloat  fraction_changed      # [0, 1]
##   eventOut     SFBool   isActive
##   eventOut     SFTime   time
## }
##  ------------------------------------------------------------------
##
## Options :
## Beyond all the fields of the node, it is also possible to use the option
##
## "DEF", name : The created node will be preceded by 'DEF name ', so that
##               it is further possible to refer to it.
##
## See also : 

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>

function s = vrml_TimeSensor (varargin)

verbose = 0;

tpl = struct ("cycleInterval", "SFTime",\
"startTime",     "SFTime",\
"stopTime",      "SFTime",\
"enabled",       "SFBool",\
"loop",          "SFBool"
);

headpar = list ();
dnode = struct ();

				# Transform varargin into key-value pairs
i = j = k = 1;			# i:pos in new varargin, j:pos in headpar,
				# k:pos is old varargin.
while i <= length (varargin) && \
      ! (isstr (nth (varargin,i)) && struct_contains (tpl, nth (varargin,i)))
  
  if j <= length (headpar)

    if verbose
      printf ("vrml_TimeSensor : Assume arg %i is '%s'\n",k,nth(headpar,j));
    end

    varargin = splice (varargin, i, 0, headpar(j++));
    i += 2;
    k++;
  else
    error ("vrml_TimeSensor : Argument %i should be string, not '%s'",\
	   k,typeinfo (nth (varargin, i)));
  end
end


if rem (length (varargin), 2), error ("vrml_TimeSensor : Odd n. of arguments"); end

DEF = 0;

l = list ("TimeSensor {\n");
i = 1;
while i < length (varargin)

  k = nth (varargin, i++);	# Read key

  if ! isstr (k)
    error ("vrml_TimeSensor : Arg n. %i should be a string, not a %s.",\
	   i-1, typeinfo (k));
  end
  if ! struct_contains (tpl, k) && ! strcmp (k,"DEF")
    error ("vrml_TimeSensor : Unknown field '%s'. Should be one of :\n%s",\
	    k, sprintf ("   '%s'\n",fieldnames (tpl)'{:}));
  end

  v = nth (varargin, i++);	# Read value
				# Add DEF
  if strcmp (k,"DEF")

    if verbose, printf ("vrml_TimeSensor : Defining node '%s'\n",v); end

    if DEF, error ("vrml_TimeSensor : Multiple DEFs found"); end
    l = splice (l,1,0,list ("DEF ",v," "));
    DEF = 1;

  else				# Add data field

    if verbose
      printf ("vrml_TimeSensor : Adding '%s' of type %s, with arg of type %s\n",\
	      k,tpl.(k),typeinfo (v));
    end
    if strcmp (tpl.(k)(2:length(tpl.(k))), "FNode")

      if verbose, printf ("vrml_TimeSensor : Trying to learn type of node\n"); end

      if is_list (v)		# v is list of arguments

				# Check whether 1st arg is node type's name.
	tn = nth (v,1);

	if all (exist (["vrml_",tn]) != [2,3,5])
	  			# If it isn't type's name, use default type.
	  if struct_contains (dnode, k)
	    if verbose
	      printf ("vrml_TimeSensor : Using default type : %s\n",dnode.(k));
	    end
	    v = splice (v, 1, 0,  list (dnode.(k)));
	  else
	    error ("vrml_TimeSensor : Can't determine type of node '%s'",k);
	  end
	else
	  if verbose
	    printf ("vrml_TimeSensor : 1st list element is type : %s\n",tn);
	  end
	end
				# If v is not a list, maybe it has a default
				# node type type (otherwise, it's be sent
				# plain.
      elseif struct_contains (dnode, k)
	if verbose
	  printf ("vrml_TimeSensor : Using default type : %s\n",dnode.(k));
	end
	v = list (dnode.(k), v);
      end
    end
    l = append (l, k, " ", data2vrml (tpl.(k), v),"\n");
  end
  
end
l = append (l, "}\n");
s = leval ("strcat", l);
endfunction

