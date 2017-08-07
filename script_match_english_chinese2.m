


%%
clear
format compact
filename = 'redk0506_fixed2 copy.txt';
% filename = 'test.txt';


%%
clc

% Read in full text file
At = fgets_line_by_line(filename);

%% Classify as English or Chinese
N = length(At);
isenglish = false(1,N);
for i = 1:N
    if quantile(double(At{i}),0.75) > 120       % Generally ASCII characters above 120 are Chinese. However, the Chinese sentences have some English mixed in due to names
        isenglish(i) = false;
    else
        isenglish(i) = true;
    end
end

%% Group English and Chinese texts 1:1
A_english = At(isenglish);
A_Chin = At(~isenglish);

%% Chunk contiguous blocks of English and Chinese text together
% Group chunks of English text together.
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
    elseif isenglish(i) && ~isenglish(i-1) % Is English and prev was English - Append
        AE{j1} = [AE{j1} ' ' At{i}];
    elseif ~isenglish(i) && isenglish(i-1) % Is Chinese & prev was english
        j2=j2+1;
        AC{j2} = At{i};
    elseif ~isenglish(i) && ~isenglish(i-1) % Should never reach!
        i
        AC{j1} = [AC{j2} ' ' At{i}];
        warning('Chinese chunk of text found');
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
for i = 1:length(AE)
    if ischar(AE{i}); AE{i} = strrep(AE{i},'%','%%');
    end
end

%% Load original text with times
script_get_text_only;
% This should return return Mytext and Mytimes

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