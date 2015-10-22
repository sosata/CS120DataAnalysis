function gaps = get_gaps(time, date_start, date_end, gap_max)

if size(time,1)==1 && size(time,2)==1,
    gaps = [];
    return;
end
if size(time,2)>1,
    time = time';
end

dif = diff([date_start*86400;time;(date_end+1)*86400]);

gaps = dif(dif >= gap_max)/3600;

end