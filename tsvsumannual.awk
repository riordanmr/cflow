# Sum the average annual values of expenses.
# Sample input line:
# Pet Food & Supplies	-340.41	-113.47
# We add the third value, which is the average annual cost for that category.
# Certain categories are ignored.
# awk -f tsvsumannual.awk sumfin.out
{
    category = $1
    annual = $3
    if(index(category, "Mortgage / Rent") > 0) {
        # We no longer have a mortgage, so ignore historical mortgage payments
    } else if(annual > 0) {
        # ignore income
    } else {
        total += annual
    }
}

END {
    print total
}
