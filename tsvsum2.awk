# tsvsum2.awk - script to add records from a tab-separated input file, such
# as one output from uwcucsv2tsv.awk or more likely, tsvfilter2.awk.
# Special processing is done to facilitate the specific budget planning being
# done in August 2022.
#
# Typical input lines look like:
# 0098828601	CK	2022-04-29	1002.00	Web Branch:TFR FROM CK 098828602		Transfer	3159.78		
# 0098828601	CK	2022-03-28	-7.72	ACH:APS electric pmt -PAYMENT		Utilities	1992.91		
# 
# Typical use:
# awk -f tsvfilter2.awk data/uwcumrr-2019-2021.tsv data//uwcushared-2019-2021-tam.tsv data/MRRVisaSharedExp2019-2021.tsv | awk -f tsvsum2.awk
#
# MRR  2022-08-05   after tsvsum.awk of 2022-04-30
BEGIN {
    FS = "\t"
    # The data covers this many years, so divide totals by this # of years
    # to get annualized data.
    nYears = 3
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

    if(account=="0098828601") {
        if(category=="Personal") {
            totPersTJRSharedChecking += amount
        } else if(category=="SharedExp") {
            totSharedTJR += amount
        } else {
            print "Error: bad category " category " in " line
        }
    } else if(account=="0098828602") {
        # Special-case payments to MRR's VISA account, because there are 
        # separate records for expenses out of that account. 
        if(index(desc,"ACH:CARDMEMBER SERV")>0) {
            totVISAMRR += amount
        } else if(category=="Personal") {
            totPersMRRChecking += amount
        } else if(category=="SharedExp") {
            totSharedMRR += amount
        } else {
            print "Error: bad category " category " in " line
        }
    } else if(account=="visa") {
        # All records with account type "visa" are presumed to be filtered 
        # to shared expenses only. 
        totVISAMRRShared += amount
    } else {
        print "Error: bad account " account " in " line
    }
}

END {
    totVISAMRRPersonal = totVISAMRR - totVISAMRRShared
    totAnnualTJRHerChecking = -1500*12

    totAnnualTJRPersonal = (totPersTJRSharedChecking / nYears) + totAnnualTJRHerChecking
    totAnnualTJRShared = totSharedTJR / nYears

    # Account for the fact that one year, property taxes were apparently paid from
    # escrow, and thus not included here due to mortgage payments being filtered out.
    totSharedMRR += -6537
    totAnnualMRRPersonal = (totVISAMRRPersonal + totPersMRRChecking) / nYears
    totAnnualMRRShared = (totSharedMRR + totVISAMRRShared) / nYears

    totAnnualExpenses = totAnnualTJRPersonal + totAnnualTJRShared + totAnnualMRRPersonal + totAnnualMRRShared

    totAnnualIncome = 1500*12 + 3800000*0.03

    print int(totAnnualTJRPersonal) "\t" "Tam personal"
    print int(totAnnualMRRPersonal) "\t" "Mark personal"
    print int(totAnnualTJRShared+totAnnualMRRShared) "\t" "Shared expenses"
    print "--------"
    print int(totAnnualExpenses) "\t" "Total annual expenses"
    print int(totAnnualIncome) "\t" "Total annual income"
}
