function name=file_in_path(p,file)
  idx=[1 findstr(p,pathsep) length(p)+1];
  for i=1:length(idx)-1
    if idx(i+1)-idx(i)<=1, continue; end
    dir=p(idx(i)+1:idx(i+1)-1);
    name = fullfile(dir, file);
    fid = fopen(name,"r");
    if fid >= 0,
      fclose(fid);
      return
    end
  end
  name=[];