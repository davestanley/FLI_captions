
%%

filename = 'Asilomar_Superintelligence.txt';
% filename = 'test.txt';


%%
clc

% Read in full text file
A = fgets_line_by_line(filename);



%% All lines of text begin with time information. Remove this
mytext = {};           % "A no time"
mytimes = {};
for i = 1:length(A)
    ind = strfind(A{i},':');
    if ~isempty(ind)
        mytext{i,1} = A{i}(ind+3:end);
        mytimes{i,1} = A{i}(1:ind+2);
    end
end


%% Convert percent signs
% Need to use %% instead of % in order to write properly
for i = 1:length(mytext)
    if ischar(mytext{i}); mytext{i} = strrep(mytext{i},'%','%%');
    end
end

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
for i = 1:length(mytext)
    fprintf(fileID,[mytimes{i} '\n']);
end
fclose(fileID);
