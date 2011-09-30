function [f1 f2] = demofunc1 (dx, dv)
    f1 = lennardjones (dx, (0.15)^2, 1e-2);
    f2 = -f1;
endfunction

