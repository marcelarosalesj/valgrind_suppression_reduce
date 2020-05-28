import suppression as supp

def search_substr(sf, substr, ignore='<insert_a_suppression_name_here>   Memcheck:Leak   match-leak-kinds:reachable'):
    c1=0
    c2=0
    tmp=[]
    for i in sf:
        if i.contains(substr):
            ss = i.string.replace(ignore, '')
            tmp.append(ss)
            c1+=1
        else:
            c2+=1
    tmp.sort()
    print(tmp)
    print('substr in sf ', c1)
    print('substr not in sf ', c2)

    return tmp

def return_sf_without_substr(sf, name, substr):
    ret_sf = supp.SuppressionFile()
    ret_sf.name=name
    c1=0
    c2=0
    for i in sf:
        if i.contains(substr):
            c1+=1
        else:
            ret_sf.add_suppression(i)
            c2+=1
    print('substr in sf ', c1)
    print('substr not in sf ', c2)
    return ret_sf

