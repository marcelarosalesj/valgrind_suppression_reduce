# Reduce valgrind suppressions tool

Valgrind can generate automatically extensive `supp` files. The goal of this
tool is to reduce them.  

* First, get rid of the repeated leak errors.
* Then, identify the common root cause of some of the erros, and reduce them to
  one by using wildcards.


## How to start fixing Valgrind leaks on DAOS?

0. Make sure DAOS is compiled with debug and dev type

```
scons BUILD_TYPE=debug TARGET_TYPE=dev install -j32
```

2. Start by generating DAOS leaks results.
Remove one of the suppressions from the suppressions file in `utils/test_memcheck.supp`, then run the unit testing.

```
CMOCKA_MESSAGE_OUTPUT=xml CMOCKA_XML_FILE=test_results/test_results_cmocka/%g_memcheck.xml RUN_TEST_VALGRIND=memcheck utils/run_test.sh | tee out.log
```

2. Put away the files that don't have `<error>` flag.
You can run something like this to check the number of errors.

```
for f in *.xml; do n=$(grep "<error>" $f | wc -l ); echo "$f $n"; done | sort -k2 -n
```


3. Check the files and select one that has DAOS related leaks. 
/home/marosale/Repos/daos/install/bin/vos_tests -A 50
