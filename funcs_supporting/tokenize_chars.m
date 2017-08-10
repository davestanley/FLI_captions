

function str3 = tokenize_chars(str1)

Lstr1=length(str1);

str_space='\s';
str_caps='[A-Z]';
str_ch='[a-z]';
str_nums='[0-9]';

ind_space=regexp(str1,str_space);
ind_caps=regexp(str1,str_caps);
ind_chrs=regexp(str1,str_ch);
ind_nums=regexp(str1,str_nums);
mask=[ind_space ind_caps ind_chrs ind_nums];

num_str2=1:1:Lstr1;
num_str2(mask)=[];

str3=str1;
str3(num_str2)=[];

str3 = lower(str3);

end