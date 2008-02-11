% Copyright (C) 2008  VZLU Prague, a.s., Czech Republic
% 
% Author: Jaroslav Hajek <highegg@gmail.com>
% 
% This file is part of OctGPR.
% 
% OctGPR is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this software; see the file COPYING.  If not, see
% <http://www.gnu.org/licenses/>.
% 
% demo of Gaussian Process Regression package
1;

disp("2-dimensional GPR demo");
% define the test function (the well-known matlab "peaks")
function z = testfun(x,y)
  z = 4 + 3 * (1-x).^2 .* exp(-(x.^2) - (y+1).^2) - ...
      10 * (x/5 - x.^3 - y.^5) .* exp(-x.^2 - y.^2)- ...
      1/3 * exp(-(x+1).^2 - y.^2);

end

disp("matlab peaks surface...");
% create the mesh onto which to interpolate
t = linspace(-3,3,50);
[xi,yi] = meshgrid(t,t);

% evaluate
zi = testfun(xi,yi);
zimax = max(vec(zi)); zimin = min(vec(zi));
subplot(1,2,1);
mesh(xi,yi,zi);
pause;

disp("sampled at 400 random points");
% create 400 random samples
xs = rand(400,1); ys = rand(400,1);
xs = 6*xs-3; ys = 6*ys - 3;
% evaluate at random samples
zs = testfun(xs,ys);
xys = [xs ys];

subplot(1,2,2);
plot3(xs,ys,zs,".+");
pause;

disp("GPR model with heuristic hypers");
ths = 0.3 ./ std(xys);
GPM = gpr_train(xys,zs,ths,1e-5);
zm = gpr_predict(GPM,[vec(xi) vec(yi)]);
zm = reshape(zm,size(zi));
zm = min(zm,zimax); zm = max(zm,zimin);
subplot(1,2,2);
mesh(xi,yi,zm);
pause;

disp("GPR model with MLE training");
fflush(stdout);
GPM = gpr_train(xys,zs,ths,1e-5,{"tol",1e-5,"maxev",400,"numin",1e-8});
zm = gpr_predict(GPM,[vec(xi) vec(yi)]);
zm = reshape(zm,size(zi));
zm = min(zm,zimax); zm = max(zm,zimin);
subplot(1,2,2);
mesh(xi,yi,zm);
pause;

close
