function mismatch_norm = strfind_mismatch_norm(segment,curr)

N=length(segment)-length(curr)+1;
mismatch_norm = zeros(1,N);
for j = 1:N
    seg_curr = segment(j:j+length(curr)-1);
    temp = ~arrayfun(@isequal,double(seg_curr),double(curr));          % 1 for mismatching chars; 0 for matching
    mismatch_norm(j) = sum(temp);                                      % Total number of mismatching characters for this sweep
end

end