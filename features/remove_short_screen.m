function dataout = remove_short_screen(datain, period)

if isempty(datain)
    dataout = [];
else

    time = datain.Var1;
    state = datain.Var2;
    
    ind_include = [];
    for k = 2:length(state),
        if strcmp(state(k),'False')&&strcmp(state(k-1),'True'),  % data is stored only at transition
            if (time(k)-time(k-1) > period),
                ind_include = union(ind_include, [k-1 k]);
            end
        end
        
    end
    
    dataout = datain(ind_include, :);
    
    
end


end