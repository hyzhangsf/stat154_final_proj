# coding: utf-8
__author__ = 'zz'
import re
from collections import Counter
fin = open('train_msgs.txt', 'r')
fout = open('svm_features.csv', 'w')


stopWordList = ["a", "n", "able", "about", "across", "after", "all", "almost",
             "also", "am", "among", "an", "and", "any", "are", "as", "at", "be",
             "because", "been", "but", "by", "can", "cannot", "could", "dear",
             "did", "do", "does", "either", "else", "ever", "every", "for", "from",
             "get", "got", "had", "has", "have", "he", "her", "hers", "him", "his",
             "how", "however", "i", "if", "in", "into", "is", "it", "its", "just",
             "least", "let", "like", "likely", "may", "me", "might", "most", "must", "my", "neither", "no", "nor",
             "not", "of", "off", "often", "on", "only", "or", "other", "our", "own", "rather", "said", "say", "says",
             "she", "should", "since", "so", "some", "than", "that", "the", "their", "them", "then", "there", "these",
             "they", "this", "tis", "to", "too", "twas", "us", "wants", "was", "we", "were", "what", "when", "where",
             "which", "while", "who", "whom", "why", "will", "with", "would", "yet", "you", "your"]


stopWordSet = set(stopWordList)

lines = fin.readlines()

def find_features(lines):
    '''
    :param lines:
    :return: filtered lines and a list of filtures
    '''

    features = set()
    featuresInlines = []
    rawLines = []
    counter = Counter()
    for line in lines:
        line = line.lower()
        rawLines.append(line)
        line = re.sub("[^0-9a-zA-Z&]+", ' ', line)
        words = [word for word in line.split()[1:] if word not in stopWordSet]
        words = [word for word in words if not word.isdigit()]
        features.update(words)
        featuresInlines.append(words)
        for word in words:
            counter[word] += 1
    print (counter.most_common(100))
    return rawLines, featuresInlines, list(features - stopWordSet)

def saveMatrix(rawLines, featuresInlines, features):
    head = features[:]+['isHam']
    fout.write(",".join(head)+'\n')
    rows = []
    for num, line in enumerate(featuresInlines):
        if line:
            rawLine = rawLines[num]
            label = 'ham' if rawLine.startswith('ham') else 'spam'
            row = ','.join([str(1.0*line.count(feature)/len(line)) for feature in features]) + ','+label + '\n'
            rows.append(row)
    fout.writelines(rows)
    print ('{0} features'.format(len(features)))
    print ('wrote {0} lines to {1}'.format(len(rows), 'svm_features.csv'))
    return features

features = saveMatrix(*find_features(lines))

def generate_test_set(test_data_name, features):
    featureSet = set(features)
    lines = []
    rawLines = []
    with open(test_data_name) as f:
        for line in f:
            rawLines.append(line)
            line = line.lower()
            line = re.sub("[^0-9a-zA-Z&]+", ' ', line)
            words = [word for word in line.split()[1:] if word not in stopWordSet]
            words = [word for word in words if not word.isdigit()]
            words = [word for word in words if word in featureSet]
            lines.append(words)

    with open('svm_test.csv', 'w') as test_data:
        head = features[:]+['isHam']
        test_data.write(",".join(head)+'\n')
        rows = []
        for num, line in enumerate(lines):
            if line:
                rawLine = rawLines[num]
                label = 'ham' if rawLine.startswith('ham') else 'spam'
                row = ','.join([str(1.0*line.count(feature)/len(line)) for feature in features]) + ','+label + '\n'
                rows.append(row)
        test_data.writelines(rows)



generate_test_set('test_msgs.txt', features)







