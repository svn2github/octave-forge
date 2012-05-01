u = [    0;   0.5;     1;     1;     1;     1;     1 ];
y = [    0;     0;  0.25;  0.62;  0.81;  0.90;  0.95 ];

dat = iddata (y, u)

sys = arx (dat, 1, 1)


ysim = lsim (sys(1,1), u);

