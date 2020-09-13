# awk -f tsvfilterbydate.awk -v oldest=2017-06-01 -v newest=2017-11-30 UWCUMRR2011.tsv
# MRR  2017-12-17
BEGIN {
	FS = "\t"
	if(0==length(oldest)) {
		print "** Error: no \"oldest\" specified"
	}
}
{
	date = $3
	if(date >= oldest && date <= newest) print
}
