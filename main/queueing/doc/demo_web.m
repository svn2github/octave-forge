## Copyright (C) 2012 Moreno Marzolla
##
## This file is part of the queueing toolbox.
##
## The queueing toolbox is free software: you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation, either version 3 of the
## License, or (at your option) any later version.
##
## The queueing toolbox is distributed in the hope that it will be
## useful, but WITHOUT ANY WARRANTY; without even the implied warranty
## of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with the queueing toolbox. If not, see <http://www.gnu.org/licenses/>

1; # not a function file

figure (1, "visible", "off"); # do not show plot window

page_screen_output(0); # avoid output pagination

N = 100; # total population size
beta = linspace(0.1,0.9,18); # population mix for class 1
D = [12 14 23 20 80 31; \
      2 20 14 90 30 33 ];
V = ones(size(D));
X1 = X1 = XX = zeros(size(beta));
R1 = R2 = RR = zeros(size(beta));
for i=1:length(beta)
  pop = [fix(beta(i)*N) N-fix(beta(i)*N)];
  [U R Q X] = qnclosedmultimva( pop, D, V );
  X1(i) = X(1,1) / V(1,1);
  X2(i) = X(2,1) / V(2,1);
  XX(i) = X1(i) + X2(i);
  R1(i) = dot(R(1,:), V(1,:));
  R2(i) = dot(R(2,:), V(2,:));
  RR(i) = N / XX(i);
endfor

## Plot throughput and response times
set(gcf,"paperorientation","landscape");
papersize=[4 3] * 0.7; margin=[0 0];
set(gcf,"papersize",papersize);
set(gcf,"paperposition", [margin papersize-margin*2]);

subplot(2,1,1);
plot(beta, X1, "--", "linewidth", 2, \
     beta, X2, ":", "linewidth", 2, \
     beta, XX, "-", "linewidth", 2 );
ylabel("Throughput");
subplot(2,1,2);
plot(beta, R1, "--", "linewidth", 2, \
     beta, R2, ":", "linewidth", 2, \
     beta, RR, "-", "linewidth", 2 );
ax = axis();
ax(3) = 0;
axis(ax);
legend({"Class 1", "Class 2", "System"}, "location","south");
xlabel("Population mix \\beta_1 for Class 1");
ylabel("Response Time");

print("web.eps", "-deps2", "-mono", "-tight");

clf;

## Plot system power
set(gcf,"paperorientation","landscape");
papersize=[4 2.5] * 0.7; margin=[0 0];
set(gcf,"papersize",papersize);
set(gcf,"paperposition", [margin papersize-margin*2]);

plot(beta, X1./R1, "--;Class 1;", "linewidth", 2, \
     beta, X2./R2, ":;Class 2;", "linewidth", 2, \
     beta, XX./RR, "-;System;", "linewidth", 2);
xlabel("Population mix \\beta_1 for Class 1");
ylabel("Power");

print("power.eps", "-deps2", "-mono", "-tight");


