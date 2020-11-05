#!/bin/bash

LNAME="14-vos-500";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./install/bin/vos_tests -A 500 &> ${LNAME}.log

LNAME="15-vos-n-500";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./install/bin/vos_tests -n -A 500 &> ${LNAME}.log

export DAOS_IO_BYPASS=pm
LNAME="16-vos-50-pm";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./install/bin/vos_tests -A 50 &> ${LNAME}.log
unset DAOS_IO_BYPASS

export DAOS_IO_BYPASS=pm_snap
LNAME="17-vos-50-pm-snap";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./install/bin/vos_tests -A 50 &> ${LNAME}.log
unset DAOS_IO_BYPASS
