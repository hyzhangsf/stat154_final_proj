# Hanyu Zhang
# Problem 1
# print the total number of messages, # of spam and ham messages
from collections import namedtuple
name = 'train_msgs.txt'
Message = namedtuple('Message', ['type', 'text'], verbose=False)
lines = None
with open(name) as f:
	lines = [Message(*line.strip().split('\t')) for line in f]
isSpam = lambda message: message.type == 'spam'
numMessages = len(lines)
numSpam = len(filter(isSpam, lines))
numHam = numMessages - numSpam
print "total # of text message is {0}".format(numMessages)
print "# of spam is {0}, {1}%".format(numSpam, 100.0*numSpam/numMessages)
print "# of ham is {0}, {1}%".format(numHam, 100.0*numHam/numMessages)