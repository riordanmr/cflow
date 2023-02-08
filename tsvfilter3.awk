# Filter or alter certain transactions.
# Input columns are like this, except in TSV format:
# "AccountNumber","AccountType","Posted Date","Amount","Description","Check Number","Category","Balance","Note",
# "0098828602","CK",3/16/2018,$7000.00,"ACH:JANUS HENDERSON -INVESTMENT","","Uncategorized",$110406.46,"",
#
# awk -f /Users/mrr/Documents/GitHub/cflow/tsvfilter3.awk alltrans.tsv >allproc.tsv
# mrr 2023-02-05  Based on tsvfilter.awk of 2017-12-17; 2017-12-22
BEGIN {
	FS = "\t"
	tty = "/dev/tty"
	incomefile = "income.tsv"
    ignorefile = "ignore.tsv"
}

function LogTTY(msg) {
	print msg >tty
}
function LogIgnore(msg) {
    print msg >ignorefile
}
function LogTTYAndLine(msg) {
	LogTTY(msg)
	LogTTY(line)
}
function LogIncome(msg) {
	print msg >incomefile
	#LogTTY("next line was counted as income:")
	#LogTTY(line)
}

function Matches(myline, target) {
    return (index(myline, target) > 0)
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
    if("Transfer" == category) {
		# I will ignore most transfers because they are between 
		# accounts to which we now have access.
		#
		# 360271101  is Casey's account
		# 0321240801 is Tam's account
		# 0098828602 is MRR2011 (Used as holding tank starting Aug 2022)
		# 0098828601 is Shared2010
        # 0098828604 is MRR2022 (Mark's personal)
		if(index(desc,"360271101")>0) {
			category = "Casey"
			bPrint = 1
		} else {
            bPrint = 0
        }
    } else if(index(desc,"Web Branch:MLink")>0) {
        # Ignore MoneyLink transfers. Dunno why UWCU doesn't categorize
        # these as transfers.
        bPrint = 0
    } else if(amount > 0) {
        # allow returns to go through, so they will cancel the original purchases.
        if(index(line,"RETURN ")>0) {
            # If it's Amazon, make that the category, else retain category.
            if(index(line,"AMAZON.COM")>0 || index(line, "AMZN Digital")>0) {
                category = "Amazon"
            }
        } else {
            LogIncome(line)
            bPrint = 0
        }
	#} else if(index(desc, "ACH:SSA TREAS") > 0) {
	#	LogIncome(line)
	#	tamssa += amount
	#} else if(index(desc, "JANUS HENDERSON") > 0) {
		# ignore investment income
	#	LogTTYAndLine("Ignoring investment income:")
#	} else if(0+amount > 0) {
		#ignore income
	#} else if(index(desc, "AIRBNB PAYMENTS")>0) {
	#	LogIncome(line)
	#	airbnb += amount
    } else if(Matches(desc,"AMZN Digital") || Matches(line,"AMAZON.COM") || 
       Matches(line, "Amzn.com") || Matches(line, "Amazon.com")) {
        category = "Amazon"
	} else if(index(desc, "SAFEWAY STORE 1207") > 0) {
		category = "Groceries"
	} else if(index(desc, "NATURAL GROCERS") > 0) {
		category = "Groceries"
	} else if(index(desc, "WALGREENS") > 0) {
		category = "Pharmacy"
	} else if(index(desc, "CITY OF SEDONA -DEBITS") > 0) {
		category = "Utilities"
	} else if(index(desc, "APL* ITUNES.COM") > 0) {
		category = "Entertainment"
   	} else if(index(desc, "CVS/PHARMACY") > 0) {
        category = "Pharmacy"
   	} else if(index(desc, "SAFEWAY ") > 0 || index(desc,"RESH & NATURAL")>0 ||
       index(desc,"FRYS-FOOD")>0) {
        category = "Groceries"
   	} else if(index(desc, "Prime Video") > 0) {
        category = "Entertainment"
   	} else if(index(desc, "ACUITY -INS PREM") > 0) {
        category = "Insurance"
   	} else if(index(desc, "PAYPAL -INST XFER") > 0) {
        category = "Shopping"
   	} else if(index(desc, "WILDFLOWER") > 0 || index(desc,"CHIPOTLE ")>0 ||
       index(desc,"FAMOUS PIZ")>0 || index(desc,"SEDONA CREPES")>0) {
        category = "Dining Out"
   	} else if(Matches(desc, "SHELL SERVICE") || Matches(desc,"CHEVRON")) {
        category = "Gas / Fuel"
   	} else if(index(desc, "FOL USED") > 0) {
        category = "Shopping"
   	} else if(index(desc, "PHX ART MUS STORE") > 0) {
        category = "Gift"
   	} else if(Matches(desc, "xyzzy")) {
        category = ""
   	} else if(Matches(desc, "xyzzy")) {
        category = ""
   	} else if(Matches(desc, "xyzzy")) {
        category = ""
   	} else if(Matches(desc, "xyzzy")) {
        category = ""
   	} else if(Matches(desc, "xyzzy")) {
        category = ""
   	} else if(Matches(desc, "xyzzy")) {
        category = ""
   	} else if(Matches(desc, "xyzzy")) {
        category = ""
   	} else if(Matches(desc, "xyzzy")) {
        category = ""
   	} else if(Matches(desc, "xyzzy")) {
        category = ""
   	} else if(Matches(desc, "xyzzy")) {
        category = ""
   	} else if(Matches(desc, "xyzzy")) {
        category = ""
   	} else if(Matches(desc, "xyzzy")) {
        category = ""
   	} else if(Matches(desc, "xyzzy")) {
        category = ""
   	} else if(Matches(desc, "xyzzy")) {
        category = ""
   	} else if(Matches(desc, "xyzzy")) {
        category = ""
   	} else if(Matches(desc, "xyzzy")) {
        category = ""
    } else if(index(desc, "Big O Tires")>0) {
        category = "Auto"
	} else if(index(desc, "VERDE VALLEY MEDICAL") > 0) {
		category = "Healthcare"
    } else if(index(desc, "SEDONA EYE CARE")>0 || index(desc,"SEDONA ENDODONTICS")>0 ||
       index(desc,"Sedona Eye")>0) {
        category = "Healthcare"
	} else if(index(desc, "AEIS -DEBIT")>0) {
		LogTTYAndLine("Ignoring Ameriprise monthly investment:")
	} else if("" == category && 0==amount) {
		# ignore empty records
	} else if("Home Services" == category) {
	} else if(index(desc, "401 JORDAN RD") > 0 || index(desc,"465 Jordan Road")>0) {
		category = "Tam Wellness"
	#} else if("Furnishings" == category) {
	} else if(index(desc, "Check Number") > 0 && (-120 == 0+amount || -50 == 0+amount)) {
		category = "Counselling"
	} else if(index(desc, "GIANT #") > 0) {
		category = "Gas / Fuel"
	} else if(index(desc, "DWR AUSTIN")>0) {
		category = "Furnishings"
		bPrint = 1
	} else if("Credit Card Payment" == category) {
		if(index(desc,"ACH:PAYPAL-EBAY MC")>0) {
			category = "Tam credit card"
			bPrint = 1
		} else if("0321240801" == account || "0098828601" == account) {
			category = "Tam credit card"
			bPrint = 1
		} else if("0098828602" == account) {
			if(index(desc, "FIA ONLINE PYMT")>0 || index(desc,"CARDMEMBER SERV -WEB PYMT")>0) {
				# will be on VISA records
				#LogTTYAndLine("Ignoring because will be in VISA records:")
				bPrint = 0
			} else if(index(desc, "PAYPAL")>0) {
				category = "Mark Paypal"
				bPrint = 1
			} else {
				category = "Unknown Credit Card"
				bPrint = 1
			}
        } else if("0098828604" == account) {
		    #LogTTYAndLine("Ignoring because will be in VISA records:")
			bPrint = 0
		} else {
			LogTTYAndLine("!Mystery credit card: " $0)
			bPrint = 1
		}
	} else if(index(desc, "Web Branch:TFR TO CK 360271101") > 0) {
		category = "Casey"
		bPrint = 1
    } else if("Dentist"==category) {
        category = "Healthcare"
    } else if("Doctor"==category || "Eyecare"==category) {
        category = "Healthcare"
    } else if("tam's wellness plus misc cash"==category) {
        category = "Tam Wellness"
    } else if("Local Tax" == category) {
        category = "Taxes"
    } else if("xyzzy" == category) {
        category = ""
    } else if("xyzzy" == category) {
        category = ""
    } else if("xyzzy" == category) {
        category = ""
    } else if("xyzzy" == category) {
        category = ""
    } else if("xyzzy" == category) {
        category = ""
    } else if("xyzzy" == category) {
        category = ""
    } else if("xyzzy" == category) {
        category = ""
    } else if("xyzzy" == category) {
        category = ""
	} else {
		bPrint = 1
	}
	if(bPrint) {
		totalExpenses += amount
		print account "\t" type "\t" date "\t" amount "\t" desc "\t" checknum "\t" category "\t" balance "\t" note "\t" 
	} else {
		LogIgnore(line)
	}
}	

END {
	LogTTY("")
	LogTTY("Total Expenses\t" totalExpenses)
	LogTTY("")
}
