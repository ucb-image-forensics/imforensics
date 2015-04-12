import sys

from .classifier import ELAClassifier
from ..ela import ELA

def main():
    classifier = ELAClassifier()

    result = classifier.predict_message(ELA(sys.argv[1]))
    print result

if __name__ == '__main__':
    main()
