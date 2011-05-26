## Copyright (C) 2011, José Luis García Pallero, <jgpallero@gmail.com>
##
## This file is part of OctCLIP.
##
## OctCLIP is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Script File}test_octclip
##
## This is the OctCLIP example script
## @end deftypefn




%subject polygon
clSub = [9.0 7.5
         9.0 3.0
         2.0 3.0
         2.0 4.0
         8.0 4.0
         8.0 5.0
         2.0 5.0
         2.0 6.0
         8.0 6.0
         8.0 7.0
         2.0 7.0
         2.0 7.5
         9.0 7.5];
%clipper polygon
clClip = [2.5 1.0
          7.0 1.0
          7.0 8.0
          6.0 8.0
          6.0 2.0
          5.0 2.0
          5.0 8.0
          4.0 8.0
          4.0 2.0
          3.0 2.0
          3.0 8.0
          2.5 8.0
          2.5 1.0];
%limits for the plots
clXLim = [1.5 11.75];
clYLim = [0.5  8.50];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute intersection
[clXI,clYI] = oc_polybool(clSub,clClip,'and');
%compute union
[clXU,clYU] = oc_polybool(clSub,clClip,'or');
%compute A-B
[clXA,clYA] = oc_polybool(clSub,clClip,'ab');
%compute B-A
[clXB,clYB] = oc_polybool(clSub,clClip,'ba');
%plot window for intersection
subplot(2,2,1);
plot(clXI,clYI,'r.-','markersize',10,'linewidth',3,clSub(:,1),clSub(:,2),...
     clClip(:,1),clClip(:,2));
axis('equal');
xlim(clXLim);
ylim(clYLim);
title('OctCLIP intersection');
legend('Intersection','Subject polygon','Clipper polygon',...
       'location','southeast');
%plot window for union
subplot(2,2,2);
plot(clXU,clYU,'r.-','markersize',10,'linewidth',3,clSub(:,1),clSub(:,2),...
     clClip(:,1),clClip(:,2));
axis('equal');
xlim(clXLim);
ylim(clYLim);
title('OctCLIP union');
legend('Union','Subject polygon','Clipper polygon',...
       'location','southeast');
%plot window for A-B
subplot(2,2,3);
plot(clXA,clYA,'r.-','markersize',10,'linewidth',3,clSub(:,1),clSub(:,2),...
     clClip(:,1),clClip(:,2));
axis('equal');
xlim(clXLim);
ylim(clYLim);
title('OctCLIP A-B');
legend('A-B','Subject polygon','Clipper polygon',...
       'location','southeast');
%plot window for B-A
subplot(2,2,4);
plot(clXB,clYB,'r.-','markersize',10,'linewidth',3,clSub(:,1),clSub(:,2),...
     clClip(:,1),clClip(:,2));
axis('equal');
xlim(clXLim);
ylim(clYLim);
title('OctCLIP B-A');
legend('B-A','Subject polygon','Clipper polygon',...
       'location','southeast');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%clear variables
clear cl*;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%input message
disp('Press ENTER to continue ...');
pause();
%kill and close the plot window
clf();
close();
