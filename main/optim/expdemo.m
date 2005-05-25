## An example of expfit in action

## Author: Paul Kienzle
## This program is public domain
x0 = 1.5; step = 0.05; xend = 5;
a = [1.3, 2]'
c = [2, -0.5]'
v = 1e-4

x = x0:step:xend;
y = exp ( x(:)  * a(:).' ) * c(:);
err = randn(size(y))*v;
plot(x,y+err);

[a_out, c_out, rms] = expfit(2, x0, step, y+err)

