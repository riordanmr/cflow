# List unique spending categories.
# Input columns are like this, in TSV format:
# 0321240801	CK	2020-04-15	-25.00	Web Branch:TFR TO CK 360271101		Casey	1174.27	
# awk -f /Users/mrr/Documents/Finances/cflow/uniquecategories.awk /Users/mrr/Documents/Finances/2020/visa.tsv /Users/mrr/Documents/Finances/2020/filtered.tsv | sort
# MRR  2020-10-24
BEGIN {
	FS = "\t"
}
{
	category = $7
	aryCategories[category] = 1
}
END {
	for(cat in aryCategories) {
		print cat
	}
}