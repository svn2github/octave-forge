function [t y vy] = mdsim(func,tspan,x0,v0,varargin);

  %% Parse options
  m = ones (size (x0,1), 1);
  
  periodic = false;
  if ~periodic
    integrator = @(x_,v_,dt_) verletstep (x_, v_, m, dt_, @func);
  else
    integrator = @(x_,v_,dt_) verletstep_boxed (x_, v_, m, dt_, func, L);
  end
  
  dt =[];
  nT = numel (tspan);
  if nT == 2
    if isempty (dt)
      nT = 100;
      dt = (tspan(2)-tspan(1)) / (nT-1); 
    else
      nT = round ((tspan(2)-tspan(1)) / dt);
    end
  elseif nT > 2
    dt = diff (tspan);
  end
  

  
  %% Allocate
  [N dim] = size(x0);
  
  t = linspace (tspan(1), tspan(end), nT).';
  y = zeros (N, dim, nT);

  if nargout > 2
    vy = y;
    vy(:,:,1) = v0;  
  end

  %% Iterate
  y(:,:,1) = x0;
  aux = v0;
  for it = 2:nT
     [y(:,:,it) aux] = integrator (y(:,:,it-1), aux, dt);
     
     if nargout > 2
      vy(:,:,it) = aux;
     end
  end
  
  if dim == 1
    y = squeeze (y);
    if nargout > 2
      vy = squeeze (vy);
    end
  end
  
endfunction
