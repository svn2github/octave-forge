function x=rindex(s,t)
     idx = findstr(s,t);
     if isempty(idx)
       x = 0;
     else
       x = idx(length(idx));
     end   
