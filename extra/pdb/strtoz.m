function [Z,w] = strtoz(s)
#function [Z,w] = strtoz(s)
#
# Return atomic numbers Z and the corresponding number of elements w  
# in the compound.
# Input s is either a string containing the name of the
# compound or the atomic number Z.
# If s is a string matrix the compounds are read rowwise and the outputs
# Z and w are matrices whose rows correspond to the compounds read from 
# the rows of s.
# 
# in:
# s = string containing the stoichiometry of the compound (eg. AlO3)
#     or atomic number Z
# out:
# Z = vector containing the atomic numbers of the elements in compound s
# w = number atoms of each element Z of the compound

# Orig. by Veijo Honkimaki
# Modified to work with GNU Octave by Teemu Ikonen 7.4.2000
# Modified to work with string matrices 6.8.2001 - Teemu

global elements;

if isstr(s) == 1,
    if (exist("elements") != 1),
        tabfile = file_in_loadpath("elements.mat");
        load(tabfile);
    end;
    N = size(s, 1);
    #    Z = []; w = [];
    Z = 1;
    w = 1;
    try eleo = empty_list_elements_ok;
    catch eleo = 0;
    end
    try wele = warn_empty_list_elements;
    catch wele = 0;
    end
    unwind_protect
      empty_list_elements_ok = 1;
      warn_empty_list_elements = 0;
      for p = 1:N,
        r = strrep(s(p,:),'Air','N3O'); 
        r = deblank(r);
        while(r(1) == " ")
            r = r(2:length(r));
        endwhile
        component = 1;
        while length(r),
            f(1) = r(1); 
            f(2) = ' '; 
            r = r(2:length(r));
            if length(r) && islower(r(1)),
                f(2) = r(1); 
                r = r(2:length(r)); 
            end;
            if length(r) && isalnum(r(1)) && !isalpha(r(1)),
                [m,c,e,i] = sscanf(r,'%g',1); 
                r = r(i:length(r));
            else 
                m = 1; 
            end;
            i = find(elements(:,1) == f(1)); 
            j = find(elements(i,2) == f(2));
            if isempty(j), 
                error('Not a valid stoichiometry'); 
            end;
            Z(p,component) = i(j);
            w(p,component) = m;
            component++;
        endwhile
    endfor
  unwind_protect_cleanup
      empty_list_elements_ok = eleo;
      warn_empty_list_elements = wele;
  end_unwind_protect
else 
    Z = s; 
    w = ones(size(Z));
end;

endfunction        
