# makesummarysheet.awk - Script to create a spreadsheet summarizing
# our expenses, based on:
# - A TSV of categorized transactions.  This can be quite long.
# - A file which maps categories to higher-level areas.  This has CSV lines like:
#   Water,Basic,Util: Water
#   If the third field is present, then the category should be rewritten with that name.
# Usage: awk -f /Users/mrr/Documents/GitHub/cflow/makesummarysheet.awk catsums.tsv >budget2023.tsv
BEGIN {
    FS = ","
    infile = "/Users/mrr/Documents/Finances/cat2higher.csv"
    while((getline < infile)>0) {
        cat2area[$1] = $2
        cat2cat[$1] = $3
    }
    FS = "\t"
}

function keyIsLessThan(rec1,rec2) {
    return rec1 < rec2
}

# Heapsort, from https://unix.stackexchange.com/questions/560185/
#.. Construct the heap, then unfold it.
function hSort (A, Local, n, j, e) {
    for (j in A) ++n;
    for (j = int (n / 2); j > 0; --j) hUp( j, A[j], n, A);
    for (j = n; j > 1; --j) { e = A[j]; A[j] = A[1]; hUp( 1, e, j - 1, A); }
    return (0 + n);
}
#.. Given an empty slot and its contents, pull any bigger elements up the tree.
function hUp (j, e, n, V, Local, k) {
    while ((k = j + j) <= n) {
        if (k + 1 <= n  &&  keyIsLessThan(V[k], V[k + 1])) ++k;
        if (!keyIsLessThan(e, V[k])) break;
        V[j] = V[k]; j = k;
    }
    V[j] = e;
}

{
    category = $1
    catsum = $2
    if(category in cat2area) {
        area = cat2area[category]
        if(category in cat2cat && ""!=cat2cat[category]) {
            category = cat2cat[category]
        }
    } else {
        print "** Error on line " NR ": cannot find category " category
    }
    arySums[++nout] = area "\t" category "\t" catsum
}
END {
    # Sort the categories alphabetically, so records in the same area are together
    sortfld = 1
    #for(j=1; j<=nout; j++) {
    #    print arySums[j]
    #}
    #print ""
    hSort(arySums)
    firstRowOfArea = 2
    for(j=1; j<=nout; j++) {
        split(arySums[j],aryFields,"\t")
        area = aryFields[1]
        category = aryFields[2]
        catsum = aryFields[3]
        #print area "|" category "|" catsum
        if(prevarea != area) {
            if(j>1) {
                print "\t" "Subtotal" "\t" "\t" "=SUM(C" firstRowOfArea ":C" row ")"
                row++
                firstRowOfArea = row+2
            }
            row++
            prevarea = area
            print area "\t" "\t"
        }
        print "" "\t" category "\t" catsum
        row++
    }
    print "\t" "Subtotal" "\t" "\t" "=SUM(C" firstRowOfArea ":C" row ")"
    row++
    print ""
    print "Total" "\t" "\t" "\t" "=SUM(C1:C" row ")"
}
