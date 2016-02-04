clear;
close all;

for num = 1:9999999,
    
    x{num} = mMD5(sprintf('%010d',num));
    
end