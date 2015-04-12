import sys

from ela.classifier import ELAClassifier


def main():
    classifier = ELAClassifier()
    result = classifier.predict_with_image_path(sys.argv[1])
    print result

if __name__ == '__main__':
    main()
