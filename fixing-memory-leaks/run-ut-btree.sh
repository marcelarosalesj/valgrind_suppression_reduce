#!/bin/bash
set -x

VALGRIND_SUPP=utils/btree.supp USE_VALGRIND=memcheck ./src/common/tests/btree.sh ukey -s 20000
mv test_results/4-* test_results/4/ 
echo "finish 4"

VALGRIND_SUPP=utils/btree.supp USE_VALGRIND=memcheck ./src/common/tests/btree.sh direct -s 20000
mv test_results/4-* test_results/5/ 
echo "finish 5"

VALGRIND_SUPP=utils/btree.supp USE_VALGRIND=memcheck ./src/common/tests/btree.sh -s 20000
mv test_results/4-* test_results/6/ 
echo "finish 6"

VALGRIND_SUPP=utils/btree.supp USE_VALGRIND=memcheck ./src/common/tests/btree.sh perf -s 20000
mv test_results/4-* test_results/7/ 
echo "finish 7"

VALGRIND_SUPP=utils/btree.supp USE_VALGRIND=memcheck ./src/common/tests/btree.sh perf direct -s 20000
mv test_results/4-* test_results/8/ 
echo "finish 8"

VALGRIND_SUPP=utils/btree.supp USE_VALGRIND=memcheck ./src/common/tests/btree.sh perf ukey -s 20000
mv test_results/4-* test_results/9/ 
echo "finish 9"

VALGRIND_SUPP=utils/btree.supp USE_VALGRIND=memcheck ./src/common/tests/btree.sh dyn ukey -s 20000
mv test_results/4-* test_results/10/
echo "finish 10"

VALGRIND_SUPP=utils/btree.supp USE_VALGRIND=memcheck ./src/common/tests/btree.sh dyn -s 20000
mv test_results/4-* test_results/11/
echo "finish 11"

VALGRIND_SUPP=utils/btree.supp USE_VALGRIND=memcheck ./src/common/tests/btree.sh dyn perf -s 20000
mv test_results/4-* test_results/12/
echo "finish 12"

VALGRIND_SUPP=utils/btree.supp USE_VALGRIND=memcheck ./src/common/tests/btree.sh dyn perf ukey -s 20000
mv test_results/4-* test_results/13/ 
echo "finish 13"
