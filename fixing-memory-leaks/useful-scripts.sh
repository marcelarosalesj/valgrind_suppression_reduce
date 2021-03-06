# Useful mini scripts for xmls checking

# show number of lines per files and sort them
for f in *.xml; do a=$(cat $f | wc -l); echo "$f $a"; done  | sort -k2 -n

# show number of lines per file
for f in *.xml; do a=$(cat $f | wc -l); echo "$f $a"; done

# move the onles with <error> tag
for f in *.xml; do grep -q "<error>" $f; if [ $? -eq 0 ]; then echo "$f - have it"; else echo "$f - doesnt have it"; mv $f empty; fi; done

# show number of errors sorted
for f in *.xml; do n=$(grep "<error>" $f | wc -l ); echo "$f $n"; done | sort -k2 -n

# show kind of leak and the functions under it
grep -E "<fn>|<kind>" unit-test-25770.memcheck.xml

# same, but for many xmls
for i in $(ls *.xml); do
	echo ">>> $i"
	grep -E "<fn>|<kind>" $i
done

# print how many leaks there are per file 

for i in $(ls *.xml); do
	echo ">>> $i"
	var=$(grep "<kind>" $i | wc -l)
	echo "count total: $var"
	var2=$(grep "Leak_StillReachable" $i | wc -l)
	echo "Results: $var2 Leak_StillReachable"
done
