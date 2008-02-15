function FPL2ptcshowmesh (varargin)

  ## -*- texinfo -*-
  ## @deftypefn {Function File} {} FPL2ptcshowmesh (@var{mesh1}, @
  ## @var{color1}, @ [@var{mesh2}, @var{color2}, ...])
  ## 
  ## Displays two or more 2-D triangulations using opendx
  ##
  ## @seealso{FPL2pdeshowmesh}
  ## @end deftypefn

  ## This file is part of 
  ##
  ##            FPL
  ##            Copyright (C) 2004-2007  Carlo de Falco
  ##
  ##
  ##
  ##  FPL is free software; you can redistribute it and/or modify
  ##  it under the terms of the GNU General Public License as published by
  ##  the Free Software Foundation; either version 2 of the License, or
  ##  (at your option) any later version.
  ##
  ##  FPL is distributed in the hope that it will be useful,
  ##  but WITHOUT ANY WARRANTY; without even the implied warranty of
  ##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ##  GNU General Public License for more details.
  ##
  ##  You should have received a copy of the GNU General Public License
  ##  along with FPL; If not, see <http://www.gnu.org/licenses/>.
  
  datalist = "";
  colorlist= "";

  for ii=1:2:nargin
    dataname{ii} = mktemp("/tmp",".dx");
    FPL2dxoutputdata(dataname{ii},varargin{ii}.p,varargin{ii}.t,...
		     varargin{ii}.p(1,:)','x',0,1,1);
    datalist = strcat (datalist, """", dataname{ii} ,"""");
    colorlist= strcat (colorlist, """", varargin{ii+1} ,"""");
  end
  scriptname = mktemp("/tmp",".net");
  
  showmesh = file_in_path(path,"FPL2ptcshowmesh.net");
  
  system (["cp " showmesh " " scriptname]);
  system (["sed -i \'s|""FILELIST""|" datalist "|g\' " scriptname]);
  system (["sed -i \'s|""COLORLIST""|" colorlist "|g\' " scriptname]);

  command = ["dx  -noConfirmedQuit -program " scriptname " -execute -image  >& /dev/null & "];  
  system(command);


  function filename = mktemp (direct,ext);

    if (~exist(direct,"dir"))
      error("trying to save temporary file to non existing directory")
    end

    done=false;

    while ~done
      filename = [direct,"/FPL.",num2str(floor(rand*1e7)),ext];
      if ~exist(filename,"file")
	done =true;
      end
    end
  endfunction