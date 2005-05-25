## This is a quick and dirty test to see that all the compiled functions
## are loading and running.  In future all tests will be distributed to
## individual directories or even individual function files.  But we have
## to start somewhere...

## Author: Paul Kienzle
## This program is public domain.

LOADPATH = "main//:extra//:nonfree//:FIXES:";

## this test could be done without the graph
demo('cheb1ord');
disp('====================');
input('confirm that the filter n stays within the design boxes:');

oneplot
clf
t = linspace(0,1,100);
plot(t,cos(2*pi*t*1.4),'b',t,sin(2*pi*t*1.4),'g');
legend('cos','sin');
input('confirm that the legend says "cos" and "sin":');

disp('click on the graph to place "hello"'); fflush(stdout);
gtext('hello');

disp('use left mouse to zoom the graph, right to unzoom, middle to exit');
fflush(stdout);
axis([0 1 0 1]);
gzoom;
