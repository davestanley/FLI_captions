
function char_out = catlines(str)

do_compare= 0;

char_out2 = [str{:}];

str = str(:)';

str_spc = repmat({' '},1,length(str));

str = [str;str_spc];

str = str(:)';

char_out = [str{:}];


if do_compare
    char_out(1:1000)        % Should have correct spacing
    char_out2(1:1000)       % Should be missing spaces where newlines occur 
end

end