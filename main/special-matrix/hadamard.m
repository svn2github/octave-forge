% Hn = hadamard(n)
%   Construct a Hadamard matrix Hn of size n x n.  The size n must be
%   of the form 2^k*p for p=1, 12, 20 or 28.  The returned matrix is
%   normalized, meaning Hn(:,1)==1 and H(1,:)==1.
%
% Some properties of Hadamard matrices:
%   kron(Hm,Hn) is a Hadamard matrix of size m*n.
%   Hn*Hn' = n*eye(n).
%   The rows of Hn are orthogonal.
%   det(A) <= det(Hn) for all A with |A(i,j)| <= 1.
%   Multiply any row or column by -1 and still have a Hadamard matrix.
%   
% Reference [1] contains a list of Hadamard matrices up to n=256.
% See code for h28 in hadamard.m for an example of how to extend
% this function for additional p.
%
% References:
% [1] A Library of Hadamard Matrices, N. J. A. Sloane 
%     http://www.research.att.com/~njas/hadamard/

% This program is in the public domain.
function h = hadamard(n)
  %# find k if n = 2^k*p
  k = 0;
  while n>1 && floor(n/2) == n/2, k++; n=n/2; end

  %# find base hadamard
  if n!=1, k-=2; end  %# except for n=2^k, need a multiple of 4
  if k<0, n=-1; end   %# trigger error if not a multiple of 4
  switch n,
  case 1, h = 1;
  case 3, h = h12;
  case 5, h = h20;
  case 7, h = Hnormalize(h28);
  otherwise, error('n must be 2^k*p, for p = 1, 12, 20 or 28');
  end

  %# build H(2^k*n) from kron(H(2^k),H(n))
  h2 = [1,1;1,-1];
  while 1,
    if floor(k/2) != k/2, h = kron(h2,h); end;
    k = floor(k/2);
    if k == 0, break; end
    h2 = kron(h2,h2);
  end

function h = h12
  tu=[-1,+1,-1,+1,+1,+1,-1,-1,-1,+1,-1];
  tl=[-1,-1,+1,-1,-1,-1,+1,+1,+1,-1,+1];
  %note: assert(tu(2:end),tl(end:-1:2))
  h = ones(12);
  h(2:end,2:end) = toeplitz(tu,tl);

function h = h20
  tu=[+1,-1,-1,+1,+1,+1,+1,-1,+1,-1,+1,-1,-1,-1,-1,+1,+1,-1,-1];
  tl=[+1,-1,-1,+1,+1,-1,-1,-1,-1,+1,-1,+1,-1,+1,+1,+1,+1,-1,-1];
  %note: assert(tu(2:end),tl(end:-1:2))
  h = ones(20);
  h(2:end,2:end) = fliplr(toeplitz(tu,tl));

function h = Hnormalize(h)
  % Make sure each row starts with +1
  for i=find(h(:,1)==-1), h(i,:) *= -1; end
  for i=find(h(1,:)==-1), h(:,i) *= -1; end

function h = h28
  % Williamson matrix construction from
  % http://www.research.att.com/~njas/hadamard/had.28.will.txt
  s=['+------++----++-+--+-+--++--';
     '-+-----+++-----+-+--+-+--++-';
     '--+-----+++---+-+-+----+--++';
     '---+-----+++---+-+-+-+--+--+';
     '----+-----+++---+-+-+++--+--';
     '-----+-----++++--+-+--++--+-';
     '------++----++-+--+-+--++--+';
     '--++++-+-------++--+++-+--+-';
     '---++++-+-----+-++--+-+-+--+';
     '+---+++--+----++-++--+-+-+--';
     '++---++---+----++-++--+-+-+-';
     '+++---+----+----++-++--+-+-+';
     '++++--------+-+--++-++--+-+-';
     '-++++--------+++--++--+--+-+';
     '-+-++-++--++--+--------++++-';
     '+-+-++--+--++--+--------++++';
     '-+-+-++--+--++--+----+---+++';
     '+-+-+-++--+--+---+---++---++';
     '++-+-+-++--+------+--+++---+';
     '-++-+-+-++--+------+-++++---';
     '+-++-+---++--+------+-++++--';
     '-++--++-+-++-+++----++------';
     '+-++--++-+-++-+++-----+-----';
     '++-++---+-+-++-+++-----+----';
     '-++-++-+-+-+-+--+++-----+---';
     '--++-++++-+-+----+++-----+--';
     '+--++-+-++-+-+----+++-----+-';
     '++--++-+-++-+-+----++------+'];
  h=(s=='+');
  h(!h)=-1;


%!assert(hadamard(1),1)
%!assert(hadamard(2),[1,1;1,-1])
%!test
%!  for n=[1,2,4,8,12,24,48,20,28,2^9]
%!    h=hadamard(n); assert(norm(h*h'-n*eye(n)),0);
%!  end
