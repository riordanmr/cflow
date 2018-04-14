# Script to process downloaded transactions from Univ Wisc CU
# - Convert from CSV to TSV for easier downstream processing
# - Clean up weird negative numbers represented as (number)
# - Convert dates like 12/7/2017 to the more processing-friendly 2017-12-07
# Lines look like:
# "0098828602","CK",12/4/2017,($7.95),"POS 7115:PURCHASE BASHAS' #028 12/04/17 18:03 160 COFFEE POT DRIVE SEDONA A","","Groceries",$98402.13,"",
#
# awk -f uwcucsv2tsv.awk UWCUMRR2011.csv >UWCUMRR2011.tsv
BEGIN {
	ST_BEGFLD = 1
	ST_INQUOTED = 2
	ST_INFIELD = 3
	ST_INNEGATIVE = 4
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

function DoState(ch) {
	if(ST_BEGFLD == state) {
		if("\"" == ch) {
			state = ST_INQUOTED;
		} else if("(" == ch) {
			state = ST_INNEGATIVE
			val = "-"
		} else if("$" == ch) {
			# ignore $
			state = ST_INFIELD
		} else {
			val = val ch
			state = ST_INFIELD
		}
	} else if(ST_INQUOTED == state) {
		if("\"" == ch) {
			state = ST_INFIELD
		} else {
			val = val ch
		}
	} else if(ST_INFIELD == state) {
		if("," == ch) {
			out = out TransformValue(val) "\t"
			val = ""
			state = ST_BEGFLD
		} else {
			val = val ch
		}
	} else if(ST_INNEGATIVE == state) {
		if(")" == ch) {
			state = ST_INFIELD
		} else if("$" != ch) {
			val = val ch
		}		
	}
}

{
	out = ""
	line = $0
	state = ST_BEGFLD
	val = ""
	for(j=1; j<=length($0); j++) {
		ch = substr(line, j, 1)
		DoState(ch)
	}
	print out
}
