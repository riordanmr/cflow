# ameriprise2tsv.awk - script to convert "Account Activity"
# scraped from ameriprise.com to TSV format.
#
# Sample input for one transaction:
# 03/07/2024	SPS ADVISOR
# (**** 4392 4 133)
# BUY - ADOBE INC	−$1,116.41	2.000	$558.2072	
# ADBE
#
# Fields are separated by tabs.  The third line is the
# most important. Its second field is the amount of the transaction.
#
# Mark Riordan  2024-03-08
#
# Usage: 
# awk -f /Users/mrr/Documents/GitHub/cflow/ameriprise2tsv.awk /Users/mrr/Documents/GitHub/cflow/data/amertrans202403.txt >/Users/mrr/Documents/GitHub/cflow/data/amertrans202403.tsv

BEGIN {
    FS = "\t"
}
{
    line = $0
    if(match(line, /[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9][0-9][0-9]/)) {
        relline = 0
    }
    relline++
    if(relline > 4) {
        print "Error: relline = " relline
    }
    if(relline == 1) {
        date = $1
    } else if(relline == 3) {
        desc = $1
        amount = $2
        # Negative amounts are indicated by a weird Unicode minus sign, sigh.
        gsub(/−/, "-", amount)
    } else if(relline == 4) {
        print date "\t" amount "\t" desc "\t" $1
    }
}
