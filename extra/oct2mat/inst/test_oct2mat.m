## test_oct2mat is a script for testing oct2mat conversion 
##
## Copyright (C) 2010 Jaroslav Hajek, Alois Schloegl 

b=zeros(5);
c=ones(5);
mat = randn(5);
BW2=1; BW=[-2:2];
x = 1:5; y=1:2;

b(1,:) += c(2,:);
[cols{1:3}] = num2cell (mat){:};
if(all((BW2==BW & BW != 0)(:)))
  k += 2 + a;
  k += 2 | a;
  k |= 2 || a;
  k -= 2 + a;
  k /= 2 + a;
  k \= 2 + a;
  k *= 2 + a;
  k ./= 2 + a;
  k .\= 2 + a;
  k .*= 2 + a;
  k &= 2 + a;
  k |= 2 + a;
  k ^= 2 + a;
  k .^= 2 + a;
  sub{d} += incr;
endif
a = -ones(length(x)+length(y)-2,1);
k.x = zeros(length(x)+length(y)-1);
k.x(:,1) += conv (x, y)(:) - [1; a](:);        ## not correctly resolved
k.x(1,:) += conv (x, y)(:).' - [1, a](:);

b = 0;
if (a ||
    b )
end
    
k = 0; N=10;
while (k++ < N)         ## todo 
   a = 5;     
endwhile 

do         ## not resolved 
    x++;
until (x(3)>10);

function x = __underscore_function__(x)         ## todo 
        x += 2;
endfunction      

x = __underscore_function__(5);              ## todo
__underscore_variable__ = 5;                 ## todo 

