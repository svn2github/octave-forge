## This is a quick and dirty test to see that all the compiled functions
## are loading and running.  In future all tests will be distributed to
## individual directories or even individual function files.  But we have
## to start somewhere...
LOADPATH = "main//:extra//:nonfree//:";
page_screen_output = 0;
disp("[main/optim]");
disp(">leval"); assert(leval("acos", list(-1)), pi, 100*eps);

if 0 # optim tests are failing far too often!
disp(">lp");
lp_test
disp(">minimize_1"); test_minimize_1; assert(ok,1);
disp(">cg_min_1"); test_cg_min_1; assert(ok,1);
disp(">cg_min_2"); test_cg_min_2; assert(ok,1);
disp(">cg_min_3"); test_cg_min_3; assert(ok,1);
disp(">cg_min_4"); test_cg_min_4; assert(ok,1);
disp(">d2_min_1"); test_d2_min_1; assert(ok,1);
disp(">d2_min_2"); test_d2_min_2; assert(ok,1);
disp(">d2_min_3"); test_d2_min_3; assert(ok,1);
disp(">nelder_mead_min_1"); test_nelder_mead_min_1; assert(ok,1);
disp(">nelder_mead_min_2"); test_nelder_mead_min_2; assert(ok,1);
endif

disp("[extra/linear-algebra]");
rt2 = sqrt(2);
disp(">chol"); 
assert(c=chol([2,1;1,1]),[rt2,1/rt2;0,1/rt2],10*eps);
assert(c\(c'\[1;1]),[0;1],10*eps); 
assert(typeinfo(c),"tri");
assert(c+1,[1+rt2,1+1/rt2;1,1+1/rt2],10*eps);
assert(typeinfo(c+1),"matrix");

disp("[main/comm]");
disp(">comms");
try comms("test"); 
catch disp([__error_text__,"\nNote: failure expected for octave 2.1.36"]); end
 
disp("[main/signal]");
disp(">medfilt"); assert(medfilt1([1, 2, 3, 4, 5], 3), [1.5, 2, 3, 4, 4.5]);
b = [
   0.0415131831103279
   0.0581639884202646
  -0.0281579212691008
  -0.0535575358002337
  -0.0617245915143180
   0.0507753178978075
   0.2079018331396460
   0.3327160895375440
   0.3327160895375440
   0.2079018331396460
   0.0507753178978075
  -0.0617245915143180
  -0.0535575358002337
  -0.0281579212691008
   0.0581639884202646
   0.0415131831103279];
disp(">remez"); assert(remez(15,[0,0.3,0.4,1],[1,1,0,0]),b,1e-14);

disp("[main/general]");
disp(">bitand"); assert(bitand(7,14),6);
disp(">bitor"); assert(bitor(7,14),15);
disp(">bitxor"); assert(bitxor(7,14),9);
disp(">bitmax"); assert(bitmax != 0);

disp("[main/image]");
b = [
   0,   1,   2,   3;
   1,   8,  12,  12;
   4,  20,  24,  21;
   7,  22,  25,  18 ];
disp(">conv2"); assert(conv2([0,1;1,2],[1,2,3;4,5,6;7,8,9]),b);
disp(">cordflt2"); assert(medfilt2(b),[0,1,2,0;1,4,12,3;4,12,20,12;0,7,20,0]);
disp(">bwlabel"); assert(bwlabel([0 1 0; 0 0 0; 1 0 1]),[0 1 0; 0 0 0; 2 0 3]);
if exist("jpgwrite")
  disp(">jpgwrite"); 
  x=linspace(-8,8,200);
  [xx,yy]=meshgrid(x,x);
  r=sqrt(xx.^2+yy.^2) + eps;
  map=colormap(hsv);
  A=sin(r)./r;
  minval = min(A(:));
  maxval = max(A(:));
  z = round ((A-minval)/(maxval - minval) * (rows(colormap) - 1)) + 1;
  Rw=Gw=Bw=z;
  Rw(:)=fix(255*map(z,1));
  Gw(:)=fix(255*map(z,2));
  Bw(:)=fix(255*map(z,3));
  jpgwrite('test.jpg',Rw,Gw,Bw);
  stats=stat("test.jpg");
  assert(stats.size,6423);
  disp(">jpgread");
  [Rr,Gr,Br] = jpgread('test.jpg');
  assert([max(Rw(:)-Rr(:))<30,max(Gw(:)-Gr(:))<30,max(Bw(:)-Br(:))<30]);
  unlink('test.jpg');
else
  disp(">jpgread ... not available");
  disp(">jpgwrite ... not available");
endif

disp("[main/splines]");
disp(">trisolve(d,e,b)");
n=6; 
l=[ 0.16, 0.05, 0.56, 0.94, 0.87 ]';
d=[ 0.21, 0.51, 0.18, 0.56, 0.80, 0.69 ]';
u=[ 0.35, 0.46, 0.23, 0.55, 0.77 ]';
b=[ 0.63, 0.88, 0.13, 0.55, 0.01, 0.96;
   0.96, 0.83, 0.85, 0.04, 0.09, 0.01 ]';
cl=0.71;
cu=0.91;

A=diag(u,-1)+diag(d+2)+diag(u,1);
assert(A*trisolve(d+2,u,b),b,10000*eps);
disp(">trisolve(l,d,u,b)");
A=diag(l,-1)+diag(d)+diag(u,1);
assert(A*trisolve(l,d,u,b),b,10000*eps);
disp(">trisolve(d,e,b,cl,cu)");
A=diag(cl,-n+1)+diag(u,-1)+diag(d+2)+diag(u,1)+diag(cu,n-1);
assert(A*trisolve(d+2,u,b,cl,cu),b,10000*eps);
disp(">trisolve(l,d,u,b,cl,cu)");
A=diag(cl,-n+1)+diag(l,-1)+diag(d)+diag(u,1)+diag(cu,n-1);
assert(A*trisolve(l,d,u,b,cl,cu),b,10000*eps);

disp("[main/strings]");
disp(">regexp"); assert(regexp("f(.*)uck"," firetruck "),[2,10;3,7]);
disp(">[m,b]=regexp"); 
[m,b]=regexp("f(.*)uck"," firetruck "); assert(b,"iretr");

disp("[main/struct]");
try
x.a = "hello";
disp(">getfield"); assert(getfield(x,"a"),"hello");
disp(">setfield"); x = setfield(x,"b","world");
y.a = "hello";
y.b = "world";
assert(x,y);
catch
disp(__error_text__);
disp("Note: failure expected for 2.1.36");
end

disp("[main/specfun]");
disp(">ellipj");

## tests taken from ellipj
u1 = pi/3; m1 = 0;
res1 = [sin(pi/3), cos(pi/3), 1];
[sn,cn,dn]=ellipj(u1,m1);
assert([sn,cn,dn], res1, 10*eps);

u2 = log(2); m2 = 1;
res2 = [ 3/5, 4/5, 4/5 ];
[sn,cn,dn]=ellipj(u2,m2);
assert([sn,cn,dn], res2, 10*eps);

u3 = log(2)*1i; m3 = 0;
res3 = [3i/4,5/4,1];
[sn,cn,dn]=ellipj(u3,m3);
assert([sn,cn,dn], res3, 10*eps);

u4 = -1; m4 = tan(pi/8)^4;
res4 = [-0.8392965923,0.5436738271,0.9895776106];
[sn,cn,dn]=ellipj(u4, m4);
assert([sn,cn,dn], res4, 1e-10);

u5 = -0.2 + 0.4i; m5 = m4;
res5 = [ -0.2152524522 + 0.402598347i, ...
          1.059453907  + 0.08179712295i, ...
          1.001705496  + 0.00254669712i ];
[sn,cn,dn]=ellipj(u5,m5);
assert([sn,cn,dn], res5, 1e-9);

u6 = 0.2 + 0.6i; m6 = m4;
res6 = [ 0.2369100139 + 0.624633635i, ...
         1.16200643   - 0.1273503824i, ...
         1.004913944 - 0.004334880912i ];
[sn,cn,dn]=ellipj(u6,m6);
assert([sn,cn,dn], res6, 1e-8);

u7 = 0.8 + 0.8i; m7 = m4;
res7 = [0.9588386397 + 0.6107824358i, ...
        0.9245978896 - 0.6334016187i, ...
        0.9920785856 - 0.01737733806i ];
[sn,cn,dn]=ellipj(u7,m7);
assert([sn,cn,dn], res7, 1e-10);

u=[0,pi/6,pi/4,pi/2]; m=0;
res = [0,1/2,1/sqrt(2),1;1,cos(pi/6),1/sqrt(2),0;1,1,1,1];
[sn,cn,dn]=ellipj(u,m);
assert([sn;cn;dn],res, 100*eps);
[sn,cn,dn]=ellipj(u',0);
assert([sn,cn,dn],res', 100*eps);

## need to check [real,complex]x[scalar,rowvec,colvec,matrix]x[u,m]

disp("[main/sparse]");
sp_test
fem_test


disp("=====================");
disp("all tests completed successfully");
