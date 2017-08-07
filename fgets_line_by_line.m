

function tlines = fgets_line_by_line(filename,maxlines)

    if nargin < 2
        maxlines = Inf;
    end

    fileID = fopen(filename,'r');
    tline = fgets(fileID,Inf);
    tlines = {};
    Nlines = 0;
    while ischar(tline) && Nlines < maxlines
        tlines{end+1,1} = tline;
        tline = fgets(fileID,Inf);
        Nlines =  Nlines + 1;
    end


end