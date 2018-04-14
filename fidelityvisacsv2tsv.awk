# awk -f fidelityvisacsv2tsv.awk FidelityVISA.csv >fidelityvisa.tsv
# sample input:
# Date,Transaction,Name,Memo,Amount
# 12/20/2017,DEBIT,Netflix.com netflix.c,24906417352048440576761; 04899;,-10.54
BEGIN {
	FS = ","
}
function ZeroPad(num) {
	if((0+num) < 10) {
		num = "0" num
	}
	return num
}

function TransformValue(val,  newval, idx) {
	if(match(val, /^[0-9]+\/[0-9]+/)) {
		idx = index(val, "/")
		month = ZeroPad(substr(val, 1, idx-1))
		val = substr(val, 1+idx)
		idx = index(val, "/")
		day = ZeroPad(substr(val, 1, idx-1))
		year = substr(val, 1+idx)
		newval = year "-" month "-" day
	} else {
		newval = val
	}
	return newval
}
{
	date = $1
	debitcredit = $2
	name = $3
	memo = $4
	amount = $5
	
	date = TransformValue(date)
	
	note = memo
	account = "visa"
	desc = name
	category = "unknown"
	bPrint = 0
	if("DEBIT"==debitcredit) {
		bPrint = 1
		if(index(name, "Netflix") > 0) {
			category = "Entertainment"
		} else if(index(name, "BLUE APRON") > 0) {
			category = "Food & Dining"
		} else if(index(name, "SOYLENT") > 0) {
			category = "Groceries"
		} else if(index(name, "SUDDENLINK") > 0) {
			category = "Internet"
		} else if(index(name, "1AND1.COM") > 0) {
			category = "Internet"
		} else if(index(name, "COPENHAGEN") > 0) {
			category = "Furnishings"
		} else if(index(name, "SLING.COM") > 0) {
			category = "Entertainment"
		} else if(index(name, "BARKING FROG") > 0) {
			category = "Food & Dining"
		} else if(index(name, "AMAZON.COM") > 0) {
			category = "Amazon"
		} else if(index(name, "AMZN.COM") > 0) {
			category = "Amazon"
		} else if(index(name, "CLEVERBRIDGE") > 0) {
			category = "Ignore"
		} else if(index(name, "THE GLASS COMPANY") > 0) {
			category = "Home Improvement"
		} else if(index(name, "ITUNES.COM") > 0) {
			category = "Amusement"
		} else if(index(name, "FERRARI AMERICA") > 0) {
			category = "Home Improvement"
		} else if(index(name, "HABITAT FOR HUM") > 0) {
			category = "Charity"
		} else if(index(name, "FAMOUS PIZZA") > 0) {
			category = "Dining Out"
		} else if(index(name, "Travis Double Lung") > 0) {
			category = "Charity"
		} else if(index(name, "NATIONAL MS") > 0) {
			category = "Charity"
		} else if(index(name, "MOON DOGS PIZZA") > 0) {
			category = "Dining Out"
		} else if(index(name, "WALGREENS") > 0) {
			category = "Pharmacy"
		} else if(index(name, "WORDPRESS") > 0) {
			category = "Ignore"
		} else if(index(name, "TARGET.COM") > 0 && index(memo, "24431067172083062201955; 05310;") > 0) {
			category = "Furnishings"
		} else if(index(name, "ACE HARDWARE") > 0) {
			category = "Home Improvement"
		} else if(index(name, "PROBUILD LUMBER") > 0) {
			category = "Home Improvement"
		} else if(index(name, "THE TAVERN GRILLE") > 0) {
			category = "Dining Out"
		} else if(index(name, "THE HOME DEPOT #0422 PAYSON") > 0) {
			category = "Furnishings"
		} else if(index(name, "Kindle") > 0) {
			category = "Entertainment"
		} else if(index(name, "SEDONAEBIKE") > 0) {
			category = "Entertainment"
#		} else if(index(name, "") > 0) {
#			category = ""
#		} else if(index(name, "") > 0) {
#			category = ""
		}
	}	
	
	if(bPrint) print account "\t" type "\t" date "\t" amount "\t" desc "\t" checknum "\t" category "\t" balance "\t" note "\t" 
}
