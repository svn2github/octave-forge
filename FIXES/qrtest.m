
1; # make it a script
'next'
function testqr(q,r,a,p)
  if (rows(a)<columns(a)) s='wide '; else s='tall '; endif
  if (isreal(a)) t='real '; else t='complex '; endif
  if (nargin == 3)
     disp(['straight ', s, t]);
     printf("|q*r-a|      =%g\n",norm(q*r-a));
     printf("|q'*q-I|     =%g\n",norm(q'*q-eye(columns(q))));
  else
     disp(['permuted ', s, t]);
     if (is_vector(p))
        printf("|q*r-a(:,p)| =%g\n",norm(q*r-a(:,p)));
     else
	printf("|q*r-a*p|    =%g\n", norm(q*r - a*p));
     endif
     printf("|q'*q-I|     =%g\n", norm(q'*q-eye(columns(q))));
  endif
  fflush(stdout);
endfunction

disp('economy');
a = rand(5000,20);
[q,r]=qr(a,0); testqr(q,r,a);
[q,r]=qr(a',0); testqr(q,r,a');
[q,r,p]=qr(a,0); testqr(q,r,a,p);
[q,r,p]=qr(a',0); testqr(q,r,a',p);

a = a+1i*randn(size(a))*sqrt(eps);
[q,r]=qr(a,0); testqr(q,r,a);
[q,r]=qr(a',0); testqr(q,r,a');
[q,r,p]=qr(a,0); testqr(q,r,a,p);
[q,r,p]=qr(a',0); testqr(q,r,a',p);

disp('full');
a = [ ones(1,15); sqrt(eps)*eye(15) ];
[q,r]=qr(a); testqr(q,r,a);
[q,r]=qr(a'); testqr(q,r,a');
[q,r,p]=qr(a); testqr(q,r,a,p);
[q,r,p]=qr(a'); testqr(q,r,a',p);

a = a+1i*randn(size(a))*sqrt(eps);
[q,r]=qr(a); testqr(q,r,a);
[q,r]=qr(a'); testqr(q,r,a');
[q,r,p]=qr(a); testqr(q,r,a,p);
[q,r,p]=qr(a'); testqr(q,r,a',p);

clear testqr
