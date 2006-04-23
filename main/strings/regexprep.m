## t = regexprep(string,pattern,replacement)
##
## Replace every occurrence of the pattern in the string with the replacement.
##
## The replacement can contain $i, which subsubstitutes for the ith set of
## parentheses in the match string.  E.g.,
##    regexprep("Bill Dunn",'(\w+) (\w+)','$2, $1')
## returns "Dunn, Bill"

## FIXME  This needs to be made into an oct-file with a two pass
## algorithm which first determines the length of the result
## string to preallocate it, then copies the parts of the original
## and replacement strings into the appropriate places in the
## result string.
##
## FIXME  This needs to be extended to handle string arrays.
function t = regexprep(str,pat,rep,varargin)
   ## Strip 'tokenize' option
   for i=length(varargin):-1:1
      if strcmp(varargin{i},"tokenize"), varargin(i) = []; end
   end

   ## FIXME need checking on varargin
   t = str;
   if any(rep=='$')
     [s,e,te] = regexp(str,pat,varargin{:});
     for i=length(s):-1:1,
       r = rep;
       subs = te{i};
       for j=1:rows(subs)
	 replacing=['$','0'+j];
	 with=str(subs(j,1):subs(j,2));
         r = strrep(r, replacing, with);
       end
       t = [t(1:s(i)-1),r,t(e(i)+1:end)];
     end
   else
     [s,e] = regexp(str,pat,varargin{:});
     for i=length(s):-1:1
       t = [t(1:s(i)-1),rep,t(e(i)+1:end)];
     end
   end

%!test  # Replace with empty
%! xml = '<!-- This is some XML --> <tag v="hello">some stuff<!-- sample tag--></tag>';
%! t = regexprep(xml,'<[!?][^>]*>','');
%! assert(t,' <tag v="hello">some stuff</tag>')

%!test  # Replace with non-empty
%! xml = '<!-- This is some XML --> <tag v="hello">some stuff<!-- sample tag--></tag>';
%! t = regexprep(xml,'<[!?][^>]*>','?');
%! assert(t,'? <tag v="hello">some stuff?</tag>')

%!test  # Check that 'tokenize' is ignored
%! xml = '<!-- This is some XML --> <tag v="hello">some stuff<!-- sample tag--></tag>';
%! t = regexprep(xml,'<[!?][^>]*>','','tokenize');
%! assert(t,' <tag v="hello">some stuff</tag>')

%!test  # Capture replacement
%! data = "Bob Smith\nDavid Hollerith\nSam Jenkins";
%! result = "Smith, Bob\nHollerith, David\nJenkins, Sam";
%! t = regexprep(data,'(?m)^(\w+)\s+(\w+)$','$2, $1');
%! assert(t,result)
