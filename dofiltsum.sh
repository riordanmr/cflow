# Combine all input files, and filter a few transactions.
awk -f tsvfilter2.awk -v bCollapseToSharedvsPersonal=0 data/uwcumrr-2019-2021.tsv data/uwcushared-2019-2021-tam.tsv data/MRRVisaSharedExp2019-2021.tsv >data/filteredwithcat.tsv
# Produce a report on expenses by category, for the both of us.
awk -f sumfin.awk -v divideby=3 data/filteredwithcat.tsv | sort -k 2 -n  -t$'\t' >data/categories.both.tsv
# Produce a report on expenses by category, for Mark.
awk -f tsvfilter2.awk -v bCollapseToSharedvsPersonal=0 data/uwcumrr-2019-2021.tsv data/MRRVisaSharedExp2019-2021.tsv | awk -f sumfin.awk -v divideby=3 | sort -k 2 -n  -t$'\t' >data/categories.mrr.tsv
# Produce a report on expenses by category, for Tam (from shared account only).
awk -f tsvfilter2.awk -v bCollapseToSharedvsPersonal=0 data/uwcushared-2019-2021-tam.tsv | awk -f sumfin.awk -v divideby=3 | sort -k 2 -n  -t$'\t' >data/categories.sharedacct.tsv
# Produce a high-level report focussing on shared vs. personal.
awk -f tsvfilter2.awk -v bCollapseToSharedvsPersonal=1 data/uwcumrr-2019-2021.tsv data/uwcushared-2019-2021-tam.tsv data/MRRVisaSharedExp2019-2021.tsv | awk -f tsvsum2.awk 
