

##
## Test conjgrad_min
optim_func = "cg_min";
printf("gonna test : %s\n",optim_func);


N = 1+floor(30*rand(1)) ;
global truemin ;
truemin = randn(N,1) ;
global offset ;
offset  = 100*randn(1) ;
global metric ;
metric = randn(2*N,N) ; 
metric = metric'*metric ;

if N>1,
  [u,d,v] = svd(metric);
  d = (0.1+[0:(1/(N-1)):1]).^2 ;
  metric = u*diag(d)*u' ;
end

function v = testfunc(x)
  global offset ;
  global truemin ;
  global metric ;
  v = sum((x{1}-truemin)'*metric*(x{1}-truemin)) + offset ;
end

function df = dtestf(x)
  global truemin ;
  global metric ;
  df = metric' * 2*(x{1}-truemin);
end

xinit = 10*randn(N,1);

[x,v,niter] = feval(optim_func, "testfunc","dtestf", xinit) ;
## [x,v,niter] = conjgrad_min("testfunc","dtestf",xinit) ;
printf("test_conjgrad_min\n");

if any(abs( x-truemin ) > 100*sqrt(eps) ) ,
  printf("NOT OK 1\n");
else
  printf("OK 1\n");
end

if  v-offset  > 1e-8 ,
  printf("NOT OK 2\n");
else
  printf("OK 2\n");
end

printf("nev=%d  N=%d  errx=%8.3g   errv=%8.3g\n",...
       niter(1),N,max(abs( x-truemin )),v-offset);

