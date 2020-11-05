# Fixing memory leaks (DAOS VOS)

To manage this problem, I will follow a divide and conquer approach.

* The breakdown of VOS UT framework is [here](#vos-ut-framework).
* The strategy description is [here](#strategy).
* The execution notes and results are [here](#execution).

Note that we want to solve not only leaks, but various kinds of Valgrind issues.

## VOS UT framework

VOS UT involves `btree.sh`, `evt_ctl.sh` and `vos_tests`. They run the following testing:

* evt
    * Drain
    * Internal
    * Sequence
* btree
    * ukey -s 20000
    * direct -s 20000
    * -s 20000
    * perf -s 20000
    * perf direct -s 20000
    * perf ukey -s 20000
    * dyn ukey -s 20000
    * dyn -s 20000
    * dyn perf -s 20000
    * dyn perf ukey -s 20000
* vos_tests
    * Pending


## Strategy

For fixing VOS memory leaks, I will start by running one by one the VOS test cases from the test suite, without the suppresions file. This is in order to narrow what test execution generated what leaks. In other words, this approach will not use the `run_test.sh` script. Instead, it requires to run the VOS Unit test directly.

I will start with `evt` and `btree`, then continue with `vos_test` suite (IO first, then the other tests).

## Priorities

Note that we care more about fixing leaks on the VOS API than in VOS test cases, although ultimately we want the code free of leaks. We will try to fix issues following this priority order:

### Issues priority order
* `InvalidWrite` is important to fix this issue in VOS API and in test cases. Writing outside of vallid allocated block can cause stability problems.
* Invalid Read
* Uninitialized Reads
* `Leak_DefinitelyLost`
* `Leak_IndirectlyLost` probably will disappear after fixing `Leak_DefinitelyLost` leak.
* `Leak_StillReachable` is important, but we can start with the ones above first.


## Execution

The Valgrind XML results of following commands are in `ut_memcheck_results`, and the logs are in `ut_logs`.

* 1 - evt drain without pmem
```
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/1-evt-drain-leaks.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./install/bin/evt_ctl --start-test "evtree drain tests" -C o:4 -e s:0,e:128,n:2379 -c &> evt-drain-leaks.log

Results: 9 Leak_StillReachable
```
[memcheck xmls](ut_memcheck_results/1-evt-drain-leaks.xml) and [tests logs](ut_memcheck_results/1-evt-drain-leaks.log)

* 2 - evt internal without pmem
```
LNAME="2-evt-internal-leaks"
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./install/bin/evt_ctl --start-test "evtree built-in tests" -t &> ${LNAME}.log

Results: 1 InvalidWrite, 4 Leak_DefinitelyLost, 3 Leak_IndirectlyLost, 9 Leak_StillReachable

```
[memcheck xmls](ut_memcheck_results/2-evt-internal-leaks.xml) and [test logs](ut_logs/2-evt-internal-leaks.log)
- [InvalidWrite PR](https://github.com/daos-stack/daos/pull/3764)

* 3 - evt sequence without pmem
```
LNAME="3-evt-sequence-leaks"
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./install/bin/evt_ctl --start-test "evt tests sequence" -C o:4 -a 20-24@4:black -a 90-95@6:coffee -a 50-56@4:scarlet -a 57-61@4:witch -a 57-61@4:witch -a 96-99@4:blue -a 78-82@6:hello -a 25-29@5:widow -a 10-15@4:spider -a 35-40@6:yellow -a -36-41@6:boggle -a -34-39@6:dimple -a 34-38@7:tight -a 0-3@3:bulk -f 20-30@5 -f 28-52@5 -f 20-30@2 -f 35-40@6 -f 35-40@7 -f 0-100@3 -f 0-100@6 -a 3-28@8:abcdefghijklmnopqrstuvwxyz -a 31-56@1:abcdefghijklmnopqrstuvwxyz -f 0-100@8 -d -0-100@8 -a 20-26@13:coveted -a 50-54@13:fight -a 90-95@15:cookie -a 57-61@13:hairy -a 96-98@13:toe -a 78-82@15:yummy -a 25-29@14:bagel -a 10-15@13:trucks -a 34-39@15:crooks -a -36-41@15:simple -a -35-40@15:bakers -a 34-38@16:motor -a 0-3@12:cake -f 20-30@14 -f 28-52@14 -f 20-30@11 -f 35-40@15 -f 35-40@16 -f 0-100@12 -f 0-100@15 -a 3-28@17:abcdefghijklmnopqrstuvwxyz -a 31-56@10:abcdefghijklmnopqrstuvwxyz -f 0-100@17 -d -0-100@17 -a 20-24@22:black -a 90-95@24:coffee -a 50-56@22:scarlet -a 57-61@22:witch -a 57-61@22:witch -a 96-99@22:blue -a 78-82@24:hello -a 25-29@23:widow -a 10-15@22:spider -a 35-40@24:yellow -a -36-41@24:boggle -a -34-39@24:dimple -a 34-38@25:tight -a 0-3@21:bulk -f 20-30@23 -f 28-52@23 -f 20-30@20 -f 35-40@24 -f 35-40@25 -f 0-100@21 -f 0-100@24 -a 3-28@26:abcdefghijklmnopqrstuvwxyz -a 31-56@19:abcdefghijklmnopqrstuvwxyz -f 0-100@26 -d -0-100@26 -a 20-26@31:coveted -a 50-54@31:fight -a 90-95@33:cookie -a 57-61@31:hairy -a 96-98@31:toe -a 78-82@33:yummy -a 25-29@32:bagel -a 10-15@31:trucks -a 34-39@33:crooks -a -36-41@33:simple -a -35-40@33:bakers -a 34-38@34:motor -a 0-3@30:cake -f 20-30@32 -f 28-52@32 -f 20-30@29 -f 35-40@33 -f 35-40@34 -f 0-100@30 -f 0-100@33 -a 3-28@35:abcdefghijklmnopqrstuvwxyz -a 31-56@28:abcdefghijklmnopqrstuvwxyz -f 0-100@35 -d -0-100@35 -a 20-24@40:black -a 90-95@42:coffee -a 50-56@40:scarlet -a 57-61@40:witch -a 57-61@40:witch -a 96-99@40:blue -a 78-82@42:hello -a 25-29@41:widow -a 10-15@40:spider -a 35-40@42:yellow -a -36-41@42:boggle -a -34-39@42:dimple -a 34-38@43:tight -a 0-3@39:bulk -f 20-30@41 -f 28-52@41 -f 20-30@38 -f 35-40@42 -f 35-40@43 -f 0-100@39 -f 0-100@42 -a 3-28@44:abcdefghijklmnopqrstuvwxyz -a 31-56@37:abcdefghijklmnopqrstuvwxyz -f 0-100@44 -d -0-100@44 -a 20-26@49:coveted -a 50-54@49:fight -a 90-95@51:cookie -a 57-61@49:hairy -a 96-98@49:toe -a 78-82@51:yummy -a 25-29@50:bagel -a 10-15@49:trucks -a 34-39@51:crooks -a -36-41@51:simple -a -35-40@51:bakers -a 34-38@52:motor -a 0-3@48:cake -f 20-30@50 -f 28-52@50 -f 20-30@47 -f 35-40@51 -f 35-40@52 -f 0-100@48 -f 0-100@51 -a 3-28@53:abcdefghijklmnopqrstuvwxyz -a 31-56@46:abcdefghijklmnopqrstuvwxyz -f 0-100@53 -d -0-100@53 -a 20-24@58:black -a 90-95@60:coffee -a 50-56@58:scarlet -a 57-61@58:witch -a 57-61@58:witch -a 96-99@58:blue -a 78-82@60:hello -a 25-29@59:widow -a 10-15@58:spider -a 35-40@60:yellow -a -36-41@60:boggle -a -34-39@60:dimple -a 34-38@61:tight -a 0-3@57:bulk -f 20-30@59 -f 28-52@59 -f 20-30@56 -f 35-40@60 -f 35-40@61 -f 0-100@57 -f 0-100@60 -a 3-28@62:abcdefghijklmnopqrstuvwxyz -a 31-56@55:abcdefghijklmnopqrstuvwxyz -f 0-100@62 -d -0-100@62 -a 20-26@67:coveted -a 50-54@67:fight -a 90-95@69:cookie -a 57-61@67:hairy -a 96-98@67:toe -a 78-82@69:yummy -a 25-29@68:bagel -a 10-15@67:trucks -a 34-39@69:crooks -a -36-41@69:simple -a -35-40@69:bakers -a 34-38@70:motor -a 0-3@66:cake -f 20-30@68 -f 28-52@68 -f 20-30@65 -f 35-40@69 -f 35-40@70 -f 0-100@66 -f 0-100@69 -a 3-28@71:abcdefghijklmnopqrstuvwxyz -a 31-56@64:abcdefghijklmnopqrstuvwxyz -f 0-100@71 -d -0-100@71 -a 20-24@76:black -a 90-95@78:coffee -a 50-56@76:scarlet -a 57-61@76:witch -a 57-61@76:witch -a 96-99@76:blue -a 78-82@78:hello -a 25-29@77:widow -a 10-15@76:spider -a 35-40@78:yellow -a -36-41@78:boggle -a -34-39@78:dimple -a 34-38@79:tight -a 0-3@75:bulk -f 20-30@77 -f 28-52@77 -f 20-30@74 -f 35-40@78 -f 35-40@79 -f 0-100@75 -f 0-100@78 -a 3-28@80:abcdefghijklmnopqrstuvwxyz -a 31-56@73:abcdefghijklmnopqrstuvwxyz -f 0-100@80 -d -0-100@80 -a 20-26@85:coveted -a 50-54@85:fight -a 90-95@87:cookie -a 57-61@85:hairy -a 96-98@85:toe -a 78-82@87:yummy -a 25-29@86:bagel -a 10-15@85:trucks -a 34-39@87:crooks -a -36-41@87:simple -a -35-40@87:bakers -a 34-38@88:motor -a 0-3@84:cake -f 20-30@86 -f 28-52@86 -f 20-30@83 -f 35-40@87 -f 35-40@88 -f 0-100@84 -f 0-100@87 -a 3-28@89:abcdefghijklmnopqrstuvwxyz -a 31-56@82:abcdefghijklmnopqrstuvwxyz -f 0-100@89 -d -0-100@89 -a 20-24@94:black -a 90-95@96:coffee -a 50-56@94:scarlet -a 57-61@94:witch -a 57-61@94:witch -a 96-99@94:blue -a 78-82@96:hello -a 25-29@95:widow -a 10-15@94:spider -a 35-40@96:yellow -a -36-41@96:boggle -a -34-39@96:dimple -a 34-38@97:tight -a 0-3@93:bulk -f 20-30@95 -f 28-52@95 -f 20-30@92 -f 35-40@96 -f 35-40@97 -f 0-100@93 -f 0-100@96 -a 3-28@98:abcdefghijklmnopqrstuvwxyz -a 31-56@91:abcdefghijklmnopqrstuvwxyz -f 0-100@98 -d -0-100@98 -a 20-26@103:coveted -a 50-54@103:fight -a 90-95@105:cookie -a 57-61@103:hairy -a 96-98@103:toe -a 78-82@105:yummy -a 25-29@104:bagel -a 10-15@103:trucks -a 34-39@105:crooks -a -36-41@105:simple -a -35-40@105:bakers -a 34-38@106:motor -a 0-3@102:cake -f 20-30@104 -f 28-52@104 -f 20-30@101 -f 35-40@105 -f 35-40@106 -f 0-100@102 -f 0-100@105 -a 3-28@107:abcdefghijklmnopqrstuvwxyz -a 31-56@100:abcdefghijklmnopqrstuvwxyz -f 0-100@107 -d -0-100@107 -a 20-24@112:black -a 90-95@114:coffee -a 50-56@112:scarlet -a 57-61@112:witch -a 57-61@112:witch -a 96-99@112:blue -a 78-82@114:hello -a 25-29@113:widow -a 10-15@112:spider -a 35-40@114:yellow -a -36-41@114:boggle -a -34-39@114:dimple -a 34-38@115:tight -a 0-3@111:bulk -f 20-30@113 -f 28-52@113 -f 20-30@110 -f 35-40@114 -f 35-40@115 -f 0-100@111 -f 0-100@114 -a 3-28@116:abcdefghijklmnopqrstuvwxyz -a 31-56@109:abcdefghijklmnopqrstuvwxyz -f 0-100@116 -d -0-100@116 -a 20-26@121:coveted -a 50-54@121:fight -a 90-95@123:cookie -a 57-61@121:hairy -a 96-98@121:toe -a 78-82@123:yummy -a 25-29@122:bagel -a 10-15@121:trucks -a 34-39@123:crooks -a -36-41@123:simple -a -35-40@123:bakers -a 34-38@124:motor -a 0-3@120:cake -f 20-30@122 -f 28-52@122 -f 20-30@119 -f 35-40@123 -f 35-40@124 -f 0-100@120 -f 0-100@123 -a 3-28@125:abcdefghijklmnopqrstuvwxyz -a 31-56@118:abcdefghijklmnopqrstuvwxyz -f 0-100@125 -d -0-100@125 -a 20-24@130:black -a 90-95@132:coffee -a 50-56@130:scarlet -a 57-61@130:witch -a 57-61@130:witch -a 96-99@130:blue -a 78-82@132:hello -a 25-29@131:widow -a 10-15@130:spider -a 35-40@132:yellow -a -36-41@132:boggle -a -34-39@132:dimple -a 34-38@133:tight -a 0-3@129:bulk -f 20-30@131 -f 28-52@131 -f 20-30@128 -f 35-40@132 -f 35-40@133 -f 0-100@129 -f 0-100@132 -a 3-28@134:abcdefghijklmnopqrstuvwxyz -a 31-56@127:abcdefghijklmnopqrstuvwxyz -f 0-100@134 -d -0-100@134 -a 20-26@139:coveted -a 50-54@139:fight -a 90-95@141:cookie -a 57-61@139:hairy -a 96-98@139:toe -a 78-82@141:yummy -a 25-29@140:bagel -a 10-15@139:trucks -a 34-39@141:crooks -a -36-41@141:simple -a -35-40@141:bakers -a 34-38@142:motor -a 0-3@138:cake -f 20-30@140 -f 28-52@140 -f 20-30@137 -f 35-40@141 -f 35-40@142 -f 0-100@138 -f 0-100@141 -a 3-28@143:abcdefghijklmnopqrstuvwxyz -a 31-56@136:abcdefghijklmnopqrstuvwxyz -f 0-100@143 -d -0-100@143 -a 20-24@148:black -a 90-95@150:coffee -a 50-56@148:scarlet -a 57-61@148:witch -a 57-61@148:witch -a 96-99@148:blue -a 78-82@150:hello -a 25-29@149:widow -a 10-15@148:spider -a 35-40@150:yellow -a -36-41@150:boggle -a -34-39@150:dimple -a 34-38@151:tight -a 0-3@147:bulk -f 20-30@149 -f 28-52@149 -f 20-30@146 -f 35-40@150 -f 35-40@151 -f 0-100@147 -f 0-100@150 -a 3-28@152:abcdefghijklmnopqrstuvwxyz -a 31-56@145:abcdefghijklmnopqrstuvwxyz -f 0-100@152 -d -0-100@152 -a 20-26@157:coveted -a 50-54@157:fight -a 90-95@159:cookie -a 57-61@157:hairy -a 96-98@157:toe -a 78-82@159:yummy -a 25-29@158:bagel -a 10-15@157:trucks -a 34-39@159:crooks -a -36-41@159:simple -a -35-40@159:bakers -a 34-38@160:motor -a 0-3@156:cake -f 20-30@158 -f 28-52@158 -f 20-30@155 -f 35-40@159 -f 35-40@160 -f 0-100@156 -f 0-100@159 -a 3-28@161:abcdefghijklmnopqrstuvwxyz -a 31-56@154:abcdefghijklmnopqrstuvwxyz -f 0-100@161 -d -0-100@161 -a 20-24@166:black -a 90-95@168:coffee -a 50-56@166:scarlet -a 57-61@166:witch -a 57-61@166:witch -a 96-99@166:blue -a 78-82@168:hello -a 25-29@167:widow -a 10-15@166:spider -a 35-40@168:yellow -a -36-41@168:boggle -a -34-39@168:dimple -a 34-38@169:tight -a 0-3@165:bulk -f 20-30@167 -f 28-52@167 -f 20-30@164 -f 35-40@168 -f 35-40@169 -f 0-100@165 -f 0-100@168 -a 3-28@170:abcdefghijklmnopqrstuvwxyz -a 31-56@163:abcdefghijklmnopqrstuvwxyz -f 0-100@170 -d -0-100@170 -a 20-26@175:coveted -a 50-54@175:fight -a 90-95@177:cookie -a 57-61@175:hairy -a 96-98@175:toe -a 78-82@177:yummy -a 25-29@176:bagel -a 10-15@175:trucks -a 34-39@177:crooks -a -36-41@177:simple -a -35-40@177:bakers -a 34-38@178:motor -a 0-3@174:cake -f 20-30@176 -f 28-52@176 -f 20-30@173 -f 35-40@177 -f 35-40@178 -f 0-100@174 -f 0-100@177 -a 3-28@179:abcdefghijklmnopqrstuvwxyz -a 31-56@172:abcdefghijklmnopqrstuvwxyz -f 0-100@179 -d -0-100@179 -a 0-1@60000:AA -a 350-355@60000:evtree -a 355-355@60010 -a 1-360@60020 -a 0-0@60030 -f 0-355@60000 -f 0-355@60030 -a 0-1@120000:AA -a 350-355@120000:evtree -a 355-355@120010 -a 1-360@120020 -a 0-0@120030 -f 0-355@120000 -f 0-355@120030 -a 0-1@180000:AA -a 350-355@180000:evtree -a 355-355@180010 -a 1-360@180020 -a 0-0@180030 -f 0-355@180000 -f 0-355@180030 -a 0-1@240000:AA -a 350-355@240000:evtree -a 355-355@240010 -a 1-360@240020 -a 0-0@240030 -f 0-355@240000 -f 0-355@240030 -a 0-1@300000:AA -a 350-355@300000:evtree -a 355-355@300010 -a 1-360@300020 -a 0-0@300030 -f 0-355@300000 -f 0-355@300030 -a 0-1@360000:AA -a 350-355@360000:evtree -a 355-355@360010 -a 1-360@360020 -a 0-0@360030 -f 0-355@360000 -f 0-355@360030 -a 0-1@420000:AA -a 350-355@420000:evtree -a 355-355@420010 -a 1-360@420020 -a 0-0@420030 -f 0-355@420000 -f 0-355@420030 -a 0-1@480000:AA -a 350-355@480000:evtree -a 355-355@480010 -a 1-360@480020 -a 0-0@480030 -f 0-355@480000 -f 0-355@480030 -a 0-1@540000:AA -a 350-355@540000:evtree -a 355-355@540010 -a 1-360@540020 -a 0-0@540030 -f 0-355@540000 -f 0-355@540030 -a 0-1@600000:AA -a 350-355@600000:evtree -a 355-355@600010 -a 1-360@600020 -a 0-0@600030 -f 0-355@600000 -f 0-355@600030 -a 0-1@660000:AA -a 350-355@660000:evtree -a 355-355@660010 -a 1-360@660020 -a 0-0@660030 -f 0-355@660000 -f 0-355@660030 -a 0-1@720000:AA -a 350-355@720000:evtree -a 355-355@720010 -a 1-360@720020 -a 0-0@720030 -f 0-355@720000 -f 0-355@720030 -a 0-1@780000:AA -a 350-355@780000:evtree -a 355-355@780010 -a 1-360@780020 -a 0-0@780030 -f 0-355@780000 -f 0-355@780030 -a 0-1@840000:AA -a 350-355@840000:evtree -a 355-355@840010 -a 1-360@840020 -a 0-0@840030 -f 0-355@840000 -f 0-355@840030 -a 0-1@900000:AA -a 350-355@900000:evtree -a 355-355@900010 -a 1-360@900020 -a 0-0@900030 -f 0-355@900000 -f 0-355@900030 -a 0-1@960000:AA -a 350-355@960000:evtree -a 355-355@960010 -a 1-360@960020 -a 0-0@960030 -f 0-355@960000 -f 0-355@960030 -a 0-1@1020000:AA -a 350-355@1020000:evtree -a 355-355@1020010 -a 1-360@1020020 -a 0-0@1020030 -f 0-355@1020000 -f 0-355@1020030 -a 0-1@1080000:AA -a 350-355@1080000:evtree -a 355-355@1080010 -a 1-360@1080020 -a 0-0@1080030 -f 0-355@1080000 -f 0-355@1080030 -a 0-1@1140000:AA -a 350-355@1140000:evtree -a 355-355@1140010 -a 1-360@1140020 -a 0-0@1140030 -f 0-355@1140000 -f 0-355@1140030 -l -l0-100@30-50:V -l0-100@30-50:v -l0-100@30-50:B -l0-100@30-50:b -l0-100@30-50:C -l0-100@30-50:c -l0-100@30-50:H -l0-100@30-50:h -l0-1000@0:B -l0-1000@0:V -l0-1000@0:C -l0-1000@0:H -l0-100@30-50:-V -l0-100@30-50:-v -l0-100@30-50:-C -l0-100@30-50:-c -l0-100@30-50:-H -l0-100@30-50:-h -l0-1000@0:-V -l0-1000@0:-C -l0-1000@0:-H -d 20-24@4 -d 90-95@6 -d 50-56@4 -d 57-61@4 -d 96-99@4 -d 78-82@6 -d 25-29@5 -d 10-15@4 -d 35-40@6 -d 20-24@22 -d 90-95@24 -d 50-56@22 -d 57-61@22 -d 96-99@22 -d 78-82@24 -d 25-29@23 -d 10-15@22 -d 35-40@24 -d 35-40@42 -b -2 -D -C o:5 -a 1-8@1.1:12345678 -a 0-1@1.2 -a 8-9@1.3 -a 5-6@1.4:ab -l0-10@0-1 -f 0-10@1 -f 0-10@2 -l0-10@0-1:b -a 0-8589934592@2 -f 0-10@3 -a 1-3@3:aaa -f 0-10@4 -d 0-1@1.2 -f 0-10@4 -d 0-8589934592@2 -f 0-10@4 -a 0-562949953421312@5 -f 0-10@5 -b -2 -D -C o:4 -a 0-1@1:ab -a 2-3@1:ab -a 4-5@1:ab -a 6-7@1:ab -a 9223372036854775808-9223372036854775809@1:ab -b -2 -D -C o:5 -a 0-1@1:ab -a 1-2@2:cd -a 3-4@3:bc -a 5-7@4:def -a 6-8@5:xyz -a 1-2@6:aa -a 4-7@7:abcd -b -2 -r -0-5@8 -b -2 -r 0-5@3 -b -2 -D &> ${LNAME}.log

Results: 9 Leak_StillReachable, 1 Leak_DefinitelyLost

```
[memcheck xmls](ut_memcheck_results/3-evt-sequence-leaks.xml) and [test logs](ut_logs/3-evt-sequence-leaks.log)

* 4 btree ukey -s 20000 
```
LNAME="4-btree-ukey-20000";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./src/common/test/btree.sh ukey -s 20000 &> ${LNAME}.log
Results: 6674 Leak_StillReachable
```

* 5 btree direct -s 20000
```
LNAME="5-btree-direct-20000";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./src/common/test/btree.sh direct -s 20000 &> ${LNAME}.log
Results: 6683 Leak_StillReachable
```

* 6 btree -s 20000
```
LNAME="6-btree-20000";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./src/common/test/btree.sh -s 20000 &> ${LNAME}.log
Results: 6666 Leak_StillReachable
```


* 7 btree perf -s 20000
```
LNAME="7-btree-perf-20000";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./src/common/test/btree.sh perf -s 20000 &> ${LNAME}.log
Results: 6716 Leak_StillReachable
```

* 8 btree perf direct -s 20000
```
LNAME="8-btree-perf-direct-20000";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./src/common/test/btree.sh perf direct -s 20000 &> ${LNAME}.log
Results: 6738 Leak_StillReachable
```

* 9 btree perf ukey -s 20000
```
LNAME="9-btree-perf-ukey-20000";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./src/common/test/btree.sh perf ukey -s 20000 &> ${LNAME}.log
Results: 6711 Leak_StillReachable
```

* 10 btree dyn ukey -s 20000
```
LNAME="10-btree-dyn-ukey-20000";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./src/common/test/btree.sh dyn ukey -s 20000 &> ${LNAME}.log

Results: 6723 Leak_StillReachable
```

* 11 btree dyn -s 20000
```
LNAME="11-btree-dyn-20000";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./src/common/test/btree.sh dyn -s 20000 &> ${LNAME}.log

Results: 6712 Leak_StillReachable
```

* 12 btree dyn perf -s 20000
```
LNAME="12-btree-dyn-perf-20000";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./src/common/test/btree.sh dyn perf -s 20000 &> ${LNAME}.log

Results: 6769 Leak_StillReachable
```

* 13 btree dyn perf ukey -s 20000
```
LNAME="13-btree-dyn-perf-ukey-20000";
valgrind --leak-check=full --show-reachable=yes --error-limit=no --xml=yes --xml-file="test_results/${LNAME}.xml" \
	    --num-callers=24 --keep-debuginfo=yes --track-origins=yes \
	    ./src/common/test/btree.sh dyn perf ukey -s 20000 &> ${LNAME}.log

Results: 6758 Leak_StillReachable
```

Note that btree unit testing was run using [run-ut-btree.sh](run-ut-btree.sh) script.
