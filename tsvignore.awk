# Read in a TSV file as output by a previous script, and print all categories
# except those we are ignoring for planning purposes.
# The ignored categories are for presumably one-time home improvement,
# transfers that don't change the net financial situation (Chloe's edu acct),
# scheduled investments, etc.
# Note:  credit card payments shouldn't show up as that general category,
# as that is filtered out and instead covered with the records from VISA.
# The input format is:
#   category "\t" amount
#
# awk -f tsvignore.awk results-sorted.tsv >results-after-ignore.tsv
#
# MRR  2017-12-122
BEGIN {
	FS = "\t"
}
{
	category = $1
	amount = $4
	bPrint = 1
	if("Home Improvement" == category) {
		bPrint = 0
	} else if("Ignore" == category) {
		bPrint = 0
	} else if("Financial & Investment" == category) {
		bPrint = 0
	}
	if(bPrint) print
}
