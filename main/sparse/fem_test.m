% Sparse function test routing
% Copyright (C) 1998 Andy Adler.
% This code has no warranty whatsoever.
% You may do what you like with this code as long as you leave this copyright
% in place.  If you modify the code then include a notice saying so.
%
% This code comes from my thesis work. Its a finite element model
%  of the voltage distribution in a cylindrical body with current applied
%  at the boundary. The complete model was published in
%  "Electrical Impedance Tomography: Regularized Imaging and Contrast
%   Detection", A.Adler, R.Guardo, IEEE Trans Med Img, 15(2),170-179
%
% $Id$

% octave commands, but OK in matlab too   
   do_fortran_indexing= 1;
   empty_list_elements_ok = 1;

TESTTIMES= 5;
dotheplot=0;

%increase N by multiples of 4 to do a larger test
    N=  8;
%increase niveaux to do a larger test
    niveaux= [-.2:.1:.2]' ;

    pos_i= [0 1];
    elec=16;
    ELEM=[];
    NODE= [0;0];
    int=1;
    for k=1:N
      phi= (0:4*k-1)*pi/2/k;
      NODE= [NODE k/N*[sin(phi);cos(phi)]];

      ext= 2*(k*k-k+1);
      idxe=[0:k-1; 1:k];
      idxi=[0:k-1]; 
      elem= [ ext+idxe ext+2*k+[-idxe idxe] ext+rem(4*k-idxe,4*k) ...
              ext+idxe ext+2*k+[-idxe idxe] ext+rem(4*k-idxe,4*k);
              int+idxi int+2*(k-1)+[-idxi idxi] ... 
                          int+rem(4*(k-1)-idxi, 4*(k-1)+(k==1) ) ...
              ext+4*k+1+idxi ext+6*k+[1-idxi 3+idxi] ext+8*k+3-idxi ];
      for j=1:k
        r1= rem(j+k-1,3)+1;
        r2= rem(j+k,3)+1;
        r3= 6-r1-r2;
        elem([r1 r2 r3],j+k*(0:7) )= elem(:,j+k*(0:7));
      end
  
      ELEM=[ ELEM elem(:,1:(8-4*(k==N))*k) ];
      int=ext;
    end %for k=1:N
  
    MES= ext+N*4/elec*([0:elec-1]);
 
  j=pos_i(1); k=floor(j);
  MES=[MES( 1+rem( (0:elec-1)+k,elec) )+floor(MES(1:2)*[-1;1]*(j-k));
       MES( 1+rem( (1:elec)+k,elec) )+floor(MES(1:2)*[-1;1]*(j-k)) ];

  cour= [ MES(1,:)' MES(1,1+rem(elec+(0:elec-1)+pos_i*[-1;1],elec) )'; 
           ones(elec,1)*[-1 1] ];

  QQCirC= [zeros(ext-1,1);cos(2*pi*(0:4/N:elec-.01)'/elec)];
  QQCirC= 2*QQCirC/sum(abs(QQCirC));
  if exist('niveaux')
    QQCirC= QQCirC*([-1 1]*niveaux([1 length(niveaux)]))/length(niveaux);
  end
  volt= [1; zeros(elec,1)];

  ELS=rem(rem(0:elec^2-1,elec)-floor((0:elec^2-1)/elec)+elec,elec)';
  ELS=~any(rem( elec+[-1 0 [-1 0]+pos_i*[-1;1] ] ,elec)' ...
		     *ones(1,elec^2)==ones(4,1)*ELS')';


d= size(ELEM,1);       %dimentions+1
n= size(NODE,2);        %NODEs
e= size(ELEM,2);        %ELEMents     

if dotheplot
% octave commands, we use eval so it doesn't fail in Matlab
   eval('gset nokey;','1');
   fleche= [1.02 0;1.06 .05;1.06 .02;1.1 .02; ...
	  1.1 -.02; 1.06 -.02;1.06 -.05;1.02 0];
   jjj= .95;
   if ~isempty(MES)
     xy=NODE(:,MES(1,:));
   end
   xxx=zeros(3,e); xxx(:)=NODE(1,ELEM(:));
   xxx= jjj*xxx+ (1-jjj)*ones(3,1)*mean(xxx);
   yyy=zeros(3,e); yyy(:)=NODE(2,ELEM(:));
   yyy= jjj*yyy+ (1-jjj)*ones(3,1)*mean(yyy);
   plot([xxx;xxx(1,:)],[yyy;yyy(1,:)],'b', ...
           fleche*xy,fleche*[0 1;-1 0]*xy,'r');
   
   axis([ [-1.1 1.1]*max(NODE(1,:)) [-1.1 1.1]*max(NODE(2,:)) ])
end % plot mesh
if exist('niveaux')
  node=NODE;
  elem= [ELEM([1 1 2 3 ],:) ...
         ELEM([2 1 2 3],:) ELEM([3 2 1 3],:)]; 
  NODE= [node; niveaux(1)*ones(1,n) ];
  ELEM= [];
 
  for k=2:length(niveaux);
    NODE=[NODE ,[node; niveaux(k)*ones(1,n)] ];
    ELEM= [ELEM,(elem + ...
       [[(k-1)*n*ones(1,e);(k-2)*n*ones(3,e)] ...
        [(k-1)*n*ones(2,e);(k-2)*n*ones(2,e)] ...  
        [(k-1)*n*ones(3,e);(k-2)*n*ones(1,e)]] ) ];
  end %for k

  MES= MES + floor(length(niveaux)/2)*n;
  QQCirC= QQCirC*ones(1, length(niveaux)); QQCirC= QQCirC(:);
  cour(1:elec,:)= cour(1:elec,:)+ floor(length(niveaux)/2)*n;

end %if exist('niveaux')

d= size(ELEM,1);       %dimentions+1
n= size(NODE,2);        %NODEs
e= size(ELEM,2);        %ELEMents     
p= size(volt,1)-1;

CC= sparse((1:d*e),ELEM(:),ones(d*e,1), d*e, n);

sa= zeros(d*e,d);
for j=1:e
  a=  inv([ ones(d,1) NODE( :, ELEM(:,j) )' ]);
  sa(d*(j-1)+1:d*j,:)= a(2:d,:)'*a(2:d,:)/(d-1)/(d-2)/abs(det(a));
end %for j=1:ELEMs 
ridx= ones(d,1)*(1:e)*d;
ridx= ridx(:)*ones(1,d) + ones(d*e,1)*[-d+1:0];
cidx= 1:d*e;
SS= sparse( cidx'*ones(1,d), ridx, sa, d*e, d*e);

QQ=sparse(cour(1:p,:),(1:p)'*ones(1,size(cour,2)), ...
                     cour(p+1:2*p,:),n,p );


if  0 %OCTAVE
# this code uses the first syntax for
# octave sparse
   CCt=       spfun(CC,'trans');
   CCtSS=     spfun(CCt,'mul',SS);
   ZZ=        spfun(CCtSS,'mul',CC);
   ZZs=       spfun(ZZ,'extract',2,n,2,n);
   QF=        full(spfun(QQ,'extract',2,n,1,p));
   fprintf('Solving Finite Element sparse eqn, n=%d nnz=%d density=%f\n', ...
            n, nnz(ZZ), nnz(ZZ)/n^2 );
   t0= clock;
   for i=1:TESTTIMES
      VV=        spfun(ZZs,'solve',QF,2);
   end
   tasktime= etime(clock,t0);
else
   ZZ=        CC'*SS*CC;
   ZZs=       ZZ(2:n,2:n);
   QF=        full(QQ(2:n,:));
%  QF=        (QQ(2:n,:));
   fprintf('Solving Finite Element sparse eqn, n=%d nnz=%d density=%f\n', ...
            n, nnz(ZZ), nnz(ZZ)/n^2 );
   t0= clock;
   for i=1:TESTTIMES
      VV=        ZZs\QF;
   end
   tasktime= etime(clock,t0);
end


checkval= full( VV(MES(1,:),1)-VV(MES(2,:),1) );
goldvalue= [ -0.918243;  0.555779;  0.148452;  0.078826;
              0.052132;  0.040116;  0.034141;  0.031872;
              0.031279;  0.033594;  0.039429;  0.052189;
              0.078377;  0.149426;  0.596195; -1.003565];
              
rdif= sqrt(mean((checkval-goldvalue).^2)) / sqrt(mean(checkval.^2));
if rdif > 1e-5
   fprintf('Sparse FEM solution fails');
end
fprintf('Time per iteration= %f s\n', tasktime/ TESTTIMES);
fprintf('Your machine is %f faster than a 486dx100!\n',  ...
         4.45*TESTTIMES/tasktime );

#ZZt=ZZ'; tt=time; for i = 1:100; x= ZZ*ZZt; end ; (time-tt)/100
%  ans = 0.039929 % 0.52245

% 
% Results:
%    11 Nov 00: Your machine is 16.501822 faster than a 486dx100!
%
% $Log$
% Revision 1.1  2001/10/10 19:54:49  pkienzle
% Initial revision
%
% Revision 1.4  2001/04/04 02:13:46  aadler
% complete complex_sparse, templates, fix memory leaks
%
% Revision 1.3  2001/03/30 04:36:30  aadler
% added multiply, solve, and sparse creation
%
% Revision 1.2  2000/12/18 03:31:16  aadler
% Split code to multiple files
% added sparse inverse
%
% Revision 1.1  2000/11/11 02:47:11  aadler
% DLD functions for sparse support in octave
%
%
