#!/bin/bash

LNAME="4-btree-ukey-20000";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./src/common/tests/btree.sh ukey -s 20000 &> ${LNAME}.log


LNAME="5-btree-direct-20000";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./src/common/tests/btree.sh direct -s 20000 &> ${LNAME}.log


LNAME="6-btree-20000";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./src/common/tests/btree.sh -s 20000 &> ${LNAME}.log



LNAME="7-btree-perf-20000";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./src/common/tests/btree.sh perf -s 20000 &> ${LNAME}.log



LNAME="8-btree-perf-direct-20000";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./src/common/tests/btree.sh perf direct -s 20000 &> ${LNAME}.log

LNAME="9-btree-perf-ukey-20000";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./src/common/tests/btree.sh perf ukey -s 20000 &> ${LNAME}.log



LNAME="10-btree-dyn-ukey-20000";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./src/common/tests/btree.sh dyn ukey -s 20000 &> ${LNAME}.log


LNAME="11-btree-dyn-20000";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./src/common/tests/btree.sh dyn -s 20000 &> ${LNAME}.log


LNAME="12-btree-dyn-perf-20000";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./src/common/tests/btree.sh dyn perf -s 20000 &> ${LNAME}.log


LNAME="13-btree-dyn-perf-ukey-20000";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./src/common/tests/btree.sh dyn perf ukey -s 20000 &> ${LNAME}.log
