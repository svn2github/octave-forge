
1;
function test(A)
  tic;
  [V,D] = eig (A);
  [invV,rcond] = inv(V);
  B = V * diag(sqrt(diag(D))) * invV;
  t = toc;
  err = norm(B^2 - A,'fro')/norm(A,'fro');
  printf('funm : time=%15f error=%15e, rcond=%15e\n', t, err, rcond);

  tic; B = sqrtm(A); t = toc;
  err = norm(B^2 - A,'fro')/norm(A,'fro');
  printf('sqrtm: time=%15f error=%15e\n', t, err);
end

disp("=== well conditioned ===");
A=rand(40);
test(A);
disp("=== ill conditioned ===");
A=triu(A);
test(A);
