# Read in a file of transactions in UWCU format (except as modified by uwcucsv2tsv.awk)
# and print a sum of the dollar amounts for each category.
# If divideby is provided, we divide by that number.  E.g., if the period covers
# 3 months, you can do this to get the monthly amounts:
# awk -f sumfin.awk -v divideby=3 both-date.tsv
#
# Mark Riordan  2017-12-17
BEGIN {
	FS = "\t"
	if(""==divideby) divideby = 1
}
{
	category = $7
	amount = $4
	tblAmounts[category] += amount
}
END {
	for(categ in tblAmounts) {
		# print categ "\t" sprintf("%.2f", tblAmounts[categ]) "\t" sprintf("%.2f", tblAmounts[categ] / divideby)
		print categ "\t" sprintf("%.2f", tblAmounts[categ] / divideby)
	}
}
