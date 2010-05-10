## test_oct2mat is a script for testing oct2mat conversion 
##
## Copyright (C) 2010 Jaroslav Hajek, Alois Schloegl 

b=zeros(5);
c=ones(5);
mat = randn(5);
BW2=1; BW=[-2:2];
x = 1:5; y=1:2; z = 2**a;
## multiple assignments
a=b=c;  ## coment1
a=b=c=0; ## comment2
a=b=c=d=e; 
a=b=c~=d=e; 
a = b = c = d = e; 
aa = bb = cc = dd = ee; 
## exclude comparison 
aa=bb~=cc;
aa=bb<=cc;
aa=bb~=cc=dd;
aa=bb>=cc=dd;
##***********************
 undo; 
 do2
 1do
 do
 until (5) ## comment       
 until (5)
 a++; % until 5 o'clock

b(1,:) += c(2,:);
[cols{1:3}] = num2cell (mat){:};
if (all((BW2==BW & BW != 0)(:)))

  k_1 += 2 + a;
  k_2 += 2 | a;        ## make sure RHS is in parenthesis
  k_3 |= 2 || a;       ## make sure RHS is in parenthesis
  k_4 -= 2 + a;        ## make sure RHS is in parenthesis
  k /= 2 / a;
  k \= 2 \ a;
  k *= 2 + a;
  k ./= 2 + a;
  k .\= 2 + a;
  k .*= 2 + a;
  k &= 2 | a;        ## make sure RHS is in parenthesis
  k |= 2 & a;
  k += - 2;
  k ^= 2 + a;
  k .^= 2 + a;
  sub{d} += incr;
  x /= 4 ; y /= 4 ;
       res(vars(irow)) +=...
           c(irow);

endif
a = -ones(length(x)+length(y)-2,1);
k.x = zeros(length(x)+length(y)-1);
k.x(:,1) += conv (x, y)(:) - [1; a](:);        ## not correctly resolved
k.x(1,:) += conv (x, y)(:).' - [1, a](:);
y += [1; a](:);        ## not correctly resolved

b = 0;
if (a ||
    b )
end
    
k = 0; N=10;
k++;
while (k++ < N)         ## todo 
   a = 5;     
endwhile 

do         ## not resolved 
    x++;
    x-- ;
    x_5-- ;
    x_5_-- ;
    _x_5_-- ;
    x(2)++ ;
    x(2) -= 1;
    a=b+c; x++ ;
    x -- ;
until (x(3)>10);

function x = __underscore_function__(x)         ## todo 
function x = __underscore_function__ (x)         ## todo 
        x += 2;
endfunction      

x = __underscore_function__(5);              ## todo
__underscore_variable__ = 5;                 ## todo 
 __underscore_variable__ = 5;                 ## todo 

