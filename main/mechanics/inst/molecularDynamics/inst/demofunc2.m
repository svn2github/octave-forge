function [f1 f2] = demofunc2 (x1,x2,v1,v2)
   f1 = -15 *((x1-x2) + 0.2) -0.7*(v1-v2);
   f2 = -f1;
end

