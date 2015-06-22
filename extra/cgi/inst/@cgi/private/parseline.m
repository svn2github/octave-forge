% Content-Type: multipart/form-data; boundary=AaB03x
% todo: handle quotes

function [header_type,header_value,attrib] = parseline(line)

parts = strsplit(line,':');
header_type = parts{1};

parts2 = strsplit(parts{2},';');

header_value = strtrim(parts2{1});


for i = 2:length(parts2)
    parts3 = strsplit(strtrim(parts2{i}),'=');
    attrib.(strtrim(parts3{1})) = parts3{2};
end
