
function str = remove_endline_char(str)


endlinechar1 = char(13);     % ASCII code for endline character is 13
endlinechar2 = char(10);     % ASCII code for endline character is also 10

str = cellfun(@(s) strrep(s,endlinechar1,''),str,'UniformOutput',false);
str = cellfun(@(s) strrep(s,endlinechar2,''),str,'UniformOutput',false);

end