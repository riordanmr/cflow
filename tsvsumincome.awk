# Reads records in UWCU TSV format and echos, and also sums, those
# values corresponding to reportable income.
# Used to calculate amount of income attributable to a given state,
# after upstream processing by 
#  awk -f tsvfilterbydate.awk -v oldest=2017-01-01 -v newest=2017-05-20
# but that turned out to not be useful.
#
# Typical input lines:
# 0098828602	CK	2017-05-05	3584.64	ACH:IPSWITCH INC -DIRECT DEP		Paycheck	147158.90		
# 0321240801	CK	2017-02-03	1413.00	ACH:SSA TREAS 310 -XXSOC SEC		Income	1999.15			
#
# awk -f tsvsumincome.awk UWCUAll-2017-WI.tsv
#
# Mark Riordan  31 March 2018
BEGIN {
	FS = "\t"
}

{
	amount = $4	
	desc = $5
	if(index(desc, "ACH:IPSWITCH INC -DIRECT DEP") > 0) {	
		markincome += amount
		print
	}
	if(index(desc, "SSA TREAS") > 0) {
		tammyincome += amount
		print
	}
}

END {
	print ""
	print "Mark income: " markincome
	print "Tammy income: " tammyincome
	totalincome = markincome + tammyincome
	print "Total income: " totalincome
}
