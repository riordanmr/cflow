# sortbyfield.awk - script to sort a file on a certain field.
# The current version assumes tab-separated fields.
#
# Usage:  awk -f /Users/mrr/Documents/GitHub/cflow/sortbyfield.awk -v sortfld=6 /Users/mrr/Documents/Finances/allproc.tsv >allsortedawk.tsv
#
# Mark Riordan  2023-02-08
BEGIN {
    FS = "\t"
    nrecs = 0
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
        split(V[k],aryFirst)
        key1 = aryFirst[sortfld]
        split(V[k+1],arySecond)
        key2 = arySecond[sortfld]
        if (k + 1 <= n  &&  STX key1 < STX key2) ++k;
        split(e, aryE)
        keyE = aryE[sortfld]
        if (STX keyE >= STX key1) break;
        V[j] = V[k]; j = k;
    }
    V[j] = e;
}

{
    aryData[++nrecs] = $0
}

END {
    print ""
    hSort(aryData)
    for(j=1; j<=nrecs; j++) {
        print aryData[j]
    }
}
