## function y = fill3(x,y,z,c)
## given a polygon defined by xyz
## octave fake surface fill

## Copyright (c) 2000 Sam Sirlin
## This program is granted to the public domain.
##
## THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
## ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
## FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
## DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
## OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
## HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
## LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
## OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
## SUCH DAMAGE.

function y = fill3(x,y,z,c)

  % check current hold state
  isheld = ishold; 
  
  [rx,cx] = size(x);
  [ry,cy] = size(y);
  [rz,cz] = size(z);
  c = [cx, cy, cz] ;
  r = [rx, ry, rz] ;
  nc = max(c);
  nr = max(r);
  if any (c != nc & c != 1) || any (r != nr)
    error("fill3 x,y,z must have same shape");
  endif
  if nc > 1
    if (cx == 1), x = x(:,ones(1,nc)); endif
    if (cy == 1), y = y(:,ones(1,nc)); endif
    if (cz == 1), z = z(:,ones(1,nc)); endif
  endif
  
  unwind_protect
    gset parametric
    
    for i=1:nc
      xyz = [x(:,i), y(:,i), z(:,i)];
      
      if 1        % do borders
      	if any(xyz(1,:) != xyz(nr,:))
    	  xyz = [ xyz ; xyz(1, :) ];
      	endif
      else        % do radial lines
      	xc = sum(xyz)/nr;  % centroid
      	xyz = xyz([1:nr ; 1:nr], :);
      	xyz(2:2:2*nr, :) = xc(ones(1,nr), :);
      end
      gset linestyle 1
      gsplot xyz t ""  with lines
      hold on
    endfor
    
  unwind_protect_cleanup
    if !isheld, hold off; endif
    gset noparametric
  end_unwind_protect
  
endfunction
