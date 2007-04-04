function [odata,J,E,nrm]=ThDDGOXinneriteration(imesh,Dsides,...
					       Simesh,Sinodes,Sielements,SiDsides,...
					       idata,toll,maxit,ptoll,pmaxit,verbose)


## function [odata,J,E,nrm]=ThDDGOXinneriteration(imesh,Dsides,...
## 						  Simesh,Sinodes,Sielements,SiDsides,...
## 						  idata,toll,maxit,ptoll,pmaxit,verbose)
	

  global DDGOXNLPOISSON_LAP DDGOXNLPOISSON_MASS DDGOXNLPOISSON_RHS DDG_RHS DDG_MASS
  
  %%%%%%%%%%%%%%%
  %% RRE param %%
  RREnnit      = [5,1];
  RRErank      = 4;
  RREpattern   = URREcyclingpattern(RREnnit,RRErank,maxit);
  %%%%%%%%%%%%%%%

  V(:,1)=idata.V;
  Fn(:,1)=idata.Fn;
  Fp(:,1)=idata.Fp;
  n(:,1)=idata.n;
  p(:,1)=idata.p;
  Tl     =idata.Tl;
  Vthn   =idata.Vthn;
  Vthp   =idata.Vthp;

  %% Set list of nodes with Dirichelet BCs
  Dnodes = Unodesonside(imesh,Dsides);
  %% Set list of nodes with Dirichelet BCs
  SiDnodes = Unodesonside(Simesh,SiDsides);

  SiNelements  = columns(Simesh.t);
  D            = idata.D;
  
  nrm          = 1;

  for ielet=1:maxit

    if (verbose>=1)
      fprintf(1,"*** start of inner iteration number: %d\n",ielet);
    end
    
    if (verbose>=1)
      fprintf(1,"\t*** solving non linear poisson equation\n");
    end
    
    
### FIXME ###
###[Vthn,Vthp] = ThDDGOXupdatevth(Tl(:,end),n(:,end),p(:,end),idata.twn,idata.twp,J,E);
      Vthn=Tl;Vthp=Tl;

    Fnshift =  log(idata.ni) .* (1-Vthn);
    Fpshift = -log(idata.ni) .* (1-Vthp);
  
    [V(:,2),n(:,2),p(:,2)] =...
	ThDDGOXnlpoisson (imesh,Dsides,Sinodes,SiDnodes,Sielements,...
			  V(:,1),Vthn,Vthp,...
			  n(:,1),p(:,1),Fn(:,1)+Fnshift,Fp(:,1)+Fpshift,D,...
			  idata.l2,idata.l2ox,ptoll,pmaxit,verbose-1);
    
    V(Dnodes,2) = idata.V(Dnodes);
    
    if (verbose>=1)
      fprintf (1,"\t***\tupdating electron qfl\n");
    end

    ##mobn  = Ufielddepmob(Simesh,idata.un,Fn(:,1),idata.vsatn,idata.mubn);
    mobn   = idata.un .* ones(SiNelements,1); 
    n(:,3) =ThDDGOXelectron_driftdiffusion(Simesh,SiDsides,n(:,2),p(:,2),...
					   V(Sinodes,2),Vthn,mobn,...
					   inf,inf,idata.ni,idata.ni);
  
    Fn(:,2)=V(Sinodes,2) - Vthn .* log(n(:,3)) - Fnshift;
    n(SiDnodes,3) = idata.n(SiDnodes);
    Fn(SiDnodes,2) = idata.Fn(SiDnodes);
  
      
      if (verbose>=1)
	fprintf(1,"\t***\tupdating hole qfl\n");
      end
      
      ##mobp   = Ufielddepmob(Simesh,idata.up,Fp(:,1),idata.vsatp,idata.mubp);
      mobp   = idata.up .* ones(SiNelements,1); 
      p(:,3) = ThDDGOXhole_driftdiffusion(Simesh,SiDsides,n(:,3),p(:,2),...
					  V(Sinodes,2),Vthp,mobp,...
					  inf,inf,idata.ni,idata.ni);
      
      Fp(:,2)= V(Sinodes,2) + Vthp .* log(p(:,3)) - Fpshift;
      p(SiDnodes,3) = idata.p(SiDnodes);
      Fp(SiDnodes,2) = idata.Fp(SiDnodes);
      
      ## store result for RRE
      if RREpattern(ielet)>0
	Fermistore(:,RREpattern(ielet)) = [Fn(:,2);Fp(:,2)];
	if RREpattern(ielet+1)==0 % Apply RRE extrapolation
	  if (verbose>=1)		
	    fprintf(1,"\n\t**********\n\tRRE EXTRAPOLATION STEP\n\t**********\n\n");
          end
          Fermi = Urrextrapolation(Fermistore);
	  Fn(:,2) = Fermi(1:rows(Fn));
	  Fp(:,2) = Fermi(rows(Fn)+1:end);
	end
      end
	

      if (verbose>=1)
	fprintf(1,'\t***\tupdating electron current\n');
      end
      [jnx,jny] = Ufvsgcurrent2(Simesh,n(:,3),V(Sinodes,2),Vthn,mobn);
      
      if (verbose>=1)
	fprintf(1,'\t***\tupdating hole current\n');
      end

      [jpx,jpy] = Ufvsgcurrent2(Simesh,p(:,3),-V(Sinodes,2),Vthp,-mobp);
      Jn = [jnx;jny];
      Jp = [jpx;jpy];
      J = Jn+Jp;

      if (verbose>=1)
	fprintf(1,'\t***\tupdating electric field\n');
      end
      
      [Ex,Ey] = Updegrad(Simesh,-V(Sinodes,2));
      E =  [Ex;Ey];

      if (verbose>=1)
	fprintf(1,"*** checking for convergence: ");
      end
      
      nrfn= norm (Fn(:,2)-Fn(:,1),inf);
      nrfp= norm (Fp(:,2)-Fp(:,1),inf);
      nrv = norm (V(:,2)-V(:,1),inf);
      nrm(ielet) = max([nrfn;nrfp;nrv]);
      
      
      if (verbose>=1)
	fprintf (1," max(|dFn|,|dFp|,|dV| )= %g\n\n",...
		 nrm(ielet));
    end
    if (nrm(ielet)<toll)
      break
    end

    V(:,1) = V(:,2);
    n(:,1) = n(:,3);
    p(:,1) = p(:,3);
    Fn(:,1)= Fn(:,2);
    Fp(:,1)= Fp(:,2);
    
    
end

if (verbose>0)
  fprintf(1,"\n*** DD simulation over: # of Gummel iterations = %d\n\n",ielet);
end

odata = idata;

odata.n  = n(:,end);
odata.p  = p(:,end);
odata.V  = V(:,end);
odata.Fn = Fn(:,end);
odata.Fp = Fp(:,end);

