## Author: Joerg Specht
##
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

function [r,p]=csaps(x,y,p,xi,w)
  ## -*- texinfo -*-
  ## @deftypefn{Function File}{[@var{yi}, @var{p}] =} csaps(@var{x}, @var{y}, @var{p}, @var{xi}, @var{w}=[])
  ## @deftypefnx{Function File}{[@var{pp}, @var{p}] =} csaps(@var{x}, @var{y}, @var{p}=-1, [], @var{w}=[])
  ##
  ## Cubic spline approximation (smoothing)@*
  ## approximate [x,y] weighted w at xi
  ##
  ## @table @asis
  ## @item @var{p}<0
  ##       automatic smoothing
  ## @item @var{p}=0
  ##       maximum smoothing: straight line
  ## @item @var{p}=1
  ##       no smoothing: interpolation
  ## @end table
  ##
  ## @seealso{csapi, ppval, gcvspl}
  ## @end deftypefn

  if(nargin < 5)
    w = [];
    if(nargin < 4)
      xi = [];
      if(nargin < 3)
	p = -1;
      endif
    endif
  endif

  if(columns(x) > 1)
    x = x.';
    y = y.';
    w = w.';
  endif

  [x,i] = sort(x);
  y = y(i);

  if(p < 0)
    md = 2;
    p = 1;
  else
    md = 1;
    ## csaps uses p=[0..1]; gcvspl uses p=[Inf..0]
    p = 1/p - 1;
  endif
  if(length(xi) > 0)
    if(columns(xi) > 1)
      transposed = 1;
      xi = xi.';
    else
      transposed = 0;
    endif
    [yi,wk] = gcvspl(x,y,xi,w,[],2,md,p);
    if(transposed)
      r = yi.';
    else
      r = yi;
    endif
  else
    [D,wk] = gcvspl(x,y,x(1:length(x)-1),w,[],2,md,p,[3,2,1,0]);
    ## gcvspl() produces derivates D, mkpp() needs coefficients P
    pp = mkpp(x,[D(:,1)/6,D(:,2)/2,D(:,3),D(:,4)]);
    r = pp;
  endif
  p = 1/(wk(4)+1);

endfunction
