## Get data from a graph on the screen.
## My use of this is to get data from scientific
## papers. In this case, you would have the PDF reader,
## or the scanned image on the screen, and get the points
##
## Usage 
## [x,y]= get_graph_data([x axis labels],[y axis labels])
##
## Example [x,y]=get_graph_data([1 10 100],[100,110,120,130])
## - Then click with mouse #1 on 1, 10, 100, then mouse #2 or #3
## - Then click with mouse #1 on 100, etc    then mouse #2 or #3
## - Then click on the data points
##
## Comments:
## - In windows, instead of mouse #1, position the mouse
##   on the point and press <Space>. Press <q> for mouse #2 or #3
## - The function will automatically detect that the x-axis
##   is in log units.
## - If you provide more x- or y- axis points, then the function
##   will probably have a more accurate fit to the graph
##

## This program is in the public domain
## Author: Andy Adler <adler@ncf.ca>

function [x,y]= get_graph_data( xaxis, yaxis )

if nargin<2
   usage('get_graph_data( xaxis, yaxis )'); 
end

[xa_x, xa_y, xa_n, x_islog]= get_ax_points( xaxis, 'x axis');
[ya_x, ya_y, ya_n, y_islog]= get_ax_points( yaxis, 'y axis');

% Based on entered points, we want to see if the axis is
% rotated (like in a scanned image, for example)
x0= 0*xa_x; x1= x0+1;
y0= 0*ya_x; y1= y0+1;
X=[xa_x,xa_y,x1,x0; ya_x,ya_y,y0,y1];
Y=[xa_n,0*xa_n;0*ya_n,ya_n];
rot_ax= X\Y;
% rot_x = [a,b;c,d; e,f;g,h] where
% x intercept of y axis is f-h 
% y intercept of x axis is g-e 

irot= inv( rot_ax(1:2,:) );
ang1= [1 0]*irot;
angx=  180/pi*atan2( ang1(2), ang1(1) );
yint= rot_ax(3,1) - rot_ax(4,1);
printf('X axis is at %5.2f degrees and intercepts Y axis at %f\n',  ...
       angx, yint );

ang1= [0 1]*irot;
angy=  180/pi*atan2( ang1(2), ang1(1) );
xint= rot_ax(4,2) - rot_ax(3,2);
printf('Y axis is at %5.2f degrees and intercepts X axis at %f\n',  ...
       angy, xint );

printf('Select points to convert. Press Mouse #2 or #3 to quit\n');
fflush(stdout);
[x,y]= grab();

% remove intercept locations
rot_ax1= rot_ax(1:3,:); rot_ax1(3,2)=rot_ax(4,2);
dconv= [x,y,x*0+1]*rot_ax1;

x= dconv(:,1);
if x_islog; x= 10.^x; end
y= dconv(:,2);
if y_islog; y= 10.^y; end

function [a_x, a_y, a_n, islog]= get_ax_points( ax_pts, ax_text);
    printf(sprintf( ...
         'click (with mouse #1) %s points, then (mouse #2)\n', ax_text));
    fflush(stdout);
    [a_x,a_y]= grab();
    if length(a_x) ~= length(ax_pts)
       error(sprintf('You specified %d %s points, but entered %d', ...
             length(ax_pts), ax_text, length(a_x) ));
    end
    islog= test_log( a_x, a_y, ax_pts, ax_text);
    if islog
       a_n= log10(ax_pts(:));
    else 
       a_n= ax_pts(:);
    end
    fflush(stdout);
endfunction
 

% Guess at whether axes are linear or logarithmic
function ll=test_log( dx, dy, dfit, ax_text )
   if any(dfit==0)
       printf(sprintf('GUESSING axis %s is LINEAR\n', ax_text));
       ll=0;
       return
   end

   if length(dx)<3
      printf(sprintf('Warning: Can t test fit using %d points', ...
            length(dx)))
% try a heuristic test for linear
      if max(dfit)/min(dfit) < 10
          printf(sprintf('GUESSING axis %s is LINEAR\n', ax_text));
          ll=0;
      else
          printf(sprintf('GUESSING axis %s is LOGARITHMIC\n', ax_text));
          ll=1;
      end
      return
   end
   dx= dx(:); dy=dy(:); dfit= dfit(:);

   [jnk, yf] = polyfit( dx, dfit, 1);
   dlinfit1= sumsq( dfit - yf );
   [jnk, yf] = polyfit( dy, dfit, 1);
   dlinfit2= sumsq( dfit - yf );
   dlinfit= min([dlinfit1, dlinfit2]);

   [jnk, yf] = polyfit( dx, log10(dfit), 1);
   dlogfit1= sumsq( log10(dfit) - yf );
   [jnk, yf] = polyfit( dy, log10(dfit), 1);
   dlogfit2= sumsq( log10(dfit) - yf );
   dlogfit= min([dlogfit1, dlogfit2]);

   if dlinfit < dlogfit
      printf(sprintf('axis %s is LINEAR\n', ax_text));
      ll=0;
   else
      printf(sprintf('axis %s is LOGARITHMIC\n', ax_text));
      ll=1;
   end

   fflush(stdout);
endfunction

