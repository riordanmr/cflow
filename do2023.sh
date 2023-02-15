# Do cash flow calculations for Ameriprise's spreadsheet.
# This focusses solely on overall cash flow, without considering 
# shared vs. personal, as was the focus of the Aug 2022 calculations.
# MRR  2023-02-05

# Convert VISA transactions to our standard TSV format.
awk -f /Users/mrr/Documents/GitHub/cflow/fidelityvisacsv2tsv2023.awk VISA2021-2022.csv | sort >VISA2021-2022.tsv

# Convert UWCU CSV downloaded transactions to TSV format, removing any
# header lines in the process.
awk -f /Users/mrr/Documents/GitHub/cflow/uwcucsv2tsv.awk UWCUMRR2011-2023-02.csv UWCUMRR2022-2023-02.csv UWCUShared-2023-02.csv UWCUTam-2023-02.csv | grep -v "^AccountNumber" | awk -f /Users/mrr/Documents/GitHub/cflow/tsvfilterbydate.awk -v oldest=2021-01-01 -v newest=2022-12-31 >uwcu-2021-2022.tsv

# Combine UWCU and VISA transactions, and sort them.
sort VISA2021-2022.tsv uwcu-2021-2022.tsv >alltrans.tsv

# Filter and categorize the records.
awk -f /Users/mrr/Documents/GitHub/cflow/tsvfilter3.awk alltrans.tsv >allproc.tsv

# List unique categories.
echo Unique categories
awk -f /Users/mrr/Documents/GitHub/cflow/uniquecategories.awk allproc.tsv | sort
echo

# Sum amounts by category.
awk -f /Users/mrr/Documents/GitHub/cflow/sumfin.awk -v divideby=2 allproc.tsv | sort -t$'\t' -k2nr >catsums.tsv
cat catsums.tsv

# Create a file sorted by category (mostly so the Uncategorized entries are together).
sort -t$'\t' -k7 allproc.tsv >allsorted.tsv

# Create a spreadsheet containing the category sums.
awk -f /Users/mrr/Documents/GitHub/cflow/makesummarysheet.awk catsums.tsv >budget2023.tsv
