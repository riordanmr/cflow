# docalcs.sh - Perform financial calculations on downloaded transactions
# from family accounts
# MRR  2020-09-13  based on work from 2018 as documented in
# https://docs.google.com/document/d/1ZNrBqx0aKGi1O52BZjT9Mv-O_cVXgsIcmxS6-zYrNwg/edit#

export cflowdir=/Users/mrr/Documents/Finances/cflow

if false; then
  echo cflowdir = $cflowdir
  rm UWCUall.csv
  for filename in UWCU*.csv; do
    tail -n +2 $filename >>UWCUall.csv
  done
  awk -f ${cflowdir}/uwcucsv2tsv.awk UWCUall.csv >UWCUall.tsv
else
  echo Skipping concat of UWCU csv
fi

if false; then
  awk -f ../cflow/tsvfilterbydate.awk -v oldest=2020-04-01 -v newest=2020-08-31 UWCUall.tsv >UWCU2020a.tsv
else
  echo Skipping filtering by date
fi

if false; then
  # sort by date.
  sort -k3,3 -t$'\t' -s UWCU2020a.tsv >UWCU2020asorted.tsv
else
  echo Not sorting by date
fi

if true; then
  awk -f ${cflowdir}/fidelityvisacsv2tsv.awk MRRVisa201903-202008.csv | awk -f ../cflow/tsvfilterbydate.awk -v oldest=2020-04-01 -v newest=2020-08-31 >visa.tsv
else
  echo Skipping processing of VISA records
fi

awk -f ../cflow/tsvfilter.awk -v months=5 UWCU2020asorted.tsv >filtered.tsv

echo -----

cat filtered.tsv visa.tsv >filteredplusvisa.tsv

awk -f ../cflow/sumfin.awk -v divideby=5 filteredplusvisa.tsv | sort -k2,2 -n -t$'\t'

ls -ltr | tail -5
