# sortbyfield.py - script to sort a file of lines by a field.
# The fields are separated by tabs.
# Usage: python3 /Users/mrr/Documents/GitHub/cflow/sortbyfield.py 

def returnKey(rec):
    list1 = rec.split("\t")
    if len(list1) > 6:
        return list1[6]
    else:
        return 0

def main():
    f = open("/Users/mrr/Documents/Finances/allproc.tsv", "r")
    listLines = f.readlines()
    listLines.sort(key=returnKey)
    with open('allsortedbypy.tsv', 'w') as fout:
        for line in listLines:
            fout.write(line)

main()