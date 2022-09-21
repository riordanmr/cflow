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

    # As of this writing, inflation is 9.1%; see
    # https://www.usinflationcalculator.com/inflation/current-inflation-rates/
    # but I think this is a blip; see
    # https://www.kiplinger.com/economic-forecasts/inflation
    # "The inflation rate is likely to stay close to 9% the rest of the year, then decline gradually after that, ending 2023 at about 3%."
    # so I am using a smaller inflation rate.
    inflationPercent = 7.0
    inflationFactor = 1.0 + (inflationPercent / 100.0)
    adjTotAnnualTJRPersonal = inflationFactor * totAnnualTJRPersonal
    adjTotAnnualMRRPersonal = inflationFactor * totAnnualMRRPersonal
    adjTotAnnualShared = inflationFactor * (totAnnualTJRShared+totAnnualMRRShared)
    adjTotAnnualExpenses = inflationFactor * totAnnualExpenses

    totAnnualTamSS = 1600*12
    totAnnualWithdrawls = 3800000*0.0315
    totAnnualIncome = totAnnualTamSS + totAnnualWithdrawls

    # Debugging output.  I'm being paranoid because I don't want to get the budget wrong.
    if(0) {
        print "totVISAMRR = " totVISAMRR
        print "totVISAMRRShared = " totVISAMRRShared
        print "totVISAMRRPersonal = " totVISAMRRPersonal
        print "totPersTJRSharedChecking = " totPersTJRSharedChecking
        print "totSharedTJR = " totSharedTJR " from shared acct"
        print "totAnnualTJRHerChecking = " totAnnualTJRHerChecking
        print "totAnnualTJRPersonal = " totAnnualTJRPersonal
        print "totAnnualTJRShared = " totAnnualTJRShared
        print "totSharedMRR = " totSharedMRR " after adding another property tax payment"
        print "totAnnualMRRPersonal = " totAnnualMRRPersonal
        print "totAnnualMRRShared = " totAnnualMRRShared
        print "totAnnualExpenses = " totAnnualExpenses
        print "inflationFactor = " inflationFactor
        print "adjTotAnnualTJRPersonal = " adjTotAnnualTJRPersonal
        print "adjTotAnnualMRRPersonal = " adjTotAnnualMRRPersonal
        print "adjTotAnnualShared = " adjTotAnnualShared
        print "adjTotAnnualExpenses = " adjTotAnnualExpenses
    }

    print "Results of analysis of historical expenses:"
    print int(adjTotAnnualTJRPersonal) "\t" "Tam personal (adjusted for inflation)"
    print int(adjTotAnnualMRRPersonal) "\t" "Mark personal (adjusted for inflation)"
    print int(adjTotAnnualShared) "\t" "Shared expenses (adjusted for inflation)"
    print "--------"
    print int(adjTotAnnualExpenses) "\t" "Total annual expenses (adjusted for " inflationPercent "% inflation)"
    print ""
    print "Proposed plan for the future"
    print "Income:"
    print "$" int(totAnnualTamSS) "\t" "Tam's SS income"
    print "$" int(totAnnualWithdrawls) "\t" "Selling investments"
    print "--------"
    print "$" int(totAnnualIncome) "\t" "Total annual income"
    print ""

    print "Expenses:"
    monthlyBudgetPersonalMRR = -3290
    monthlyBudgetPersonalTJR = -3390
    monthlyBudgetShared = adjTotAnnualShared/12
    projectedAnnualBudget = 12*monthlyBudgetPersonalMRR + 12*monthlyBudgetPersonalTJR + adjTotAnnualShared
    print "$" 12*monthlyBudgetPersonalMRR " /year or \t$" monthlyBudgetPersonalMRR " /month \t" "Mark's discretionary budget"
    print "$" 12*monthlyBudgetPersonalTJR " /year or \t$" monthlyBudgetPersonalTJR "/ month \t"  "Tam's discretionary budget"
    print "$" int(12*monthlyBudgetShared )" /year or \t$" int(monthlyBudgetShared) " /month\t"  "Shared expenses budget"
    print "--------"    
    print "$" projectedAnnualBudget " /year or \t$" int(projectedAnnualBudget/12) " /month\t" "Total budget"
}
