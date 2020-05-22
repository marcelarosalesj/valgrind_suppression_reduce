import re

class Suppression:
    def __init__(self, name, tool, array = []):
        self.name = name
        self.tool = tool
        self.array = array


class SuppressionFile:
    def __init__(self, name):
        self.name = name
        self.suppressions = []

    def add_suppression(self, supp):
        self.suppressions.append(supp);


class Parser:
    def __init__(self, ff):
        self.suppression_file = ff
        self.search_results = []

    def split_into(self, sfo):
        if not isinstance(sfo, SuppressionFile):
            return False

        # Get list with suppressions
        with open(self.suppression_file, 'r') as f:
            data = f.read().replace('\n', '')
        self.search_results = re.findall(r'\{.*?\}', data)

        # Remove repeated suppressions
        self.search_results = list(set(self.search_results))

        # Store it in the sfo SuppressionFile object
        for element in self.search_results:
            element = element[1:-1]
            element = re.sub(r'[\s]*:[\s]*',r':', element)
            element = element.split()

            sup = Suppression(element[0],
                              element[1],
                              element[2:])
            sfo.add_suppression(sup)


