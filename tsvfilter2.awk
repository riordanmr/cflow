# tsvfilter2.awk - script to read UWCU-format TSV files (emitted by uwcucsv2tsv.awk)
# and write similarly-formatted output, with some adjustments.
# This is mostly to rewrite the category field of some expenses; this
# is less time-consuming than manually editing the categories on the
# UWCU website.  Also, some lines are not passed on to output.
# This script is similar to tsvfilter.awk, but written 5 years later for
# a slightly different purpose.
#
# Input lines (and output lines) look like:
# AccountNumber	AccountType	Posted Date	Amount	Description	Check Number	Category	Balance	Note	
# 0098828602	CK	2022-08-02	-225.47	ACH:ATT -Payment		Phone	126762.55		
#
# Mark Riordan   2022-08-03

BEGIN {
    FS = "\t"

    # If a category name appears in this array, it means the category should be
    # considered a shared expense.
    arySharedExp["Counselling"] = 1
    arySharedExp["Sewer"] = 1
    arySharedExp["Healthcare"] = 1
    arySharedExp["Water"] = 1
    arySharedExp["Home Improvement"] = 1
    arySharedExp["Phone"] = 1
    arySharedExp["Propane"] = 1
    arySharedExp["Taxes"] = 1
    arySharedExp["Local Tax"] = 1
    arySharedExp["Federal Tax"] = 1
    arySharedExp["Trash Hauling"] = 1
    arySharedExp["Cable / Satellite TV"] = 1
    arySharedExp["Auto Insurance"] = 1
    arySharedExp["Utilities"] = 1
}

{
	line = $0
	account = $1
	type = $2
	date = $3
	amount = $4
	desc = $5
	checknum = $6
	category = $7
	balance = $8
	note = $9

    bPrint = 1

    if(amount >= 0) {
        # Ignore income
        bPrint = 0
    } else if(index(desc,"CMS MEDICARE")>0) {
        category = "Healthcare"
    } else if(index(desc,"TFR TO CK 098828601")>0) {
        # Ignore transfers to MRR Shared 2010, as those will be processed
        # separately by examining outflow from MRR Shared 2010.
        bPrint = 0
    } else if(index(desc,"MUTUAL OF OMAHA")>0) {
        category = "Healthcare"
    } else if(index(desc,"AEIS -DEBIT")>0) {
        # Autoinvest is not an expense per se. 
        bPrint = 0
    } else if(index(desc,"ACH:CARDMEMBER SERV -WEB PYMT")>0) {
        # For now, we will pass VISA card payments through.
        # Eventually I may ignore them here & process those from the
        # Fidelity VISA website, to be more precise.  Likely many
        # of these would be categorized as shared.
    # } else if(index(desc,"")>0) {

    }

    # Map certain categories to shared expenses.  
    if(category in arySharedExp) {
        category = "SharedExp"
    }

    if(bPrint) {
  		print account "\t" type "\t" date "\t" amount "\t" desc "\t" checknum "\t" category "\t" balance "\t" note "\t" 
    }
}
