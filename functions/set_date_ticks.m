function set_date_ticks(gca, resolution)

    xminmax = xlim;
    xmin = ceil(xminmax(1)/86400)*86400;
    xmax = floor(xminmax(2)/86400)*86400;
    tick_loc = xmin:86400*resolution:xmax;
    set(gca, 'xtick', tick_loc, 'xticklabel', datestr(tick_loc/86400 + datenum(1970,1,1), 6));

end