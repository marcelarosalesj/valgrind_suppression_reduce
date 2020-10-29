# DAOS Unit testing Notes

DAOS Unit testing (UT) begins with `utils/run_test.sh` script. This script executes VOS scripts.

## Commands / Usage

* To run the DAOS Unit Testing and keep Cmocka test results in a specific directory you run this command:
```
CMOCKA_MESSAGE_OUTPUT=xml CMOCKA_XML_FILE=test_results/%g.xml utils/run_test.sh
```
For this task we do not care too much about cmocka XML files. As long as there is not a bug we do not need these files.

* For the purpose of fining memory leaks, you can run the UT with Valgrind using: 
```
mkdir -p test_results/test_results_cmocka/
CMOCKA_MESSAGE_OUTPUT=xml CMOCKA_XML_FILE=test_results/test_results_cmocka/%g_memcheck.xml RUN_TEST_VALGRIND=memcheck utils/run_test.sh  &> out.log
```
Previous command will keep Cmocka XML files in `test_results/test_results_cmocka` and keep valgrind XML results in `test_results`.

Valgrind's results have the name a name like `unit-test-[0-9]*.memcheck.xml`.

Consider that this command uses these Valgrind's flags:
```
valgrind --leak-check=full --show-reachable=yes  --error-limit=no --suppressions="utils/test_memcheck.supp" \
         --xml=yes --xml-file="test_results/unit-test-%p.memcheck.xml"
```
As you can see, this implementation suppress the leaks in this supressions file: `utils/test_memcheck.supp`.

## VOS Unit testing

`utils/run_test.sh` runs these VOS testing:

```
# vos_tests
run_test "${SL_PREFIX}/bin/vos_tests" -A 500
run_test "${SL_PREFIX}/bin/vos_tests" -n -A 500
export DAOS_IO_BYPASS=pm
run_test "${SL_PREFIX}/bin/vos_tests" -A 50
export DAOS_IO_BYPASS=pm_snap
run_test "${SL_PREFIX}/bin/vos_tests" -A 50
unset DAOS_IO_BYPASS

# btree
run_test src/common/tests/btree.sh ukey -s 20000
run_test src/common/tests/btree.sh direct -s 20000
run_test src/common/tests/btree.sh -s 20000
run_test src/common/tests/btree.sh perf -s 20000
run_test src/common/tests/btree.sh perf direct -s 20000
run_test src/common/tests/btree.sh perf ukey -s 20000
run_test src/common/tests/btree.sh dyn ukey -s 20000
run_test src/common/tests/btree.sh dyn -s 20000
run_test src/common/tests/btree.sh dyn perf -s 20000
run_test src/common/tests/btree.sh dyn perf ukey -s 20000

# evt
run_test src/vos/tests/evt_ctl.sh
run_test src/vos/tests/evt_ctl.sh pmem
```
* Note: `btree.sh` and `evt_ctl.sh` are scripts that call btree and evt testing respectively. Thus, the Valgrind command is inside those scripts.
