# converts Fidelity VISA CSV to UWCU TSV, also converting dates to YYYY-MM-DD.  
# awk -f /Users/mrr/Documents/GitHub/cflow/fidelityvisacsv2tsv2023.awk VISA2021-2022.csv | sort >VISA2021-2022.tsv
# sample input:
# Date,Transaction,Name,Memo,Amount
# 12/20/2017,DEBIT,Netflix.com netflix.c,24906417352048440576761; 04899;,-10.54
# or (because the Fidelity VISA export format apparently changed to quoted values):
# "2021-10-12","DEBIT","AIRBNB  HM4PHH5534     AIRBNB.COM   CA","24492151283719129900667; 07011; ; ; FOR 01 NIGHTS FOLIO: HM4PHH55344158005959;","-37.44"
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
    if(substr(val,1,1)=="\"" && substr(val,length(val),1)=="\"") {
        val = substr(val, 2, length(val)-2)
    }
    # Convert from m/d/y to y-m-d if necessary.
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
	date = TransformValue($1)
	debitcredit = TransformValue($2)
	name = TransformValue($3)
	memo = TransformValue($4)
	amount = TransformValue($5)
	
	note = memo
	account = "visa"
	desc = name
	category = "unknown"
	bPrint = 0
	if("DEBIT"==debitcredit) {
		bPrint = 1
    }	
	if(bPrint) print account "\t" type "\t" date "\t" amount "\t" desc "\t" checknum "\t" category "\t" balance "\t" note "\t" 
}
