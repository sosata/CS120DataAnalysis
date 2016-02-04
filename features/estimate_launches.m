function launches = estimate_launches(app)

if length(app{1})>1,
    launches = length(app{1})/(app{1}(end)-app{1}(1))*86400;
else
    launches = 0;
end

end