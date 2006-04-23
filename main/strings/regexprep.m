function t = regexprep(str,pat,rep,varargin)
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
       t(s(i):e(i)) = r;
     end
   else
     [s,e] = regexp(str,pat,varargin{:});
     for i=length(s):-1:1
       t = [t(1:s(i)-1),rep,t(e(i)+1:end)];
     end
   end

%!test
%! xml = '<!-- This is some XML --> <tag v="hello">some stuff<!-- sample tag--></tag>';
%! t = regexprep(xml,'<[!?][^>]*>','');
%! assert(t,' <tag v="hello">some stuff</tag>')

%!test
%! xml = '<!-- This is some XML --> <tag v="hello">some stuff<!-- sample tag--></tag>';
%! t = regexprep(xml,'<[!?][^>]*>','?');
%! assert(t,'? <tag v="hello">some stuff?</tag>')

%!test
%! data = "Bob Smith\nDavid Hollerith\nSam Jenkins";
%! result = "Smith,Bob\nHollerith,David\nJenkins,Sam";
%! t = regexprep(data,'(?m)^(\w+)\s+(\w+)$','$2,$1');
%! assert(t,result)
