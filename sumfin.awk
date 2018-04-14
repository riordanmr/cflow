# Read in a file of transactions in UWCU format (except as modified by uwcucsv2tsv.awk)
# and print a sum of the dollar amounts for each category.
# awk -f sumfin.awk both-date.tsv
#
# Mark Riordan  2017-12-17
BEGIN {
	FS = "\t"
}
{
	category = $7
	amount = $4
	tblAmounts[category] += amount
}
END {
	for(categ in tblAmounts) {
		print categ "\t" tblAmounts[categ]
	}
}
