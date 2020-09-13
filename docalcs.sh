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
  echo Skipping concat of csv
fi




