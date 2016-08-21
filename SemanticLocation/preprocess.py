def preprocess_reason(reason):
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
            if ',' in r:
                r_parsed = r.split(',')
                if '' in r_parsed:
                    r_parsed = filter(None, r_parsed) # removing empty strings
                if r_parsed:
                    r_parsed = [r_p.lower() for r_p in r_parsed]
            else:
                r_parsed = [r.lower()]
            
            # removing extra start or end spaces
            r_parsed_new = []
            for (i,r_p) in enumerate(r_parsed):
                if r_p.startswith(' '):
                    r_p = r_p[1:]
                if r_p.endswith(' '):
                    r_p = r_p[:-1]
                if r_p:
                    r_parsed_new += [r_p]
            r_parsed = r_parsed_new
            
            if r_parsed:
                reason_new += r_parsed
    
    return reason_new

def preprocess_location(location):
    location_new = []
    for l in location:
        l = l.replace('"','')
        l = l.replace('[','')
        l = l.replace(']','')
        if l:
            #location_new += [l.upper()]
            location_new += [l]
#            if ',' in l:
#                l_parsed = l.split(',')
#                if '' in l_parsed:
#                    l_parsed = filter(None, l_parsed) # removing empty strings
#                if l_parsed:
#                    l_parsed = [l_p.upper() for l_p in l_parsed]
#                    location_new += l_parsed
#            else:
#                location_new += [l.upper()]
    return location_new