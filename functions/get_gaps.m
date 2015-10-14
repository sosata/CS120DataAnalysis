function n = get_gaps(time, date_start, date_end, gap_max)

if size(time,1)==1 && size(time,2)==1,
    n = 0;
    return;
end
if size(time,2)>1,
    time = time';
end

n = sum(diff([date_start*86400;time;(date_end+1)*86400]) >= gap_max);

end