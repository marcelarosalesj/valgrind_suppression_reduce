import suppression as supp

sf = supp.SuppressionFile("supp_files/may-25-2020.supp")
parser = supp.Parser("supp_files/memcheck_all_errors.supp")

parser.split_into(sf)

print("SF len is ", sf.len())

sf.save()

print("Finish")
