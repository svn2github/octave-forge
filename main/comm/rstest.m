%%
%% This is a simple test program to exercise the reed-solomon code
%% in octave and matlab

%% Idiot proofing. Clear all variables, and set sane defaults
if (exist('OCTAVE_VERSION'))
  clear *;
  more off;
  closeplot;
  eval('axis();');
  eval('gset nokey;');
else
  clear all;
end;

% #####
% User changeable parameters
type='binary';        %% <string> :'decimal' or 'binary': Coding of msg
msgcode='random';     %% <string> :'fixed' or 'random'  : Msg fixed or not
packets = 10;         %% <int>    : > 1                 : Num of packets
m=8;                  %% <int>    : 2 < m < 16          : Bits per symbol
k=223;                %% <int>    : < 2^m -1            : Msg length
errtype='random';     %% <string> :'fixed' or 'random'  : Type of Error
errpercent=0.02;      %% <float>  : [0:1)               : % of errors

%% Note if m=8 and k=223, also test CCSDS coding in octave

% End user changeable parameters
% #####

%% MATLAB is completely stuffed for 'decimal' formats. rsenco can
%% only treat a single packet and rsdeco gets dimension errors!!!!
if (strcmp(type, 'decimal') & ~exist('OCTAVE_VERSION'))
  error('Can not have more than one packet in decimal mode');
end
  
%% We'll be timing the speed of the simulator. So store the start time
tcpu=cputime;
tic;

%% Derive the message length
n=2^m-1;

pol = gfprimdf(m);
fprintf('Default Primitive Polynomial\n');
first = 1;
for i=1:length(pol)
  if (pol(i) ~= 0)
    if (~first)
      fprintf(' + ');
    else
      first = 0;
    end
    if (i > 2)
      if (pol(i) > 1)
        fprintf('%i x ^ %i', pol(i), i-1);
      else
        fprintf('x ^ %i', i-1);
      end
    elseif (i > 1)
      if (pol(i) > 1)
        fprintf('%i x', pol(i));
      else
        fprintf('x');
      end
    else
      fprintf('%i', pol(i));
    end
  end
end
fprintf('\n\n');

tp0 = gftuple([-1:n-1]',m);
tp1 = gftuple([-1:n-1]',pol);
fprintf('Galois Field Tuples 0:\n');
for i=1:10
  fprintf('%2i: ', i);
  for j=1:m
    fprintf('%i ', tp0(i,j));
  end
  fprintf('\n');
end
fprintf('\n');
fprintf('Galois Field Tuples 1:\n');
for i=1:10
  fprintf('%2i: ', i);
  for j=1:m
    fprintf('%i ', tp1(i,j));
  end
  fprintf('\n');
end
fprintf('\n\n');

Gg0 = rspoly(n,k);
Gg1 = rspoly(n,k,tp0);
if (exist('OCTAVE_VERSION'))
  %% This form doesn't exist in matlab
  Gg2 = rspoly(k,pol);
end
Gg2=Gg1;
fprintf('Generator Polynomial:\n');
fprintf('Gg0: ');
first = 1;
for i=1:length(Gg0)
  if (Gg0(i) ~= 0)
    if (~first)
      fprintf(' + ');
    else
      first = 0;
    end
    
    if (i > 2)
      fprintf('%i x ^ %i', Gg0(i), i-1);
    elseif (i > 1)
      fprintf('%i x', Gg0(i));
    else
      fprintf('%i', Gg0(i));
    end
  end
end
fprintf('\n');
fprintf('Gg1: ');
first = 1;
for i=1:length(Gg1)
  if (Gg1(i) ~= 0)
    if (~first)
      fprintf(' + ');
    else
      first = 0;
    end
    if (i > 2)
      fprintf('%i x ^ %i', Gg1(i), i-1);
    elseif (i > 1)
      fprintf('%i x', Gg1(i));
    else
      fprintf('%i', Gg1(i));
    end
  end
end
if (exist('OCTAVE_VERSION'))
  fprintf('\n');
  fprintf('Gg2: ');
  first = 1;
  for i=1:length(Gg2)
    if (Gg1(i) ~= 0)
      if (~first)
        fprintf(' + ');
      else
        first = 0;
      end
      if (i > 2)
        fprintf('%i x ^ %i', Gg2(i), i-1);
      elseif (i > 1)
        fprintf('%i x', Gg2(i));
      else
        fprintf('%i', Gg2(i));
      end
    end
  end
end
fprintf('\n\n');

if (strcmp(type, 'decimal'))
  l=packets * k;
  if (strcmp(msgcode,'fixed'))
    msg = zeros(1,l);
    for i=0:packets-1
      msg(i*k+1:(i+1)*k) = [0:k-1];
    end
  else
    msg = randint(1,l,n);
  end
else  
  l= packets * k * m;
  if (strcmp(msgcode,'fixed'))
    msg = zeros(1,l);
    for i=0:packets-1
      for j=0:m-1
        msg(i*k*m+j+1:m:(i+1)*k*m) = (bitand([0:k-1],bitshift(1,j)));
      end
    end
    msg = (msg ~= 0);
  else
    msg = randint(1,l);
  end
end

enc0 = rsenco(msg,n,k,type);
enc1 = rsenco(msg,tp0,k,type);
enc2 = rsenco(msg,tp0,k,type,Gg0);
if (exist('OCTAVE_VERSION') & (m == 8) & (k == 223))
  %% CCSDS RS tests
  enc3 = rsenco_ccsds(msg, type);
end

fprintf('RS-encode:\n');
if (strcmp(type, 'decimal'))
  fprintf('Enc0: ');
  for i=1:n-k+3
    fprintf('%i ', enc0(i));
  end
  fprintf(' ... ');
  for i=k-3:n
    fprintf('%i ', enc0(i));
  end
  fprintf('\nEnc1: ');
  for i=1:n-k+3
    fprintf('%i ', enc1(i));
  end
  fprintf(' ... ');
  for i=k-3:n
    fprintf('%i ', enc1(i));
  end
  fprintf('\nEnc2: ');
  for i=1:n-k+3
    fprintf('%i ', enc2(i));
  end
  fprintf(' ... ');
  for i=k-3:n
    fprintf('%i ', enc2(i));
  end
  if (exist('OCTAVE_VERSION') & (m == 8) & (k == 223))
    fprintf('\nEnc CCSDS: ');
    for i=1:n-k+3
      fprintf('%i ', enc3(i));
    end
    fprintf(' ... ');
    for i=k-3:n
      fprintf('%i ', enc3(i));
    end
  end
  fprintf('\n\n');
else
  fprintf('Enc0: ');
  for i=1:n-k+3
    tmp = 0;
    for j=1:m
      if (enc0((i-1)*m+j) == 1)
        tmp = tmp + 2^(j-1);
      end
    end
    fprintf('%i ', tmp);
  end
  fprintf(' ... ');
  for i=k-3:n
    tmp = 0;
    for j=1:m
      if (enc0((i-1)*m+j) == 1)
        tmp = tmp + 2^(j-1);
      end
    end
    fprintf('%i ', tmp);
  end
  fprintf('\nEnc1: ');
  for i=1:n-k+3
    tmp = 0;
    for j=1:m
      if (enc1((i-1)*m+j) == 1)
        tmp = tmp + 2^(j-1);
      end
    end
    fprintf('%i ', tmp);
  end
  fprintf(' ... ');
  for i=k-3:n
    tmp = 0;
    for j=1:m
      if (enc1((i-1)*m+j) == 1)
        tmp = tmp + 2^(j-1);
      end
    end
    fprintf('%i ', tmp);
  end
  fprintf('\nEnc2: ');
  for i=1:n-k+3
    tmp = 0;
    for j=1:m
      if (enc2((i-1)*m+j) == 1)
        tmp = tmp + 2^(j-1);
      end
    end
    fprintf('%i ', tmp);
  end
  fprintf(' ... ');
  for i=k-3:n
    tmp = 0;
    for j=1:m
      if (enc2((i-1)*m+j) == 1)
        tmp = tmp + 2^(j-1);
      end
    end
    fprintf('%i ', tmp);
  end
  if (exist('OCTAVE_VERSION') & (m == 8) & (k == 223))
    fprintf('\nCCSDS Enc: ');
    for i=1:n-k+3
      tmp = 0;
      for j=1:m
        if (enc3((i-1)*m+j) == 1)
          tmp = tmp + 2^(j-1);
        end
      end
      fprintf('%i ', tmp);
    end
    fprintf(' ... ');
    for i=k-3:n
      tmp = 0;
      for j=1:m
        if (enc3((i-1)*m+j) == 1)
          tmp = tmp + 2^(j-1);
        end
      end
      fprintf('%i ', tmp);
    end
  end
  fprintf('\n\n');
end  

%% Introduce the errors
if (strcmp(errtype,'random'))
  %% Decimal gives burst errors of 8 bits, while binary gives random
  %% errors
  errs = (rand(n*packets,1) < errpercent);
    nerrs = sum(errs > 0) * m;
  if (strcmp(type, 'decimal'))
    errs = errs * n;
  else
    errs1 = zeros(m*n*packets,1);
    for i=1:m
      errs1(i:m:m*n*packets) = errs;
    end
    errs = errs1;
  end
else
  %% both give burst errors
  if (strcmp(type, 'decimal'))
    errs = zeros(n*packets,1);
    errs(1:1/errpercent:length(errs)) = ... 
        ones(size(1:1/errpercent:length(errs)));
    nerrs = sum(errs > 0) * m;
  else
    errs = zeros(m*n*packets,1);
    for i=1:m
      errs(i:m/errpercent:length(errs)) = ...
          ones(size(1:m/errpercent:length(errs)));
    end
    nerrs = sum(errs > 0);
  end
end
enc_err = bitxor(enc0,errs);
  
[deco0 err0 cod0 cerr0] = rsdeco(enc_err', n, k, type);
[deco1 err1 cod1 cerr1] = rsdeco(enc_err', tp0, k, type);

if (exist('OCTAVE_VERSION') & (m == 8) & (k == 223))
  enc_err3 = bitxor(enc3,errs);
  [deco2 err2 cod2 cerr2] = rsdeco_ccsds(enc_err3', type);
end

fprintf('RS-decode:\n');
fprintf('Burst Err0:');
for i=1:packets
  if (strcmp(type, 'decimal'))
    fprintf(' %i',err0((i-1)*k + 1));
  else
    fprintf(' %i',err0((i-1)*k*m + 1));
  end
end
fprintf('\n');
fprintf('Burst Err1:');
for i=1:packets
  if (strcmp(type, 'decimal'))
    fprintf(' %i',err1((i-1)*k + 1));
  else
    fprintf(' %i',err1((i-1)*k*m + 1));
  end
end
fprintf('\n');
if (exist('OCTAVE_VERSION') & (m == 8) & (k == 223))
  fprintf('Burst Err CCSDS:');
  for i=1:packets
    if (strcmp(type, 'decimal'))
      fprintf(' %i',err2((i-1)*k + 1));
    else
      fprintf(' %i',err2((i-1)*k*m + 1));
    end
  end
  fprintf('\n');
end
if (strcmp(type, 'decimal'))
  uncor0 = 0;
  uncor1 = 0;
  uncor2 = 0;
  errs0 = bitxor(deco0,msg');
  errs1 = bitxor(deco1,msg');
  if (exist('OCTAVE_VERSION') & (m == 8) & (k == 223))
    errs2 = bitxor(deco2,msg');
  end
  for i=1:k*packets
    uncor0 = uncor0 + sum(bitget(errs0(i),1:m));
    uncor1 = uncor1 + sum(bitget(errs1(i),1:m));
    if (exist('OCTAVE_VERSION') & (m == 8) & (k == 223))
      uncor2 = uncor2 + sum(bitget(errs2(i),1:m));
    end
  end
else
  uncor0 = sum(bitxor(deco0,msg'));
  uncor1 = sum(bitxor(deco1,msg'));
  if (exist('OCTAVE_VERSION') & (m == 8) & (k == 223))
    uncor2 = sum(bitxor(deco2,msg'));
  end
end
fprintf('Uncorr0: %i in %i\n', uncor0, nerrs);
fprintf('Uncorr1: %i in %i\n', uncor1, nerrs);
if (exist('OCTAVE_VERSION') & (m == 8) & (k == 223))
  fprintf('Uncorr CCSDS: %i in %i\n', uncor2, nerrs);
end
fprintf('\n');
fprintf('\n');
fprintf('CPU time: %11.2f secs, Wall Time %11.2f secs\n', ...
        cputime-tcpu, toc);

