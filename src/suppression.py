import re


class Suppression:
    def __init__(self, name, tool, array, string):
        self.name = name
        self.tool = tool
        self.array = array
        self.string = string

    def __eq__(self, other):
        if self.string == other.string:
            return True
        else:
            return False

    def __repr__(self):
        ret = "{\n"
        ret += "   {}\n   {}\n".format(self.name, self.tool)
        for i in self.array:
            ret += "   {}\n".format(i)
        ret += "}\n"
        return ret

    def __str__(self):
        return self.string

    def save_in(self, directory):
        with open(directory, "a") as myfile:
            myfile.write("{\n")
            myfile.write("   {}\n".format(self.name))
            myfile.write("   {}\n".format(self.tool))
            for element in self.array:
                myfile.write("   {}\n".format(element))
            myfile.write("}\n")



class SuppressionFileIterator:
    def __init__(self, sf):
        self._sf = sf
        self._index = 0

    def __next__(self):
        if self._index < len(self._sf.suppressions):
            result = self._sf.suppressions[self._index]
            self._index += 1
            return result
        raise StopIteration


class SuppressionFile:
    def __init__(self, file_name):
        self.suppressions = []
        self.suppression_file = file_name

        lst_supp = []
        str_supp = ""
        # Get list with suppressions
        with open(self.suppression_file, 'r') as f:
            data = f.read().replace('\n', '')
        lst_supp = re.findall(r'\{.*?\}', data)

        # Remove repeated suppressions
        lst_supp = list(set(lst_supp))

        # Store it in self.suppressions list
        for element in lst_supp:
            element = element[1:-1]
            element = element.strip()
            element = re.sub(r'[\s]*:[\s]*',r':', element)
            str_supp = element
            element = element.split('   ')
            sup = Suppression(element[0],
                              element[1],
                              element[2:],
                              str_supp)
            self.add_suppression(sup)

    def __eq__(self, other):
        if not isinstance(other, SuppressionFile):
            return False
        if self.len() != other.len():
            return False
        for sp in self.suppressions:
            found = False
            for ot in other.suppressions:
                if sp == ot:
                    found = True
            if found == False:
                return False
        return True

    def __iter__(self):
        return SuppressionFileIterator(self)

    def __len__(self):
        return len(self.suppressions)

    def add_suppression(self, supp):
        self.suppressions.append(supp);


    def save(self, dir_to_save):
        for sup in self.suppressions:
            sup.save_in(dir_to_save)
