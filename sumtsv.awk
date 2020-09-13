# awk -f ../cflow/sumtsv.awk -v col=2 
BEGIN {
	FS = "\t"
}
{
	sum += $(col)
}
END {
	print "Total\t" sum
}
