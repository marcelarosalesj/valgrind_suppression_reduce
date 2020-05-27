import suppression as supp
import argparse

parser = argparse.ArgumentParser(description='Valgrind suppressions reduce')
parser.add_argument('-i', '--input_file', required=True, help='provide input supp file')


def main():
    args = parser.parse_args()
    input_file = args.input_file

    sf = supp.SuppressionFile(input_file)

    print("SF len is ", len(sf))

    sf.save("tmp.log")

    print("Finish")

if __name__ == '__main__':
    main()
