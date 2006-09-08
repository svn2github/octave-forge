%# a few tests for gsvd.m

A0=randn(5, 3); B0=diag([1 2 4]);
A = A0; B = B0;

disp('Full rank, 5x3 by 3x3 matrices');
disp([rank(A) rank(B) rank([A' B'])]);
[U, V, C, S, X, R] = gsvd(A, B);

D1 = zeros(5, 3); D1(1:3, 1:3) = C;
D2 = S;

if (norm(diag(C).^2+diag(S).^2 - ones(3, 1)) > 1e-6)
  error("diag(C)^2 + diag(S)^2 <> 1!");
end

if (norm((U'*A*X)-D1*R) > 1e-6)
  error ("(U'*A*X) <> C*R!");
end

if (norm((V'*B*X)-D2*R) > 1e-6)
  error ("(V'*B*X) <> S*R!");
end

disp('A 5x3 full rank, B 3x3 rank deficient');
B(2, 2) = 0;
disp([rank(A) rank(B) rank([A' B'])]);

[U, V, C, S, X, R] = gsvd(A, B);
D1 = zeros(5, 3); D1(1, 1) = 1; D1(2:3, 2:3) = C;
D2 = [zeros(2, 1) S; zeros(1, 3)];

if (norm(diag(C).^2+diag(S).^2 - ones(2, 1)) > 1e-6)
  error("diag(C)^2 + diag(S)^2 <> 1!");
end

if (norm((U'*A*X)-D1*R) > 1e-6)
  error ("(U'*A*X) <> C*R!");
end

if (norm((V'*B*X)-D2*R) > 1e-6)
  error ("(V'*B*X) <> S*R!");
end

disp('A 5x3 rank deficient, B 3x3 full rank');
B = B0;
A(:, 3) = 2*A(:, 1) - A(:, 2);

disp([rank(A) rank(B) rank([A' B'])]);

[U, V, C, S, X, R]=gsvd(A, B);

D1 = zeros(5, 3); D1(1:3, 1:3) = C;
D2 = S;

if (norm(diag(C).^2+diag(S).^2 - ones(3, 1)) > 1e-6)
  error("diag(C)^2 + diag(S)^2 <> 1!");
end

if (norm((U'*A*X)-D1*R) > 1e-6)
  error ("(U'*A*X) <> C*R!");
end

if (norm((V'*B*X)-D2*R) > 1e-6)
  error ("(V'*B*X) <> S*R!");
end

disp("A 5x3, B 3x3, [A' B'] rank deficient");
B(:, 3) = 2*B(:, 1) - B(:, 2);
disp([rank(A) rank(B) rank([A' B'])]);

[U, V, C, S, X, R]=gsvd(A, B);
D1 = zeros(5, 2); D1(1:2, 1:2) = C;
D2 = [S; zeros(1, 2)];

if (norm(diag(C).^2+diag(S).^2 - ones(2, 1)) > 1e-6)
  error("diag(C)^2 + diag(S)^2 <> 1!");
end

if (norm((U'*A*X)-D1*[zeros(2, 1) R]) > 1e-6)
  error ("(U'*A*X) <> C*R!");
end

if (norm((V'*B*X)-D2*[zeros(2, 1) R]) > 1e-6)
  error ("(V'*B*X) <> S*R!");
end

%# now, A is 3x5
A = A0.'; B0=diag([1 2 4 8 16]); B = B0;
disp('Full rank, 3x5 by 5x5 matrices');
disp([rank(A) rank(B) rank([A' B'])]);

[U, V, C, S, X, R] = gsvd(A, B);
D1 = [C zeros(3,2)];
D2 = [S zeros(3,2); zeros(2, 3) eye(2)]; 

if (norm(diag(C).^2+diag(S).^2 - ones(3, 1)) > 1e-6)
  error("diag(C)^2 + diag(S)^2 <> 1!");
end

if (norm((U'*A*X)-D1*R) > 1e-6)
  error ("(U'*A*X) <> C*R!");
end

if (norm((V'*B*X)-D2*R) > 1e-6)
  error ("(V'*B*X) <> S*R!");
end

disp('A 5x3 full rank, B 5x5 rank deficient');
B(2, 2) = 0;
disp([rank(A) rank(B) rank([A' B'])]);

[U, V, C, S, X, R] = gsvd(A, B);
D1 = zeros(3, 5); D1(1, 1) = 1; D1(2:3, 2:3) = C;
D2 = zeros(5,5); D2(1:2,2:3) = S; D2(3:4, 4:5) = eye(2);

if (norm(diag(C).^2+diag(S).^2 - ones(2, 1)) > 1e-6)
  error("diag(C)^2 + diag(S)^2 <> 1!");
end

if (norm((U'*A*X)-D1*R) > 1e-6)
  error ("(U'*A*X) <> C*R!");
end

if (norm((V'*B*X)-D2*R) > 1e-6)
  error ("(V'*B*X) <> S*R!");
end

disp('A 3x5 rank deficient, B 5x5 full rank');
B = B0;
A(3, :) = 2*A(1, :) - A(2, :);
disp([rank(A) rank(B) rank([A' B'])]);

[U, V, C, S, X, R]=gsvd(A, B);

D1 = zeros(3, 5); D1(1:3, 1:3) = C;
D2 = zeros(5,5); D2(1:3, 1:3) = S; D2(4:5, 4:5) = eye(2);

if (norm(diag(C).^2+diag(S).^2 - ones(3, 1)) > 1e-6)
  error("diag(C)^2 + diag(S)^2 <> 1!");
end

if (norm((U'*A*X)-D1*R) > 1e-6)
  error ("(U'*A*X) <> C*R!");
end

if (norm((V'*B*X)-D2*R) > 1e-6)
  error ("(V'*B*X) <> S*R!");
end

disp("A 5x3, B 5x5, [A' B'] rank deficient");
A = A0.';
A(:, 3) = 2*A(:, 1) - A(:, 2);
B(:, 3) = 2*B(:, 1) - B(:, 2);
disp([rank(A) rank(B) rank([A' B'])]);

[U, V, C, S, X, R]=gsvd(A, B);
D1 = zeros(3, 4); D1(1:3, 1:3) = C;
D2 = eye(4); D2(1:3, 1:3) = S; D2(5,:) = 0;

if (norm(diag(C).^2+diag(S).^2 - ones(3, 1)) > 1e-6)
  error("diag(C)^2 + diag(S)^2 <> 1!");
end

if (norm((U'*A*X)-D1*[zeros(4, 1) R]) > 1e-6)
  error ("(U'*A*X) <> C*R!");
end

if (norm((V'*B*X)-D2*[zeros(4, 1) R]) > 1e-6)
  error ("(V'*B*X) <> S*R!");
end


A0 = A0 +j * randn(5, 3); B0 =  B0=diag([1 2 4]) + j*diag([4 -2 -1]);
A = A0; B = B0;

disp('Complex: Full rank, 5x3 by 3x3 matrices');
disp([rank(A) rank(B) rank([A' B'])]);
[U, V, C, S, X, R] = gsvd(A, B);

D1 = zeros(5, 3); D1(1:3, 1:3) = C;
D2 = S;

if (norm(diag(C).^2+diag(S).^2 - ones(3, 1)) > 1e-6)
  error("diag(C)^2 + diag(S)^2 <> 1!");
end

if (norm((U'*A*X)-D1*R) > 1e-6)
  error ("(U'*A*X) <> C*R!");
end

if (norm((V'*B*X)-D2*R) > 1e-6)
  error ("(V'*B*X) <> S*R!");
end

disp('Complex: A 5x3 full rank, B 3x3 rank deficient');
B(2, 2) = 0;
disp([rank(A) rank(B) rank([A' B'])]);

[U, V, C, S, X, R] = gsvd(A, B);
D1 = zeros(5, 3); D1(1, 1) = 1; D1(2:3, 2:3) = C;
D2 = [zeros(2, 1) S; zeros(1, 3)];

if (norm(diag(C).^2+diag(S).^2 - ones(2, 1)) > 1e-6)
  error("diag(C)^2 + diag(S)^2 <> 1!");
end

if (norm((U'*A*X)-D1*R) > 1e-6)
  error ("(U'*A*X) <> C*R!");
end

if (norm((V'*B*X)-D2*R) > 1e-6)
  error ("(V'*B*X) <> S*R!");
end

disp('Complex: A 5x3 rank deficient, B 3x3 full rank');
B = B0;
A(:, 3) = 2*A(:, 1) - A(:, 2);

disp([rank(A) rank(B) rank([A' B'])]);

[U, V, C, S, X, R]=gsvd(A, B);

D1 = zeros(5, 3); D1(1:3, 1:3) = C;
D2 = S;

if (norm(diag(C).^2+diag(S).^2 - ones(3, 1)) > 1e-6)
  error("diag(C)^2 + diag(S)^2 <> 1!");
end

if (norm((U'*A*X)-D1*R) > 1e-6)
  error ("(U'*A*X) <> C*R!");
end

if (norm((V'*B*X)-D2*R) > 1e-6)
  error ("(V'*B*X) <> S*R!");
end

disp("Complex: A 5x3, B 3x3, [A' B'] rank deficient");
B(:, 3) = 2*B(:, 1) - B(:, 2);
disp([rank(A) rank(B) rank([A' B'])]);

[U, V, C, S, X, R]=gsvd(A, B);
D1 = zeros(5, 2); D1(1:2, 1:2) = C;
D2 = [S; zeros(1, 2)];

if (norm(diag(C).^2+diag(S).^2 - ones(2, 1)) > 1e-6)
  error("diag(C)^2 + diag(S)^2 <> 1!");
end

if (norm((U'*A*X)-D1*[zeros(2, 1) R]) > 1e-6)
  error ("(U'*A*X) <> C*R!");
end

if (norm((V'*B*X)-D2*[zeros(2, 1) R]) > 1e-6)
  error ("(V'*B*X) <> S*R!");
end

%# now, A is 3x5
A = A0.'; B0=diag([1 2 4 8 16])+j*diag([-5 4 -3 2 -1]); 
B = B0;
disp('Complex: Full rank, 3x5 by 5x5 matrices');
disp([rank(A) rank(B) rank([A' B'])]);

[U, V, C, S, X, R] = gsvd(A, B);
D1 = [C zeros(3,2)];
D2 = [S zeros(3,2); zeros(2, 3) eye(2)]; 

if (norm(diag(C).^2+diag(S).^2 - ones(3, 1)) > 1e-6)
  error("diag(C)^2 + diag(S)^2 <> 1!");
end

if (norm((U'*A*X)-D1*R) > 1e-6)
  error ("(U'*A*X) <> C*R!");
end

if (norm((V'*B*X)-D2*R) > 1e-6)
  error ("(V'*B*X) <> S*R!");
end

disp('Complex: A 5x3 full rank, B 5x5 rank deficient');
B(2, 2) = 0;
disp([rank(A) rank(B) rank([A' B'])]);

[U, V, C, S, X, R] = gsvd(A, B);
D1 = zeros(3, 5); D1(1, 1) = 1; D1(2:3, 2:3) = C;
D2 = zeros(5,5); D2(1:2,2:3) = S; D2(3:4, 4:5) = eye(2);

if (norm(diag(C).^2+diag(S).^2 - ones(2, 1)) > 1e-6)
  error("diag(C)^2 + diag(S)^2 <> 1!");
end

if (norm((U'*A*X)-D1*R) > 1e-6)
  error ("(U'*A*X) <> C*R!");
end

if (norm((V'*B*X)-D2*R) > 1e-6)
  error ("(V'*B*X) <> S*R!");
end

disp('Complex: A 3x5 rank deficient, B 5x5 full rank');
B = B0;
A(3, :) = 2*A(1, :) - A(2, :);
disp([rank(A) rank(B) rank([A' B'])]);

[U, V, C, S, X, R]=gsvd(A, B);

D1 = zeros(3, 5); D1(1:3, 1:3) = C;
D2 = zeros(5,5); D2(1:3, 1:3) = S; D2(4:5, 4:5) = eye(2);

if (norm(diag(C).^2+diag(S).^2 - ones(3, 1)) > 1e-6)
  error("diag(C)^2 + diag(S)^2 <> 1!");
end

if (norm((U'*A*X)-D1*R) > 1e-6)
  error ("(U'*A*X) <> C*R!");
end

if (norm((V'*B*X)-D2*R) > 1e-6)
  error ("(V'*B*X) <> S*R!");
end

disp("Complex: A 5x3, B 5x5, [A' B'] rank deficient");
A = A0.';
A(:, 3) = 2*A(:, 1) - A(:, 2);
B(:, 3) = 2*B(:, 1) - B(:, 2);
disp([rank(A) rank(B) rank([A' B'])]);

[U, V, C, S, X, R]=gsvd(A, B);
D1 = zeros(3, 4); D1(1:3, 1:3) = C;
D2 = eye(4); D2(1:3, 1:3) = S; D2(5,:) = 0;

if (norm(diag(C).^2+diag(S).^2 - ones(3, 1)) > 1e-6)
  error("diag(C)^2 + diag(S)^2 <> 1!");
end

if (norm((U'*A*X)-D1*[zeros(4, 1) R]) > 1e-6)
  error ("(U'*A*X) <> C*R!");
end

if (norm((V'*B*X)-D2*[zeros(4, 1) R]) > 1e-6)
  error ("(V'*B*X) <> S*R!");
end

