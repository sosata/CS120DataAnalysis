def remove_extra_space(x):
    y = []
    for xi in x:
        if xi.startswith(' '):
            xi = xi[1:]
        if xi.endswith(' '):
            xi = xi[:-1]
        if xi:
            y += [xi]
    return y


def preprocess_reason(reason, parse=True):
    
    # if only one element is sent
    if type(reason)==str:
        reason = [reason]

    reason_new = []
    for r in reason:
        r = r.replace('"','')
        r = r.replace('[','')
        r = r.replace(']','')
        #r = r.replace(' ','')
        if '\\u2026' in r:
            r = r.replace('\\u2026','')
        if r:
            # parsing
            if ',' in r and parse:
                r_parsed = r.split(',')
                if '' in r_parsed:
                    r_parsed = filter(None, r_parsed) # removing empty strings
                if r_parsed:
                    r_parsed = [r_p.lower() for r_p in r_parsed]
            else:
                r_parsed = [r.lower()]
            
            # removing extra start or end spaces
            r_parsed = remove_extra_space(r_parsed)

            if r_parsed:
                reason_new += r_parsed
    
    return reason_new

def preprocess_location(location, parse=True):

    # if only one element is sent
    if type(location)==str:
        location = [location]

    location_new = []
    for l in location:
        l = l.replace('"','')
        l = l.replace('[','')
        l = l.replace(']','')
        if l:
            # parsing
            if ',' in l and parse:
                l_parsed = l.split(',')
                if '' in l_parsed:
                    l_parsed = filter(None, l_parsed) # removing empty strings
                if l_parsed:
                    l_parsed = [l_p for l_p in l_parsed]
                    #l_parsed = [l_p.upper() for l_p in l_parsed]
            else:
                l_parsed = [l]
                #l_parsed = [l.upper()]

            # removing extra start or end spaces
            l_parsed = remove_extra_space(l_parsed)

            if l_parsed:
                location_new += l_parsed

    return location_new