function [odata,it,res] = ThDDGOXgummelmap (imesh,Dsides,...
					    Simesh,Sinodes,Sielements,SiDsides,...
					    idata,toll,maxit,ptoll,pmaxit,thtol,thmaxit,...
					    verbose)

##   [odata,it,res] = ThDDGOXgummelmap (imesh,Dsides,...
## 				     Simesh,Sinodes,Sielements,SiDsides,...
## 				     idata,toll,maxit,ptoll,pmaxit,thtol,thmaxit,...
## 				     verbose) 
  
  clear DDGOXNLPOISSON_LAP DDGOXNLPOISSON_MASS DDGOXNLPOISSON_RHS DDG_RHS DDG_MASS
  global DDGOXNLPOISSON_LAP DDGOXNLPOISSON_MASS DDGOXNLPOISSON_RHS DDG_RHS DDG_MASS

  %% Set list of nodes with Dirichelet BCs
  Dnodes = Unodesonside(imesh,Dsides);
  %% Set list of nodes with Dirichelet BCs
  SiDnodes = Unodesonside(Simesh,SiDsides);

  Tl(:,1)  = idata.Tl;
  eletdata = idata;
  nrm      = 1;
  innernrm = [];

  for ith=1:thmaxit
    
    eletdata.Tl  = Tl(:,1);
    
    if (verbose>=1)
      fprintf(1,'\n***\n***\tupdating potentials\n***\n');
    end
    
    [eletdata,J,E,innrm]=ThDDGOXinneriteration(imesh,Dsides,...
					       Simesh,Sinodes,Sielements,SiDsides,...
					       eletdata,toll,maxit,ptoll,pmaxit,verbose);
    
    innernrm = [innernrm,innrm];

    if (verbose>=1)
      fprintf(1,'***\n***\tupdating lattice temperature\n***\n');
    end
    
    Tl(:,2)   = ThDDGOXheatequation (Simesh,SiDnodes,idata.kappa,J,E,Tl(:,1));
    
    tldampcoef = 1;
    dtlnrm     = norm(Tl(:,2)-Tl(:,1),inf);
    tldampfact = log(1+tldampcoef*dtlnrm)/(tldampcoef*dtlnrm);
    Tl(:,2)    = tldampfact * Tl(:,2) + (1-tldampfact) * Tl(:,1); 
    
    if (verbose>=1)
      fprintf(1,"\n***\n***\tchecking for convergence: ");
    end
    
    nrm(ith) = dtlnrm;
    
    if (verbose>=1)
      fprintf (1,"|dT|= %g\n***\n",nrm(ith));
      if (verbose>1)
	figure(2);
	semilogy(nrm)
	pause(.1)
      end
    end

    if (nrm(ith)<thtol)
      break
    end
    
    Tl(:,1)= Tl(:,2);
    
  end
  
  res = {nrm,innernrm};
  
  if (verbose>0)
    fprintf(1,"\n***\n***\tThDD simulation over: # of Gummel iterations = %d\n***\n",ith);
  end
  
  odata    = eletdata;
  odata.Tl = Tl(:,2);

