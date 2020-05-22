import mock
import unittest
import logging
import sys

print(sys.path)

#from suppression import Suppresion, SuppressionFile
import suppression as supp

class testSuppressionFile(unittest.TestCase):

    def create_suppression(self):

        name ="<insert_a_suppression_name_here>"
        tool = "Memcheck:Leak"
        arr = ["match-leak-kinds: reachable", "fun:malloc", "fun:sysfs_init", "fun:_dl_init", "obj:/usr/lib64/ld-2.17.so"]
        s1 = supp.Suppression(name, tool, arr)
        assertEquals(s1.name, "marcela")
