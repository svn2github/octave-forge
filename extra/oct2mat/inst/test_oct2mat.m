## test_oct2mat is a script for testing oct2mat conversion 
##
## Copyright (C) 2010 Jaroslav Hajek, Alois Schloegl 

b=zeros(5);
c=ones(5);
mat = randn(5);
BW2=1; BW=[-2:2];
x = 1:5; y=1:2; z = 2**a;
## parsing comments 
"a"  #comment "
"a'\'b"  #comment "
"a#%b"  #comment "
"a\"\'b"  #comment "
a'  #comment "
a.'  #comment "
a '  #comment "
a "  #comment "
a .'  #comment "

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
if (nargout == 0)
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
    ++x;
    --x;
    x_5-- ;
    x_5_-- ;
    _x_5_-- ;
    x(2)++;
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

function x = __bvp4c_solve__ (t, x, h, odefun, bcfun, Nvar, Nint, s)
  fun = @( x ) ( [vec(__bvp4c_fun_u__(t, 
				  reshape(x(1:Nvar*(Nint+1)),Nvar,(Nint+1)),
				  reshape(x([1:Nvar*Nint*s]+Nvar*(Nint+1)),Nvar,Nint,s),
 				  h,
				  s,
				  Nint,
				  Nvar));
		  vec(__bvp4c_fun_K__(t, 
				  reshape(x(1:Nvar*(Nint+1)),Nvar,(Nint+1)),
				  reshape(x([1:Nvar*Nint*s]+Nvar*(Nint+1)),Nvar,Nint,s),
				  odefun,
				  h,
				  s,
				  Nint,
				  Nvar));
		  bcfun(vec(x(1:Nvar)),
			vec(x(Nvar*Nint+1:Nvar*(Nint+1))));
		  ] );
  
  x    = fsolve ( fun, x );
endfunction


a' #comment
a ' #comment '
a .' #comment '
a " #comment " 


    for i = 1:N:pad_sz
      hb = hb + fft (postpad (b(i:i+N-1), N))(1:n);
      ha = ha + fft (postpad (a(i:i+N-1), N))(1:n);
    endfor

#### xx{kk++} = aa;
varargout{++vr_val_cnt} = nn;
varargout{vr_val_cnt++} = nn;
varargout{vr_val_cnt++} = xx;
tmp(img_idx--) = tmap(img);
tmp(--img_idx) = tmap(img);
str(--idx) = "*";
outstruct.namesn(++nnames)=nn;

args{1,++kk} = real (olpol);
args{1,++kk} = [sigma_A sigma_A+len_A*cos(phi_A)];
args{1,++kk} = real (rlzer);
args5{1,++kk} = real (rlzer);

set (hplt(kk--), "linewidth", 2);
set (hplt(kk--), "markersize", 2);

f(1) = r(k++); 
f(2) = r(k++); 

opts = varargin(narg++);
param = varargin{narg++};
std_formats{++nfmt} = "HH:MM";
  
++y(m > 12);   
++y.b;
 ijob = ++pjobs;
 ijob = pjobs++;
 ijob = --pjobs;
 ijob = pjobs--;
 
 
   real_ax_pts = real_ax_pts(find (imag (real_ax_pts) == 0));

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

      kk += 1; 
			++drows;
			++drows ; 4,
    i += 1;
    val *= 1000;
    coeff -= 1;
    val /= 1000;
    coeff += 1;


aa = dd.(kk);
  dd.(kk) = bb;
  dd.(kk) = [bb;1];
  dd.(kk) = [bb;1];b=a;
  
  
      __sqp_nfun__++;
     x(i) += deltax;
     x{i} += deltax;
     x (i) += deltax;
     x {i} += deltax;
     x(i,j) += deltax;
     x{i,j} += deltax;

   [~,ix]=max(a);
   
                      ++st;
                 ++drows;
                ++jj;
           --llcol;

   {tolower(xyz),toupper(xyz),arg(Z),toascii([64,10,13,32,9,64])}
   printf('abc= %s','xyz');
   
   y = Z(:,1); X = [ones(rows(Z),1), Z(:,2:end)];
   if (rows (y) ~= rows (X))
   if (rows (varargin{1}) == 1 && columns (varargin{1}) > 1)
   if ((rows(x)==1)&(columns(x)>1))
   a=ones(rows(d),1);
   a=ones((rows(d(a{b(4)}))),1);
     
   vec(X)
   vec([Y{a},1;2,3])
   m=m|all(vec(X==[0,0,1;0,1,0;0,0,0]));

   mx = vec ( xx + xx' )/2;
    
    
for [k,v]=x,    
for [ k , v ] = x,    
end
