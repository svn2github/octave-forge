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

printf('click (with mouse #1) x axis points, then (mouse #2)\n');
fflush(stdout);
[xa_x,xa_y]= grab();
if length(xa_x) ~= length(xaxis)
   error(sprintf('You specified %d xaxis points, but entered %d', ...
         length(xaxis), length(xa_x) ));
end
x_islog= test_log( xa_x, xa_y, xaxis, 'x axis');


printf('click (with mouse #1) y axis points, then (mouse #2)\n');
fflush(stdout);
[ya_x,ya_y]= grab();
if length(ya_x) ~= length(yaxis)
   error(sprintf('You specified %d yaxis points, but entered %d', ...
         length(yaxis), length(ya_x) ));
end
y_islog= test_log( ya_x, ya_y, yaxis, 'y axis');
 

function ll=test_log( dx, dy, dfit, ax_test )
   if length(dx)<3
      warn(sprintf('Can t test linear or log fit using %d points', ...
            length(dx)))
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
      printf(sprintf('axis %s is LINEAR\n', ax_test));
      ll=0;
   else
      printf(sprintf('axis %s is LOGARITHMIC\n', ax_test));
      ll=1;
   end
endfunction

