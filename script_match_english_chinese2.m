


%%

addpath(genpath(fullfile('.','funcs_supporting')));
clear
clc
format compact
filename = 'redk0506_fixed2.txt';           % Fixed version with chunks still present
filename = 'redk0506_fixed2 copy.txt';      % Version after Kristy de-chunked
filename = 'redk0506_fixed3.txt';           % Dave fixed a few inconsistencies with original Asilomar text

% filename = 'test.txt';


%% Cleaning the data
clc

% Read in full text file
At = fgets_line_by_line(filename);

% Remove endline characters
At = remove_endline_char(At);

% Remove blank entries
ind = ~cellfun(@isempty,At); At = At(ind);

% Set number of trailing spaces to the end of each line to 1
At = remove_trailing_spaces(At);
At = append_N_trailing_spaces(At,1);

%% Classify as English or Chinese
N = length(At);
isenglish = false(1,N);
for i = 1:N
    if quantile(double(At{i}),0.75) > 122       % Generally ASCII characters above 122 are Chinese. However, the Chinese sentences have some English mixed in due to names
        % Line is for sure Chinese
        isenglish(i) = false;
    else
        % Line might be English. But might also be Chinese with English
        % mixed in (e.g. English names like Jaan, Stuart, Sam). For
        % starters, assume it's English.
        isenglish(i) = true;
        
        % Might need to override this. To test this assumption, look at histogram of only
        % characters that are not replicated in previous line
        if i > 1
            curr = double(At{i});
            prev = double(At{i-1});
            clc
            char(curr)
            char(prev)
            [instc,edges] = histcounts(curr(:),sort(unique([curr prev Inf])));       % Current counts (sort is not really necessary, since unique sorts by default)
            [instp,edges] = histcounts(prev(:),sort(unique([curr prev Inf])));       % Prev counts
            edges = edges(1:end-1);     % Remove Inf. Inf was included above to capture the final unique value, since we're dealing with edges, not bins.
            inst_hs = heaviside(instc - instp) .* (instc-instp);      % This should subtract off any characters that are duplicated from the previous line (e.g. letters in English names)
            inst_absdiff = abs(instc - instp);
            sum_gt_120 = sum(inst_hs(edges > 122));
            if sum(inst_absdiff) > 0        % No dividing by zero.
                fract_gt_120 = sum_gt_120 ./ sum(inst_absdiff);
                if fract_gt_120 > 0.1    
                    isenglish(i) = false; % Special case: English line is same as previous English line. In this case, it is a name that could be translated. (e.g. Stuart?)
                end
            else
                % If current line is exactly the same as the previous line,
                % assume it's Chinese
                isenglish(i) = false;
            end
        end
    end
end

clear curr prev

%% Group English and Chinese texts 1:1
A_english = At(isenglish);
A_Chin = At(~isenglish);

%% Chunk contiguous blocks of English and Chinese text together
% This will force them to be 1:1
clear AE AC % English; Chinese
j1=0;
j2=0;
% First entry is english, guaranteed
    i=1;
    j1=j1+1;
    AE{j1}=At{i};

for i = 2:N
    if isenglish(i) && ~isenglish(i-1)  % Current is english; prev was Chinese
        j1=j1+1;
        AE{j1} = At{i};
    elseif isenglish(i) && isenglish(i-1) % Is English and prev was English - Append
        %i
        %[AE{j1} ' ' At{i}]
        AE{j1} = [AE{j1} '' At{i}];
        
    elseif ~isenglish(i) && isenglish(i-1) % Is Chinese & prev was english
        j2=j2+1;
        AC{j2} = At{i};
    elseif ~isenglish(i) && ~isenglish(i-1) % Is Chinese & prev was Chinese
        %i
        %[AC{j2} ' ' At{i}]
        AC{j1} = [AC{j2} '' At{i}];
        %warning('Chinese chunk of text found');
    end
end
AC = AC';
AE = AE';
% Now, AC and AE should be 1:1
if length(AC) ~= length(AE)
    error ('Mismatch between english and chinese versions')
end

%% Convert percent signs
% Need to use %% instead of % in order to write data properly
% English
for i = 1:length(AE)
    if ischar(AE{i}); AE{i} = strrep(AE{i},'%','%%');
    end
end

% Chinese
for i = 1:length(AC)
    if ischar(AC{i}); AC{i} = strrep(AC{i},'%','%%');
    end
end

%% Load original text with times - this will be our library!
script_get_text_only;
% This should return return Mytext and Mytimes

% Remove blank entries
ind = ~cellfun(@isempty,mytext);
mytimes = mytimes(ind);
mytext = mytext(ind);

% Remove endline characters
mytext = remove_endline_char(mytext);

% Set number of trailing spaces to the end of each line to 1
mytext = remove_trailing_spaces(mytext);
mytext = append_N_trailing_spaces(mytext,1);

% Remove any blank entries that might have resulted from the above operations
ind = ~cellfun(@isempty,mytext);
mytimes = mytimes(ind);
mytext = mytext(ind);


%% Convert mytext to single long char array. Interpolate mytimes

% For each line, calculate the absolute time as a numeric
lines_t = cellfun(@datenum, mytimes, 'UniformOutput',true);

% For each line, record the location of the new line in terms of characters
lines_N = cellfun(@length,mytext(:)');
lines_N = cumsum(lines_N);
lines_N = [1, lines_N(1:end-1)];

% Rename mytext to lines
lines = mytext;

% Do the interpolation
chars = [lines{:}];
chars_N = 1:length(chars);
chars_t = interp1(lines_N,lines_t,chars_N);


%% Find the sentence start and end times

A_times = zeros(1,length(AE));

forwardtrack = 20;
backtrack = 1;

anchor = 1;

mismatch_thresh = 0;    % Number of permitted mismatches.

for i = 1:length(A_times)
    curr = AE{i};                           % Current English line
    sstart = max(1,anchor-backtrack);                                   % Starting segment is backtrack spaces before the anchor
    sstop = min(anchor+length(curr)+forwardtrack,length(chars));        % Ending segment is the length of the English line plus forwardtrack
    segment = chars(sstart:sstop);          % Take a segment from chars around the anchor that will form our search basin.
    segment_t = chars(sstart:sstop);
    
    % Sweep through segment and find number of mismatched characters at
    % each sweep value
    mismatch_norm = strfind_mismatch_norm(segment,curr);
    
    mismatch_norm(mismatch_norm > mismatch_thresh) = Inf;                  % Make any that are above threshold Infs
    [M,I] = min(mismatch_norm);
    if M >= Inf
        fprintf('Current English line: %s\nCurrent segment: %s\n AE(%d) \n',curr,segment,i);
        error('Matching English segment not found. Try increasing mismatch_thresh or evaluating text.');
    end
    
    % Record estimated time of Chinese text
    A_times(i) = segment_t(I);
    
    % Record English original and English matching text
    reconstruct{i} = segment(I:I+length(curr)-1);
    chars_I(i) = I;
    
    % Update anchor
    anchor = anchor + I + length(curr) - 1;
end





%% Find times of sentence starting and ending
NE = length(AE);
maxstarting = 20; 
clear ind
for i = 1:NE
    ind{i} = [];
%     i
%     for j = 1:length(mytext)
%         ind_temp = strfind(mytext{j},AE{i}(1:min(end-2,maxstarting)));
%         if ~isempty(ind_temp)
%             ind{i} = [ind{i}, j];
%         end
%     end

    if i == 1
        start = 1;
    else start = ind{i-1}+1;
    end
    
    for j = start:start+15             % Start from prev and search in range
        %[mytext{j} 'vs ' AE{i}(1:min(end-2,maxstarting))]
        ind_temp = strfind(mytext{j},AE{i}(1:min(end-2,maxstarting)));
        if ~isempty(ind_temp)
            %fprintf('found \n');
            ind{i} = j;
            break;          % Break out once found
        end
    end
    
end

clear reconstruct
for i = 1:length(ind)
    if ~isempty(ind{i})
        reconstruct{i} = mytext{ind{i}};
    end
end
reconstruct=reconstruct';

clear compare
mylen = 10;
for i = 1:length(ind)
    compare{i} = [AE{i}(1:min(end-2,mylen)) ' vs. ' reconstruct{i}(1:min(end,mylen))];
end
compare=compare';

%% Save the text and the times separately

[~,name,ext] = fileparts(filename);
filename_times = [name,'_times',ext];
filename_text = [name,'_text',ext];

fileID = fopen(filename_text,'w');
for i = 1:length(mytext)
    fprintf(fileID,[mytext{i} '']);
end
fclose(fileID);


fileID = fopen(filename_times,'w');
for i = 1:length(A2)
    fprintf(fileID,[A2{i} '\n']);
end
fclose(fileID);