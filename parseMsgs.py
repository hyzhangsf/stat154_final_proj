#coding: utf-8
import re
from powerFeature import ALL_FUNCTIONS
#input file
fin=open('train_msgs.txt','r')
#output file
fout1=open('train_word.csv','w')
fout2=open('train_pwr.csv','w')
stopwords={}
contractions={}
dictionary={}
res=[]

fout2.write("class_label,"+",".join(['f'+str(i+1) for i in range(len(ALL_FUNCTIONS))]))

STOPWORDS=set(["a","n","able","about","across","after","all","almost","also",
	"am","among","an","and","any","are","as","at","be","because","been","but","by",
	"can","cannot","could","dear","did","do","does","either","else","ever","every",
	"for","from","get","got","had","has","have","he","her","hers","him","his","how",
	"however","i","if","in","into","is","it","its","just","least","let","like",
	"likely","may","me","might","most","must","my","neither","no","nor","not","of",
	"off","often","on","only","or","other","our","own","rather","said","say","says",
	"she","should","since","so","some","than","that","the","their","them","then",
	"there","these","they","this","tis","to","too","twas","us","wants","was","we",
	"were","what","when","where","which","while","who","whom","why","will","with",
	"would","yet","you","your"])

#removes contraction in a line of input
def restore_contraciton(line):
	line=re.sub("'s","",line)
	line=re.sub("won't|wont","will not",line)
	line=re.sub("dont","do not",line)
	line=re.sub("can't","cannot",line)
	line=re.sub("n't"," not",line)
	line=re.sub("'m"," am",line)
	line=re.sub("'ve"," have",line)
	line=re.sub("'re"," are",line)
	line=re.sub("'d"," would",line)
	line=re.sub("'ll"," will",line)
	return line

for line in fin:
	#extract and write all power features:
	tmp=line.split()
	class_label=tmp[0]
	line=" ".join(tmp[1:])

	pwr = [str(f(line)) for f in ALL_FUNCTIONS]
	fout2.write("\n"+class_label+","+",".join(pwr))

	#all lowercase
	line=line.lower()
	
	#remove contractions
	line=restore_contraciton(line)
	
	#remove alphanumeric words: eg.kagbew2433
	line=re.sub("([a-z]+[0-9]+|[0-9]+[a-z]+)[^\s\-,]*"," ",line)

	#replace all nonwords
	line=re.sub("[^a-z]"," ",line)
		
	#remove extra space
	line=re.sub(" +"," ",line)
	
	#remove all stopwords
	#process all remaining words
	#dictionary is stored as word:index pairs
	#each msg is parsed as its classification followed by a list of indices
	tmp=line.split()
	msg=[class_label]
	for i in range(len(tmp)):
		if tmp[i] not in dictionary:
			dictionary[tmp[i]]=len(dictionary)
		msg.append(dictionary[tmp[i]])
	res.append(msg)

#first line of input, lists all word features
allwords=[None]*len(dictionary)
for word in dictionary:
	allwords[dictionary[word]]=word
allwords=",".join(allwords)
fout1.write("class,"+allwords)

#writes the frequency of each message
for msg in res:
	tmp=[0]*len(dictionary)
	if len(msg)>1:
		for i in range(1,len(msg)):
			tmp[msg[i]]+=1.0/(len(msg)-1)
	tmp=",".join(map(str, tmp))
	fout1.write("\n"+msg[0]+","+tmp)

#prints out the number of word features
print len(dictionary)

#close all files
fin.close()
fout1.close()
fout2.close()
