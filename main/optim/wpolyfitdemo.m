pin = [3 -1 2]'
x = [-3:0.1:3];
y = polyval(pin,x);
dy = sqrt(y);
y = y+randn(size(y)).*dy;
wpolyfit(x,y,dy,2)

