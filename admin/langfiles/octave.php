<?php
/*************************************************************************************
 * octave.php
 * -----------
 * Author: Juan Pablo Carbajal (carbajal@ifi.uzh.ch)
 * Copyright: (c) 2012 Juan Pablo Carbajal (http://www.florian-knorn.com)
 * Release Version: 1.0.0
 * Date Started: 2012/05/22
 *
 * Octave M-file language file for GeSHi.
 * Derived from matlab.php by Florian Knorn and octave.lang for GtkSourceView.
 *
 * CHANGES
 * -------
 * 2012/05/22 (1.0.0)
 *   -  First Release
 *
 * TODO
 * -------------------------
 * Instead of keywords use groups for different type of highlight
 * http://qbnz.com/highlighter/geshi-doc.html#language-files
 *
 *************************************************************************************
 *
 *     This file is part of GeSHi.
 *
 *   GeSHi is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   GeSHi is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with GeSHi; if not, write to the Free Software
 *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 ************************************************************************************/

$language_data = array (
    'LANG_NAME' => 'GNU/Octave',
    'COMMENT_SINGLE' => array(1=> '#', 2 => '%'),
    'COMMENT_MULTI' => array('#{' => '#}', '%{' => '%}'),
    //Octave Strings
    'COMMENT_REGEXP' => array(
        2 => "/(?<![\\w\\)\\]\\}\\.])('[^\\n']*?')/"
        ),
    'CASE_KEYWORDS' => GESHI_CAPS_NO_CHANGE,
    'QUOTEMARKS' => array('"',"'"),
    'ESCAPE_CHAR' => '',
    'KEYWORDS' => array(
          // Data types
          1 => array(
           'cell', 'char ', 'double ', 'uint8', 'uint16', 'uint32', 'uint64',
           'int8','int16', 'int32', 'int64', 'logical ', 'single ', 'struct '
          ),
          // Storage type
          2 => array(
            'global ', 'persistent ', 'static '
           ),
          // Internal variables
          3 => array(
            'ans'
           ),
          // Reserved words
          4 => array(
                  'break', 'case', 'catch', 'continue', 'do', 'else',
                  'elseif','end_try_catch', 'end_unwind_protect', 'endfor',
                  'endfunction', 'endif', 'endswitch', 'endwhile', 'for',
                  'function', 'if','otherwise', 'return', 'switch ', 'try',
                  'until', 'unwind_protect', 'unwind_protect_cleanup', 'varargin',
                  'varargout', 'while'
          ),
          // Built in
          5 => array(
          'all','any','exist','is','logical','mislocked',
          'abs','acos','acosh','acot','acoth','acsc','acsch','airy','angle',
          'area','asec','asech','asin','asinh','atan','atan2','atanh',
          'auread','autumn','auwrite','axes','axis','balance','bar','bar3',
          'bar3h','barh','besselh','besseli','besselj','besselk','Bessely',
          'beta','betainc','betaln','bicg','bicgstab','bin2dec','bitand',
          'bitcmp','bitget','bitmax','bitor','bitset','bitshift','bitxor',
          'blkdiag','bone','box','brighten','builtin','bwcontr','calendar',
          'camdolly','camlight','camlookat','camorbit','campan','campos',
          'camproj','camroll','camtarget','camup','camva','camzoom','capture',
          'cart2pol','cart2sph','cat','caxis','cdf2rdf','ceil',
          'cell2struct','celldisp','cellfun','cellplot','cellstr','cgs',
          'char','chol','cholinc','cholupdate','cla','clabel','class','clc',
          'clf','clg','clock','close','colmmd','colorbar','colorcube',
          'colordef','colormap','colperm','comet','comet3','compan','compass',
          'complex','computer','cond','condeig','condest','coneplot','conj',
          'contour','contourc','contourf','contourslice','contrast','conv',
          'conv2','convhull','cool','copper','copyobj','corrcoef','cos',
          'cosh','cot','coth','cov','cplxpair','cputime','cross','csc','csch',
          'cumprod','cumsum','cumtrapz','cylinder','daspect','date','datenum',
          'datestr','datetick','datevec','dbclear','dbcont','dbdown',
          'dblquad','dbmex','dbquit','dbstack','dbstatus','dbstep','dbstop',
          'dbtype','dbup','deblank','dec2bin','dec2hex','deconv','del2',
          'delaunay','det','diag','dialog','diff','diffuse','dlmread',
          'dlmwrite','dmperm','double','dragrect','drawnow','dsearch','eig',
          'eigs','ellipj','ellipke','eomday','eps','erf','erfc','erfcx',
          'erfiny','error','errorbar','errordlg','etime','eval','evalc',
          'evalin','exp','expint','expm','eye','ezcontour','ezcontourf',
          'ezmesh','ezmeshc','ezplot','ezplot3','ezpolar','ezsurf','ezsurfc',
          'factor','factorial','fclose','feather','feof','ferror','feval',
          'fft','fft2','fftshift','fgetl','fgets','fieldnames','figure',
          'fill','fill3','filter','filter2','find','findfigs','findobj',
          'findstr','fix','flag','flipdim','fliplr','flipud','floor','flops',
          'fmin','fmins','fopen','fplot','fprintf','fread','frewind','fscanf',
          'fseek','ftell','full','funm','fwrite','fzero','gallery','gamma',
          'gammainc','gammaln','gca','gcbo','gcd','gcf','gco','get',
          'getfield','ginput','gmres','gradient','gray','graymon','grid',
          'griddata','gsvd','gtext','hadamard','hankel','hdf','helpdlg',
          'hess','hex2dec','hex2num','hidden','hilb','hist','hold','hot',
          'hsv','hsv2rgb','i','ifft','ifft2','ifftn','ifftshift','imag',
          'image','imfinfo','imread','imwrite','ind2sub','Inf','inferiorto',
          'inline','inpolygon','input','inputdlg','inputname',
          'int2str','interp1','interp2','interp3','interpft',
          'interpn','intersect','inv','invhilb','ipermute','isa','ishandle',
          'ismember','isocaps','isonormals','isosurface','j','jet','keyboard',
          'lcm','legend','legendre','light','lighting','lightingangle',
          'lin2mu','line','lines','linspace','listdlg','loadobj','log',
          'log10','log2','loglog','logm','logspace','lower','lscov','lu',
          'luinc','magic','mat2str','material','max','mean','median','menu',
          'menuedit','mesh','meshc','meshgrid','min','mod','msgbox','mu2lin',
          'NaN','nargchk','nargin','nargout','nchoosek','ndgrid','ndims',
          'newplot','nextpow2','nnls','nnz','nonzeros','norm','normest','now',
          'null','num2cell','num2str','nzmax','ode113,','ode15s,','ode23s,',
          'ode23t,','ode23tb','ode45,','odefile','odeget','odeset','ones',
          'orient','orth','pagedlg','pareto','pascal','patch','pause',
          'pbaspect','pcg','pcolor','peaks','perms','permute','pi','pie',
          'pie3','pinv','plot','plot3','plotmatrix','plotyy','pol2cart',
          'polar','poly','polyarea','polyder','polyeig','polyfit','polyval',
          'polyvalm','pow2','primes','print','printdlg','printopt','prism',
          'prod','propedit','qmr','qr','qrdelete','qrinsert','qrupdate',
          'quad','questdlg','quiver','quiver3','qz','rand','randn','randperm',
          'rank','rat','rats','rbbox','rcond','real','realmax','realmin',
          'rectangle','reducepatch','reducevolume','refresh','rem','repmat',
          'reset','reshape','residue','rgb2hsv','rgbplot','ribbon','rmfield',
          'roots','rose','rot90','rotate','rotate3d','round','rref',
          'rrefmovie','rsf2csf','saveobj','scatter','scatter3','schur',
          'script','sec','sech','selectmoveresize','semilogx','semilogy',
          'set','setdiff','setfield','setxor','shading','shg','shiftdim',
          'shrinkfaces','sign','sin','single','sinh','slice','smooth3','sort',
          'sortrows','sound','soundsc','spalloc','sparse','spconvert',
          'spdiags','specular','speye','spfun','sph2cart','sphere','spinmap',
          'spline','spones','spparms','sprand','sprandn','sprandsym','spring',
          'sprintf','sqrt','sqrtm','squeeze','sscanf','stairs','std','stem',
          'stem3','str2double','str2num','strcat','strcmp','strcmpi',
          'stream2','stream3','streamline','strings','strjust','strmatch',
          'strncmp','strrep','strtok','struct','struct2cell','strvcat',
          'sub2ind','subplot','subspace','subvolume','sum','summer',
          'superiorto','surf','surf2patch','surface','surfc','surfl',
          'surfnorm','svd','svds','symmmd','symrcm','symvar','tan','tanh',
          'texlabel','text Create','textread','textwrap','tic','title','toc',
          'toeplitz','trace','trapz','tril','trimesh','trisurf','triu',
          'tsearch','uicontext Create','uicontextmenu','uicontrol',
          'uigetfile','uimenu','uiputfile','uiresume',
          'uisetcolor','uisetfont','uiwait Used','union','unique','unwrap',
          'upper','var','varargin','varargout','vectorize','view','viewmtx',
          'voronoi','waitbar','waitforbuttonpress','warndlg','warning',
          'waterfall','wavread','wavwrite','weekday','whitebg','wilkinson',
          'winter','wk1read','wk1write','xlabel','xlim','ylabel','ylim',
          'zeros','zlabel','zlim','zoom',
          'addpath','cd','clear','copyfile','delete','diary','dir','disp',
          'doc','docopt','echo','edit','fileparts','format','fullfile','help',
          'helpdesk','helpwin','home','inmem','lasterr','lastwarn','length',
          'load','lookfor','ls','matlabrc','matlabroot','mkdir','mlock',
          'more','munlock','open','openvar','pack','partialpath','path',
          'pathtool','profile','profreport','pwd','quit','rmpath','save',
          'saveas','size','tempdir','tempname','type','ver','version','web',
          'what','whatsnew','which','who','whos','workspace'
          ),
          //Function handle
          6 => array("@([A-Za-z_][A-Za-z1-9_]*)?"),
          // Boolean
          // false and true can be used as functions too.
          // Do not highlight as boolean if followed by parentheses.
          7 => array("\b([false|true])(\b(?!(\s)*\()"),
          // Decimal
          8 => array("\b([1-9][0-9]*|0)([Uu]([Ll]|LL|ll)?|([Ll]|LL|ll)[Uu]?)?\b"),
          // Floating point number
          9 => array("\b([0-9]+[Ee][-]?[0-9]+|([0-9]*\.[0-9]+|[0-9]+\.)([Ee][-]?[0-9]+)?)[fFlL]?"
           ),
          // Octal number
          10 => array("\b0[0-7]+([Uu]([Ll]|LL|ll)?|([Ll]|LL|ll)[Uu]?)?\b"),
          // Hex number
          11 => array("\b0[xX][0-9a-fA-F]+([Uu]([Ll]|LL|ll)?|([Ll]|LL|ll)[Uu]?)?\b"),
          // Reserved constants
          // Most of the constants can be used as functions too. Do not highlight
          // as constants if followed by parentheses.
          12 => array("[e|eps|(J|j|I|i)|(Inf|inf)|(NaN|nan)|NA|ones|pi|rand|randn|zeros])(\b(?!(\s)*\()"),
          // Package manager
          13 => array("(\b)pkg(?!(\s)*\()(\s)+(((un)?install|(un)?load|list|(global|local)_list|describe|prefix|(re)?build)(\b))?")
    ),
    'SYMBOLS' => array("((\.)?\+{1,2}?(?!\+) | (\.)?\-{1,2}?(?!\-) |
                (\.)?\*{1,2}?(?!\*) | (\.)?\/(?!\^) |
                (\.)?\\(?!\^) | (\.)?\^(?!\^) |
                (?&lt;=[0-9a-zA-Z_)\]}])(\.)?' | &lt;=? |
                &gt;=? | != | ~= | == | &lt;&gt; |
                &amp;{1,2}?(?!&amp;) | \|{1,2}?(?!\|) | ! | ~ |
                = | : | ...)"
        ),
    'CASE_SENSITIVE' => array(
        GESHI_COMMENTS => false,
        1 => false,
        2 => false,
        3 => false,
        4 => false,
        5 => false,
        6 => false,
        7 => false,
        8 => false,
        9 => false,
        10 => false,
        11 => false,
        12 => false,
        13 => false
        ),
    'STYLES' => array(
        'KEYWORDS' => array(
            1 => 'color: #2E8B57; font-weight:bold;', // Data types
            2 => 'color: #2E8B57; font-weight:bold;', // Storage type
            3 => 'color: #0000FF;', // Internal variable
            4 => 'color: #FF0000; font-weight:bold;', // Reserved words
            5 => 'color: #008A8C;' // Built-in
            ),
        'COMMENTS' => array(
            1 => 'color: #0000FF; font-style: italic;',
            2 => 'color: #0000FF; font-style: italic;',
            'MULTI' => 'color: #0000FF; font-style: italic;'
            ),
        'ESCAPE_CHAR' => array(
            0 => ''
            ),
        'BRACKETS' => array(
            0 => 'color: #080;'
            ),
        'STRINGS' => array(
            //0 => 'color: #A020F0;'
            ),
        'NUMBERS' => array(
            0 => 'color: #33f;'
            ),
        'METHODS' => array(
            1 => '',
            2 => ''
            ),
        'SYMBOLS' => array(
            0 => 'color: #080;'
            ),
        'REGEXPS' => array(
            0 => 'color: #33f;'
            ),
        'SCRIPT' => array(
            0 => ''
            )
        ),
    'URLS' => array(
        1 => '',
        2 => '',
        3 => '',
        4 => '',
        5 => '',
        6 => '',
        7 => '',
        8 => '',
        9 => '',
        10 => '',
        11 => '',
        12 => '',
        13 => ''
        ),
    'OOLANG' => true,
    'OBJECT_SPLITTERS' => array(
        1 => '.',
        2 => '::'
        ),
    'REGEXPS' => array(
        //Complex numbers
        0 => '(?<![\\w\\/])[+-]?[\\d]*([\\d]\\.|\\.[\\d])?[\\d]*[ij](?![\\w]|\<DOT>html)'
        ),
    'STRICT_MODE_APPLIES' => GESHI_NEVER,
    'SCRIPT_DELIMITERS' => array(),
    'HIGHLIGHT_STRICT_BLOCK' => array()
);

?>
