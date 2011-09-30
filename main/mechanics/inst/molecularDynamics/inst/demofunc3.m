function [f1 f2] = demofunc3 (dx, dv)
    f1 = lennardjones (dx, (0.2)^2, 1);
    f2 = -f1;
 end
 
