## Anderson, B.D.O (1989) Controller Reduction: Concepts and Approaches, IEEE Transactions of Automatic Control

A = [ -0.161      -6.004      -0.58215    -9.9835     -0.40727    -3.982       0.0         0.0
       1.0         0.0         0.0         0.0         0.0         0.0         0.0         0.0
       0.0         1.0         0.0         0.0         0.0         0.0         0.0         0.0
       0.0         0.0         1.0         0.0         0.0         0.0         0.0         0.0
       0.0         0.0         0.0         1.0         0.0         0.0         0.0         0.0
       0.0         0.0         0.0         0.0         1.0         0.0         0.0         0.0
       0.0         0.0         0.0         0.0         0.0         1.0         0.0         0.0
       0.0         0.0         0.0         0.0         0.0         0.0         1.0         0.0     ];

B = [  1.0
       0.0  
       0.0  
       0.0  
       0.0  
       0.0  
       0.0  
       0.0 ];

C = [  0.0         0.0         6.4432e-3   2.3196e-3   7.1252e-2   1.0002      0.10455     0.99551 ];

G = ss (A, B, C);


H = [  0.0         0.0         0.0         0.0         0.55       11.0         1.32       18.0     ];

q1 = 1e-6;
q2 = 100;   # [100, 1000, 2000]

Q = q1 * H.' * H;
%Q = q1 * (H.' * H);
R = 1;

W = q2 * B * B.';
V = 1;

F = lqr (G, Q, R)
L = lqr (G.', W, V).'
%[~, L] = kalman (G, W, V)

%{
[Kr, info] = fwcfconred (G, F, L, "cf", "right")

figure (1)
T = feedback (G*Kr)
step (T, 150)
%}

figure (1)
clf

for k = 8:-1:2
  Kr = cfconred (G, F, L, k);
  T = feedback (G*Kr);
  step (T, 200)
  hold on
endfor

hold off
print -depsc2 anderson-figure1.eps

figure (2)
clf

for k = 8:-1:2
  Kr = cfconred (G, F, L, k, 'method', 'bfsr-spa');
  T = feedback (G*Kr);
  step (T, 200)
  hold on
endfor

hold off
print -depsc2 anderson-figure2.eps


figure (3)
clf

for k = 8:-1:2
  Kr = fwcfconred (G, F, L, k);
  T = feedback (G*Kr);
  step (T, 300)
  hold on
endfor

hold off
print -depsc2 anderson-figure3.eps
