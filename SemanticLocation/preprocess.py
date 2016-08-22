def remove_extra_characters(x):
    x = x.replace('"','')
    x = x.replace('[','')
    x = x.replace(']','')
    return x

def remove_extra_space(x):
    if type(x)==str:
        if x.startswith(' '):
            x = x[1:]
        if x.endswith(' '):
            x = x[:-1]
        y = x
    else:
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
        reason = remove_extra_characters(reason)
        reason = remove_extra_space(reason)
        if '\\u2026' in reason:
            reason = reason.replace('\\u2026','')
        reason = reason.lower()
    else:
        reason_new = []
        for r in reason:
            r = remove_extra_characters(r)
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
        reason = reason_new
    
    return reason

def preprocess_location(location, parse=True):

    # if only one element is sent
    if type(location)==str:
        location = remove_extra_characters(location)
        location = remove_extra_space(location)
    else:
        location_new = []
        for l in location:
            l = remove_extra_characters(l)
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
        location = location_new

    return location

# xs should be a list of lists. First level is subjects, and second samples for that subject.
def get_top(xs, n):
    
    x_all = [x_ for x in xs for x_ in x]
    x_uniq = list(set(x_all))

    freq = []
    for i in range(len(x_uniq)):
        freq.append(0)
        for j in range(len(xs)):
            if x_uniq[i] in xs[j]:
                freq[i] += 1

    ind_sort = sorted(range(len(freq)), key=lambda k: freq[k], reverse=True)
    freq_sorted = [freq[i] for i in ind_sort]
    x_uniq_sorted = [x_uniq[i] for i in ind_sort]

    freq_top = freq_sorted[:n]
    x_top = x_uniq_sorted[:n]

    return x_top, freq_top