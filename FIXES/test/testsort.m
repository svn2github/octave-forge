function ret = testsort (func, n, idx)
  % Some test code for the speed and correctness of real sort codes.
  % Code is written to be compatiable with octave and matlab.
  % Run the code with a call something like
  %
  % >> a = testsort ('sort');
  % >> ai = testsort ('sort, [], 1);

  mintime = 0.1; % Minimum time in seconds
  runtime = 2;   % Desired runtime in seconds
  ncorr = 10000; % Number of values in the test of correctness

  % Update these values if not run on my IBM T23 with Matlab R12
  matlab_n = [100; 1000; 1e4; 1e5; 1e6];
  matlab_norm  = [1.70e-05,  2.29e-04,  2.73e-03,  3.60e-02,  5.10e-01;  
                  1.16e-05,  1.37e-04,  1.75e-03,  2.25e-02,  3.28e-01;  
                  1.07e-05,  1.29e-04,  1.66e-03,  2.21e-02,  3.08e-01;  
                  1.10e-05,  1.31e-04,  1.64e-03,  2.18e-02,  3.10e-01;  
                  1.51e-05,  1.86e-04,  2.21e-03,  3.05e-02,  4.65e-01;  
                  1.21e-05,  1.57e-04,  2.12e-03,  2.69e-02,  3.77e-01];
  
  matlab_index = [2.37e-05,  3.02e-04,  3.71e-03,  5.77e-02,  8.40e-01;  
                  1.62e-05,  1.86e-04,  2.24e-03,  3.19e-02,  4.13e-01;  
                  1.40e-05,  1.62e-04,  2.01e-03,  2.83e-02,  3.62e-01;  
                  1.51e-05,  1.63e-04,  2.00e-03,  2.81e-02,  3.60e-01;  
                  2.10e-05,  2.43e-04,  2.92e-03,  4.18e-02,  5.60e-01;  
                  1.95e-05,  2.62e-04,  3.67e-03,  5.13e-02,  6.70e-01];

  if (nargin < 1)
    error ('testsort: need to define sort function');
  end

  if (nargin < 2)
    n = [100; 1000; 1e4; 1e5; 1e6];
  else
    if (isempty(n))
      n = [100; 1000; 1e4; 1e5; 1e6];
    end
  end

  if (nargin < 3)
   idx = 0;
  end

  if (idx)
    test = ['[b, bi] = ', func , '(a);'];
  else
    test = ['b = ', func , '(a);'];
  end

  if (nargin > 3)
    error ('testsort: too many arguments');
  end

  % There are 6 tests, and this records the time for each test 
  ret = zeros(6,length(n));

  if (idx)
    fprintf('Test of the sorting function (%s) with indexing\n\n', func);
  else
    fprintf('Test of the sorting function (%s)\n\n', func);
  end

  % Test for correctness of the sorting
  ncorr = max(3,ncorr);
  a = randn(1,ncorr);  % row vector
  eval(test);
  if any (b(1:(ncorr-1)) > b(2:ncorr))
    error('testsort: incorrect sorting!!');
  end

  a = randn(ncorr,1);  % col vector
  eval(test);
  if any (b(1:(ncorr-1)) > b(2:ncorr))
    error('testsort: incorrect sorting!!');
  end

  a = randn(ncorr,10);  % matrix
  eval(test);
  if any (any(b(1:(ncorr-1),:) > b(2:ncorr,:)))
    error('testsort: incorrect sorting!!');
  end

  % Test for the sorting of Inf and NaN
  a = randn(1,ncorr);
  a(1) = Inf; a(2) = NaN; a(3) = -Inf;
  eval(test);
  if (b(1) ~= -Inf | any (b(2:(ncorr-2)) == -Inf) | b(ncorr-1) ~= Inf | ...
	any(b(2:(ncorr-2)) == Inf) | ~isnan(b(ncorr)) | ...
	any(isnan(b(2:(ncorr-2)))))
    error('testsort: NaN or Inf not correctly treated');
  end
 
  if (idx)
    % Test for stability
    for i=1:10
      a = randn(1,ncorr);
      for j=1:20
        ind = min(ncorr-1,floor(ncorr*rand(1,1) + 1));
        a(ind+1) = a(ind);
      end
      eval(test);
      same = find ( b(1:(ncorr-1)) == b(2:ncorr));
      if any(bi(same) > bi(same+1))
        error('testsort: stability not respected');
      end
    end
  end

  fprintf('    \\  N  |');
  for i=1:length(n)
    fprintf('%5.2e  ', n(i));
  end
  fprintf('\n');
  fprintf('Test \\    |\n');

  % Test a random sort first
  str = ['*sort'];
  fprintf('%-10s|', str);               % print name
  if (exist('OCTAVE_VERSION'))
    fflush(stdout);
  end
  for i = 1:length(n);
    sz = n(i);
    a = randn (sz, 1);
    % Run the test once to load things up
    eval (test);
    % Find approx runtime per iteration
    rep = 1;
    while (1)
      a = randn (sz, rep);
      t = cputime;
      eval (test);
      time = cputime - t;
      if (time > mintime)
         break;
      end
      rep = 2*rep;
    end
    nloops = max(3, round(runtime / time));
    res = zeros(1, nloops);
    for runs = 1:nloops
      t = cputime;
      eval (test);
      res(runs) = cputime - t;
    end
    speed = mean(res(2:nloops-1)) / rep;
    fprintf('%5.2e  ', speed);
    if (exist('OCTAVE_VERSION'))
      fflush(stdout);
    end
    ret(1,i) = speed;
  end
  fprintf('\n');
  
  % Descending data
  str = ['\\sort'];
  fprintf('%-10s|', str);               % print name
  if (exist('OCTAVE_VERSION'))
    fflush(stdout);
  end
  for i = 1:length(n);
    sz = n(i);
    a = [sz:-1:1]';
    % Run the test once to load things up
    eval (test);
    % Find approx runtime per iteration
    rep = 1;
    while (1)
      a = repmat([sz:-1:1]', 1, rep);
      t = cputime;
      eval (test);
      time = cputime - t;
      if (time > mintime)
         break;
      end
      rep = 2*rep;
    end
    nloops = max(3, round(runtime / time));
    res = zeros(1, nloops);
    for runs = 1:nloops
      t = cputime;
      eval (test);
      res(runs) = cputime - t;
    end
    speed = mean(res(2:nloops-1)) / rep;
    fprintf('%5.2e  ', speed);
    if (exist('OCTAVE_VERSION'))
      fflush(stdout);
    end
    ret(2,i) = speed;
  end
  fprintf('\n');
  
  % Ascending data
  str = ['/sort'];
  fprintf('%-10s|', str);               % print name
  if (exist('OCTAVE_VERSION'))
    fflush(stdout);
  end
  for i = 1:length(n);
    sz = n(i);
    a = [1:sz]';
    % Run the test once to load things up
    eval (test);
    % Find approx runtime per iteration
    rep = 1;
    while (1)
      a = repmat([1:sz]', 1, rep);
      t = cputime;
      eval (test);
      time = cputime - t;
      if (time > mintime)
         break;
      end
      rep = 2*rep;
    end
    nloops = max(3, round(runtime / time));
    res = zeros(1, nloops);
    for runs = 1:nloops
      t = cputime;
      eval (test);
      res(runs) = cputime - t;
    end
    speed = mean(res(2:nloops-1)) / rep;
    fprintf('%5.2e  ', speed);
    if (exist('OCTAVE_VERSION'))
      fflush(stdout);
    end
    ret(3,i) = speed;
  end
  fprintf('\n');
  
  % Ascending data with 3 random exchanges
  str = ['3sort'];
  fprintf('%-10s|', str);               % print name
  if (exist('OCTAVE_VERSION'))
    fflush(stdout);
  end
  for i = 1:length(n);
    sz = n(i);
    a = [1:sz]';
    % Run the test once to load things up
    eval (test);
    % Find approx runtime per iteration
    rep = 1;
    while (1)
      a = repmat([1:sz]', 1, rep);
      idx1 = min(sz,floor(sz * rand(1,3)) + 1);
      idx2 = min(sz,floor(sz * rand(1,3)) + 1);
      for j = 1:3
        tmp = a(idx1,1:rep);
        a(idx1,1:rep) = a(idx2,1:rep);
        a(idx2,1:rep) = tmp;
       end
      t = cputime;
      eval (test);
      time = cputime - t;
      if (time > mintime)
         break;
      end
      rep = 2*rep;
    end
    nloops = max(3, round(runtime / time));
    res = zeros(1, nloops);
    for runs = 1:nloops
      a = repmat([1:sz]', 1, rep);
      idx1 = min(sz,floor(sz * rand(1,3)) + 1);
      idx2 = min(sz,floor(sz * rand(1,3)) + 1);
      for j = 1:3
        tmp = a(idx1,1:rep);
        a(idx1,1:rep) = a(idx2,1:rep);
        a(idx2,1:rep) = tmp;
       end
      t = cputime;
      eval (test);
      res(runs) = cputime - t;
    end
    speed = mean(res(2:nloops-1)) / rep;
    fprintf('%5.2e  ', speed);
    if (exist('OCTAVE_VERSION'))
      fflush(stdout);
    end
    ret(4,i) = speed;
  end
  fprintf('\n');
  
  % Ascending data with 10 random values at the end
  str = ['+sort'];
  fprintf('%-10s|', str);               % print name
  if (exist('OCTAVE_VERSION'))
    fflush(stdout);
  end
  for i = 1:length(n);
    sz = n(i);
  
    a = randn(sz-10,1);
    eval(test);
    a = [b; randn(10,1)];
    % Run the test once to load things up
    eval (test);
    % Find approx runtime per iteration
    rep = 1;
    while (1)
      a = randn(sz-10,rep);
      eval(test);
      a = [b; randn(10,rep)];
      t = cputime;
      eval (test);
      time = cputime - t;
      if (time > mintime)
         break;
      end
      rep = 2*rep;
    end
    nloops = max(3, round(runtime / time));
    res = zeros(1, nloops);
    for runs = 1:nloops
      a = randn(sz-10,rep);
      eval(test);
      a = [b; randn(10,rep)];
      t = cputime;
      eval (test);
      res(runs) = cputime - t;
    end
    speed = mean(res(2:nloops-1)) / rep;
    fprintf('%5.2e  ', speed);
    if (exist('OCTAVE_VERSION'))
      fflush(stdout);
    end
    ret(5,i) = speed;
  end
  fprintf('\n');
  
  % All equal
  str = ['=sort'];
  fprintf('%-10s|', str);               % print name
  if (exist('OCTAVE_VERSION'))
    fflush(stdout);
  end
  for i = 1:length(n);
    sz = n(i);
    a = ones(sz,1);
    % Run the test once to load things up
    eval (test);
    % Find approx runtime per iteration
    rep = 1;
    while (1)
      a = ones(sz,rep);
      t = cputime;
      eval (test);
      time = cputime - t;
      if (time > mintime)
         break;
      end
      rep = 2*rep;
    end
    nloops = max(3, round(runtime / time));
    res = zeros(1, nloops);
    for runs = 1:nloops
      t = cputime;
      eval (test);
      res(runs) = cputime - t;
    end
    speed = mean(res(2:nloops-1)) / rep;
    fprintf('%5.2e  ', speed);
    if (exist('OCTAVE_VERSION'))
      fflush(stdout);
    end
    ret(6,i) = speed;
  end

  matnorms = false;
  for i=1:length(n)
    t=find(matlab_n == n(i));
    if (!isempty(t))
	matnorms=true;
	break;
    end
  end 

  if (matnorms)
      fprintf('\n\n Normalized times against Matlab R12 on an IBM T23\n\n');

      fprintf('    \\  N  |');
      for i=1:length(n)
        fprintf('%5.2e  ', n(i));
      end
      fprintf('\n');
      fprintf('Test \\    |\n');

      str = ['*sort'];
      fprintf('%-10s|', str);               % print name
      for i=1:length(n)
	t = find(matlab_n == n(i));
	if (isempty(t))
	  fprintf('NA     ');
	else
	  if (~idx)
            fprintf('%5.2e  ', ret(1,i) / matlab_norm(1,t));
          else
            fprintf('%5.2e  ', ret(1,i) / matlab_index(1,t));
          end
        end
      end
      fprintf('\n');

      str = ['\\sort'];
      fprintf('%-10s|', str);               % print name
      for i=1:length(n)
	t = find(matlab_n == n(i));
	if (isempty(t))
	  fprintf('NA     ');
	else
	  if (~idx)
            fprintf('%5.2e  ', ret(2,i) / matlab_norm(2,t));
          else
            fprintf('%5.2e  ', ret(2,i) / matlab_index(2,t));
          end
        end
      end
      fprintf('\n');

      str = ['/sort'];
      fprintf('%-10s|', str);               % print name
      for i=1:length(n)
	t = find(matlab_n == n(i));
	if (isempty(t))
	  fprintf('NA     ');
	else
	  if (~idx)
            fprintf('%5.2e  ', ret(3,i) / matlab_norm(3,t));
          else
            fprintf('%5.2e  ', ret(3,i) / matlab_index(3,t));
	  end
        end
      end
      fprintf('\n');

      str = ['3sort'];
      fprintf('%-10s|', str);               % print name
      for i=1:length(n)
	t = find(matlab_n == n(i));
	if (isempty(t))
	  fprintf('NA     ');
	else
	  if (~idx)
            fprintf('%5.2e  ', ret(4,i) / matlab_norm(4,t));
          else
            fprintf('%5.2e  ', ret(4,i) / matlab_index(4,t));
	  end
        end
      end
      fprintf('\n');

      str = ['+sort'];
      fprintf('%-10s|', str);               % print name
      for i=1:length(n)
	t = find(matlab_n == n(i));
	if (isempty(t))
	  fprintf('NA     ');
	else
	  if (~idx)
            fprintf('%5.2e  ', ret(5,i) / matlab_norm(5,t));
          else
            fprintf('%5.2e  ', ret(5,i) / matlab_index(5,t));
	  end
        end
      end
      fprintf('\n');

      str = ['=sort'];
      fprintf('%-10s|', str);               % print name
      for i=1:length(n)
	t = find(matlab_n == n(i));
	if (isempty(t))
	  fprintf('NA     ');
	else
	  if (~idx)
            fprintf('%5.2e  ', ret(6,i) / matlab_norm(6,t));
          else
            fprintf('%5.2e  ', ret(6,i) / matlab_index(6,t));
	  end
        end
      end
      fprintf('\n');
  end

  return

endfunction
