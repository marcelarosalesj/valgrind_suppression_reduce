import suppression as supp

sf = supp.SuppressionFile("may-05-2020")
parser = supp.Parser("supp_files/memcheck_all_errors.supp")

parser.split_into(sf)

print(sf.suppressions[0].name)
print(sf.suppressions[0].tool)
print(sf.suppressions[0].array)
