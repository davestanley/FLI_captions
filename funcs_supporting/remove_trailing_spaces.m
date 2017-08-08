
function str = remove_trailing_spaces(str)


for i = 1:length(str)

    if isempty(str{i})
        warning('Empty cell at index %d',i);
        continue;
    end
    
    % Continuously prune off trailing spaces until none left.
    lastchar = str{i}(end);
    while strcmp(lastchar,' ') && ~isempty(str{i})
        str{i} = str{i}(1:end-1);
        lastchar = str{i}(end);
    end
    
    % Throw out a warning if somehow we trimmed off everything
    if isempty(str{i})
        warning('str{i} is empty, i=%d',i);
    end
    
    
end

end