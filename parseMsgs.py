#coding: utf-8
import re
fin=open('train_msgs.txt','r')
fout=open('output.csv','w')
stopwords={}
contractions={}
dictionary={}
res=[]

for word in ["a","n","able","about","across","after","all","almost","also","am","among","an","and","any","are","as","at","be","because","been","but","by","can","cannot","could","dear","did","do","does","either","else","ever","every","for","from","get","got","had","has","have","he","her","hers","him","his","how","however","i","if","in","into","is","it","its","just","least","let","like","likely","may","me","might","most","must","my","neither","no","nor","not","of","off","often","on","only","or","other","our","own","rather","said","say","says","she","should","since","so","some","than","that","the","their","them","then","there","these","they","this","tis","to","too","twas","us","wants","was","we","were","what","when","where","which","while","who","whom","why","will","with","would","yet","you","your"]:
	stopwords[word]=None
for contraction in ["dont","won't","can't","isn't","aren't","wasn't","weren't","haven't","hasn't","hadn't","won't","wouldn't","don't","doesn't","didn't","can't","couldn't","shouldn't","mightn't","mustn't"]:
	contractions[contraction]=None
for line in fin:
	#all lowercase
	line=line.lower()
	
	#remove contractions
	line=re.sub("'m|'s|'ve|'re|'d|'ll","",line)
	tmp=line.split()
	for i in range(len(tmp)):
		if tmp[i] in contractions:
			tmp[i]=""
	line=" ".join(tmp)
	
	#replace all nonalphanumeric
	line=re.sub("[^0-9a-z]"," ",line)
	
	#remove numeric sequences
	line=re.sub("[0-9]+ [0-9]+"," ",line)
	line=re.sub("[0-9]{5,50}"," ",line)

	#remove alphanumeric words: eg.kagbew2433
	line=re.sub("([a-z]+[0-9]+|[0-9]+[a-z]+)[^\s\-,]*"," ",line)

	#remove extra space
	line=re.sub(" +"," ",line)
	
	#remove all stopwords
	#process all remaining words
	print line
	tmp=line.split()
	msg=["s" if tmp[0]=="spam" else "h"]
	for i in range(1,len(tmp)):
		if tmp[i] not in stopwords:
			if tmp[i] not in dictionary:
				dictionary[tmp[i]]=len(dictionary)
			msg.append(dictionary[tmp[i]])

	if(len(msg)>1):
		res.append(msg)


allwords=[None]*len(dictionary)
for word in dictionary:
	allwords[dictionary[word]]=word
allwords=re.sub("[ \']","",str(allwords))
fout.write("class,"+allwords[1:(len(allwords)-1)])

for msg in res:
	tmp=[0]*len(dictionary)
	for i in range(1,len(msg)):
		tmp[msg[i]]+=1.0/(len(msg)-1)
	tmp=str(tmp)
	tmp=re.sub(" ","",tmp)
	fout.write("\n"+msg[0]+","+tmp[1:(len(tmp)-1)])
#prints out the number of columns
print len(dictionary)
fin.close()
fout.close()