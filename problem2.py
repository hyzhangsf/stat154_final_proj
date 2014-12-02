# coding: utf-8
__author__ = 'zz'
import re
fin = open('train_msgs.txt', 'r')
fout = open('svm_features.csv', 'w')
stopwords = {}
contractions = {}
dictionary = {}
res = []

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
    for line in lines:
        line = line.lower()
        rawLines.append(line)
        line = re.sub("[^0-9a-zA-Z]+", ' ', line)
        words = [word for word in line.split()[1:] if word not in stopWordSet]
        features.update(words)
        featuresInlines.append(words)
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
    print '{0} features'.format(len(features))
    print 'wrote {0} lines to {1}'.format(len(rows), 'svm_features.csv')

saveMatrix(*find_features(lines))
