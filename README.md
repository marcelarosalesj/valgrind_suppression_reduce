# Reduce valgrind suppressions tool

Valgrind can generate automatically extensive `supp` files. The goal of this
tool is to reduce them.  

* First, get rid of the repeated leak errors.
* Then, identify the common root cause of some of the erros, and reduce them to
  one by using wildcards.
