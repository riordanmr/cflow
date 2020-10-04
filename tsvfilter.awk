# filter or alter certain transactions.
# Input columns are like this, except in TSV format:
# "AccountNumber","AccountType","Posted Date","Amount","Description","Check Number","Category","Balance","Note",
# "0098828602","CK",3/16/2018,$7000.00,"ACH:JANUS HENDERSON -INVESTMENT","","Uncategorized",$110406.46,"",
#
# awk -f tsvfilter.awk -v months=5 both-date.tsv
# mrr 2017-12-17; 2017-12-22
BEGIN {
	FS = "\t"
	paycheck = 0
	totalExpenses = 0
	tty = "/dev/tty"
	incomefile = "income.tsv"
}

function LogTTY(line) {
	print line >tty
}
function LogIncome(line) {
	print line >incomefile
	LogTTY("next line was counted as income:")
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

	bPrint = 0
	if("Paycheck" == category) {
		if(amount > 4000) {
			# ignore bonus
			LogTTY("Ignoring bonus:")
		} else {
			LogIncome(line)
			paycheck += amount
		}
	} else if(index(desc, "ACH:SSA TREAS") > 0) {
		LogIncome(line)
		tamssa += amount
	} else if(index(desc, "JANUS HENDERSON") > 0) {
		# ignore investment income
		LogTTY("Ignoring investment income:")
#	} else if(0+amount > 0) {
		#ignore income
	} else if(index(desc, "AIRBNB PAYMENTS")>0) {
		LogIncome(line)
		airbnb += amount
	} else if(index(desc, "SAFEWAY STORE 1207") > 0) {
		category = "Groceries"
		bPrint = 1
	} else if(index(desc, "NATURAL GROCERS") > 0) {
		category = "Groceries"
		bPrint = 1		
	} else if(index(desc, "WALGREENS") > 0) {
		category = "Pharmacy"
		bPrint = 1		
	} else if(index(desc, "CITY OF SEDONA -DEBITS") > 0) {
		category = "Utilities"
		bPrint = 1	
	} else if(index(desc, "APL* ITUNES.COM") > 0) {
		category = "Entertainment"
		bPrint = 1
	} else if(index(desc, "VERDE VALLEY MEDICAL") > 0) {
		category = "Doctor"
		bPrint = 1
	} else if("2018-02-01" == date && index(desc, "ZB,N.A.") > 0) {
		# ignore failed mortgage payment and reversal
		LogTTY("Ignoring failed mortgage payment and reversal")
		bPrint = 0
#	} else if(index(desc, "CARDMEMBER SERV -WEB PYMT") > 0 && amount == -3646.72) {
		# I though this was a one-time mortgage payment when the autopay didn't go thru,
		# but I think it's a coincidence that the amt was about the same as mortgage
#		category = "Mortgage / Rent"
#		bPrint = 1
	} else if(index(desc, "AEIS -DEBIT")>0) {
		LogTTY("Ignoring Ameriprise monthly investment")
	} else if("" == category && 0==amount) {
		# ignore empty records
	} else if("Home Services" == category) {
	} else if(index(desc, "401 JORDAN RD") > 0) {
		category = "Tam Wellness"
		bPrint = 1
	} else if("Furnishings" == category) {
	} else if(index(desc, "Check Number") > 0 && (-120 == 0+amount || -50 == 0+amount)) {
		category = "Counselling"
		bPrint = 1
	} else if(index(desc, "GIANT #") > 0) {
		category = "Gas / Fuel"
		bPrint = 1		
	} else if(index(desc, "ZB,N.A. LOAN PAYMT") > 0) {
		# unusual coding for mortgage
		category = "Mortgage / Rent"
		bPrint = 1
	} else if("2018-01-20" == date && 1382.52 == amount) {
		LogTTY("Ignoring refund of overpayment of insurance")
		bPrint = 0
	} else if("Credit Card Payment" == category) {
		#print "!credit card: " $0 >tty
		if("0321240801" == account) {
			category = "Tam credit card"
			bPrint = 1
		} else if(index(desc, "ACH:PAYPAL-EBAY MC")>0) {
			category = "Tam credit card"
			bPrint = 1
		} else if("0098828602" == account) {
			if(index(desc, "FIA ONLINE PYMT")>0 || index(desc,"CARDMEMBER SERV -WEB PYMT")>0) {
				# will be on VISA records
				LogTTY("Ignoring because will be in VISA records:")
				bPrint = 0
			} else if(index(desc, "PAYPAL")>0) {
				category = "Mark Paypal"
				bPrint = 1
			} else {
				category = "Unknown Credit Card"
				bPrint = 1
			}
		} else {
			LogTTY("!Mystery credit card: " $0)
			bPrint = 1
		}
	} else if(index(desc, "Web Branch:TFR TO CK 360271101") > 0) {
		category = "Casey"
		bPrint = 1
	} else if("Transfer" == category) {
		# I was originally treating transfers as an expense category, except
		# for the wire transfers associated with sale of 741 Highcliff.
		# But now that I have access to Tam's transactions, I will handle
		# these differently, ignoring most transfers because they are between 
		# accounts to which we now have access.
		#
		# Transfers to/from Tam's savings will be added in, even though presumably
		# over time they will converge to zero.
		# 360271101  is Casey's account
		# 0321240801 is Tam's account
		# 0098828602 is MRR2011
		# 0098828601 is Shared2010
		if(index(desc,"SV 321240801")>0) {
			category = "Tam Checking"
			bPrint = 1
		}
		if(index(desc,"360271101")>0) {
			category = "Casey"
			bPrint = 1
		}
		#if(bPrint) print "!" account "\t" type "\t" date "\t" amount "\t" desc "\t" checknum "\t" category "\t" balance "\t" note "\t"  >"/dev/tty"
#		if(98828601 == 0+account && "WIRE TRANSFER" != desc) {
#			#print "amount=" amount
#			if(0+amount < 0) {
#				bPrint = 1
#			}
#		}
	} else if("Misc. Income" == category) {
		# special case this record:
		# 
		# 0321240801	CK	2017-10-31	799.00	Web Branch:TFR FROM CK 098828601		Misc. Income	1008.75		
		if(index(desc, "Web Branch:TFR FROM CK 098828601") > 0) {
			bPrint = 0
		}
	} else {
		bPrint = 1
	}
	if(bPrint) {
		totalExpenses += amount
		print account "\t" type "\t" date "\t" amount "\t" desc "\t" checknum "\t" category "\t" balance "\t" note "\t" 
	} else {
		LogTTY("  Ignoring: " line)
	}
}	

END {
	LogTTY("")
	LogTTY("Total paychecks\t" paycheck)
	LogTTY("Total Tam SSA\t" tamssa)
	LogTTY("Total AirBnb\t" airbnb)
	totalIncome = paycheck + tamssa + airbnb
	LogTTY("Sum of above\t" totalIncome)
	LogTTY("Sum of above/" months "\t" totalIncome/months)
	LogTTY("")
	LogTTY("Total Expenses\t" totalExpenses)
	LogTTY("")
	netIncome = totalIncome + totalExpenses
	LogTTY("Net income over period\t" netIncome)
	LogTTY("Net income/" months "\t" netIncome/months)
}
