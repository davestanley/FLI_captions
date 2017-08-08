
function str = append_N_trailing_spaces(str,N)

% By default, append one
if nargin < 2
    N = 1;
end

for i = 1:length(str)
    
    if isempty(str{i})
        warning('Empty cell at index %d',i);
        continue;
    end

    % Append the appropriate number of spaces
    if N > 0
        str{i} = [str{i}, repmat(' ',1,N)];
    end
    
end

end