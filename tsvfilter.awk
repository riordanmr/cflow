# filter or alter certain transactions.
# Input columns are like this, except in TSV format:
# "AccountNumber","AccountType","Posted Date","Amount","Description","Check Number","Category","Balance","Note",
# awk -f tsvfilter.awk both-date.tsv
# mrr 2017-12-17; 2017-12-22
BEGIN {
	FS = "\t"
	paycheck = 0
	tty = "/dev/tty"
}
{
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
		paycheck += amount
	} else if(index(desc, "ACH:SSA TREAS") > 0) {
		tamssa += amount
#	} else if(0+amount > 0) {
		#ignore income
	} else if("" == category && 0==amount) {
		# ignore empty records
	} else if("Home Services" == category) {
	} else if("Furnishings" == category) {
	} else if("Credit Card Payment" == category) {
		#print "!credit card: " $0 >tty
		if("0321240801" == account) {
			category = "Tam credit card"
			bPrint = 1
		} else if("0098828602" == account) {
			if(index(desc, "FIA ONLINE PYMT")>0 || index(desc,"CARDMEMBER SERV -WEB PYMT")>0) {
				# will be on VISA records
				bPrint = 0
			} else if(index(desc, "PAYPAL")>0) {
				category = "Mark Paypal"
				bPrint = 1
			} else {
				category = "Unknown Credit Card"
				bPrint = 1
			}
		} else {
			print "!Mystery credit card: " $0 >tty
		}
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
	if(bPrint) print account "\t" type "\t" date "\t" amount "\t" desc "\t" checknum "\t" category "\t" balance "\t" note "\t" 
}	

END {
	tty = "/dev/tty"
	print "Total paychecks\t" paycheck >tty
	print "Total Tam SSA\t" tamssa >tty
	print "Sum of above\t" paycheck + tamssa >tty
}
