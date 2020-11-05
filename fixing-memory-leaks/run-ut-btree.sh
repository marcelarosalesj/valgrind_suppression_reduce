#!/bin/bash
set -x

# 4 to 8
USE_VALGRIND=memcheck ./src/common/tests/btree.sh ukey -s 20000
USE_VALGRIND=memcheck ./src/common/tests/btree.sh direct -s 20000
USE_VALGRIND=memcheck ./src/common/tests/btree.sh -s 20000
USE_VALGRIND=memcheck ./src/common/tests/btree.sh perf -s 20000
USE_VALGRIND=memcheck ./src/common/tests/btree.sh perf direct -s 20000

USE_VALGRIND=memcheck ./src/common/tests/btree.sh perf ukey -s 20000
mv test_results/4-* test_results/9/ 
echo "finish 9"

USE_VALGRIND=memcheck ./src/common/tests/btree.sh dyn ukey -s 20000
mv test_results/4-* test_results/10/
echo "finish 10"

USE_VALGRIND=memcheck ./src/common/tests/btree.sh dyn -s 20000
mv test_results/4-* test_results/11/
echo "finish 11"

USE_VALGRIND=memcheck ./src/common/tests/btree.sh dyn perf -s 20000
mv test_results/4-* test_results/12/
echo "finish 12"

USE_VALGRIND=memcheck ./src/common/tests/btree.sh dyn perf ukey -s 20000
mv test_results/4-* test_results/13/ 
echo "finish 13"
