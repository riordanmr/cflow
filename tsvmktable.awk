# Script to read the output of sumfin.awk and create HTML output
# MRR   2022-08-09
# awk -f tsvmktable.awk data/categories.both.tsv >data/categories.html
BEGIN {
    print "<html><body>"
    print "<!-- created by tsvmktable.awk -->"
    print "<table>"
    print "<tr><td>Description</td><td>Annual Amount</td><td>Shared?</td></tr>"

    FS = "\t"
}

{
    desc = $1
    amount = $2
    print "<tr><td>" desc "</td><td>" amount "</td><td></td></tr>"
}

END {
    print "</table>"
    print "</body></html>"
}
