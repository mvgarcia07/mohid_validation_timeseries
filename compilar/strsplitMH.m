function [s, ncol] = strsplitMH(str);
%splits a string into an array of strings
%considering the delimiter as space
%MOHID Water Modelling System.
%Copyright (C) 1985, 1998, 2002, 2006. 
%MARETEC, Instituto Superior Técnico, Technical University of Lisbon. 

    h = double(str);
  
    n = size(h,2);
    ncol = 0;
    hasname = false;

    for i=1:n;
        if h(i)==32;
            if hasname;
                endi = i;
                ncol = ncol + 1;
                name = char(h(starti:endi));              
                s(ncol) = cellstr(name);
            end 
            hasname = false;
            
        elseif h(i)==13;
            if hasname;
                endi = i;
                ncol = ncol + 1;
                name = char(h(starti:endi));              
                s(ncol) = cellstr(name);
            end 
            hasname = false;
        else
            if ~hasname;
                starti = i;
            end
            hasname = true;
        end
    end
end 