# tsvsum.awk - script to add numbers in an input TSV file, such as one
# created by uwcucsv2tsv.awk
#
# Typical input lines look like:
# 0098828601	CK	2022-04-29	1002.00	Web Branch:TFR FROM CK 098828602		Transfer	3159.78		
# 0098828601	CK	2022-03-28	-7.72	ACH:APS electric pmt -PAYMENT		Utilities	1992.91		
#
# Usage:  awk -f tsvsum.awk data/uwcushared_2022-04.tsv
#
# Mark Riordan  2022-04-30
BEGIN {
    FS = "\t"
    total = 0
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
        if (k + 1 <= n  &&  STX V[k] < STX V[k + 1]) ++k;
        if (STX e >= STX V[k]) break;
        V[j] = V[k]; j = k;
    }
    V[j] = e;
}

# function ShellSort(ary,  i, j, n, temp, increment)
# {
#   for (j in ary) ++n;
#   increment = int(n / 2)
#   while ( increment > 0 ) {
#     for(i=increment+1; i <= n; i++) {
#       j = i
#       temp = ary[i]
#       while ( (j >= increment+1) && (ary[j-increment] > temp) ) {
#         ary[j] = ary[j-increment]
#         j -= increment
#       }
#       ary[j] = temp
#     }
#     if ( increment == 2 )
#       increment = 1
#     else
#       increment = int(increment*5/11)
#   }
# }

{
    date = $3
    year = substr(date,1, 4)
    amt = $4
    desc = $5

    # Sum only certain transactions:  Transfers into the account, and expenses we want
    # to NOT factor in.
    if(index(desc,"TFR FROM CK 098828602") > 0 || index(desc,"ACH:APS")>0) {
        print date " " amt " " desc
        aryAmtYear[year] = aryAmtYear[year] + amt
        total += amt
    }
}

END {
    print ""
    idxYear = 0
    for(year in aryAmtYear) {
        idxYear++
        aryTextAmtYear[idxYear] = year " " aryAmtYear[year]
        nYears = idxYear
        #print nYears ": " aryTextAmtYear[nYears]
    }
    print ""
    hSort(aryTextAmtYear)
    for(j=1; j<=nYears; j++) {
        print aryTextAmtYear[j]
    }
    print "Total: " total
}
