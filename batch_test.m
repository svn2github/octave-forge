## This is a quick and dirty test to see that all the compiled functions
## are loading and running.  In future all tests will be distributed to
## individual directories or even individual function files.  But we have
## to start somewhere...
LOADPATH = "main//:extra//:nonfree//:";

disp("main/signal");
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

disp("main/general");
disp(">bitand"); assert(bitand(7,14),6);
disp(">bitor"); assert(bitor(7,14),15);
disp(">bitxor"); assert(bitxor(7,14),9);
disp(">bitmax"); assert(bitmax != 0);

disp("main/image");
b = [
   0,   1,   2,   3;
   1,   8,  12,  12;
   4,  20,  24,  21;
   7,  22,  25,  18 ];
disp(">conv2"); assert(conv2([0,1;1,2],[1,2,3;4,5,6;7,8,9]),b);
disp(">cordflt2"); assert(medfilt2(b),[0,1,2,0;1,4,12,3;4,12,20,12;0,7,20,0]);
disp(">jpgwrite"); 
x=linspace(-8,8,200);
[xx,yy]=meshgrid(x,x);
r=sqrt(xx.^2+yy.^2) + eps;
map=colormap(hsv);
Rw=Gw=Bw=z=imagesc(sin(r)./r);
Rw(:)=fix(255*map(z,1));
Gw(:)=fix(255*map(z,2));
Bw(:)=fix(255*map(z,3));
jpgwrite('test.jpg',Rw,Gw,Bw);
assert(stat("test.jpg").size,6423);
disp(">jpgread");
[Rr,Gr,Br] = jpgread('test.jpg');
assert([max(Rw(:)-Rr(:))<30,max(Gw(:)-Gr(:))<30,max(Bw(:)-Br(:))<30]);
unlink('test.jpg');

disp("main/splines");
disp(">trisolve(d,e,b)");
n=15; l=rand(n-1,1);d=rand(n,1);u=rand(n-1,1);b=rand(n,2);cl=rand;cu=rand;
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

disp("main/strings");
disp(">regexp"); assert(regexp("f(.*)uck"," firetruck "),[2,10;3,7]);
disp(">[m,b]=regexp"); 
[m,b]=regexp("f(.*)uck"," firetruck "); assert(b,"iretr");

disp("main/struct");
x.a = "hello";
disp(">getfield"); assert(getfield(x,"a"),"hello");
disp(">setfield"); x = setfield(x,"b","world");
y.a = "hello";
y.b = "world";
assert(x,y);
