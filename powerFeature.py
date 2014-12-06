#coding: utf-8
import re

#phone number
def f1(line):
	return re.search("[0-9]{2,4}[\.\- ]?[0-9]{2,5}[\.\- ]?[0-9]{2,5}",line) is not None	
	# 	return 1
	# else:
	# 	return 0

#money symbol
def f2(line):
	pt=re.compile(ur'£|\$',re.UNICODE)
	return re.search(pt,line) is not None
	# 	return 1
	# else:
	# 	return 0

#percentage captitalized:
#Capitalize/all latin characters
def f3(line):
	total=re.sub("[^a-zA-Z]","",line)
	cap=re.sub("[^A-Z]","",line)
	return (0.0+len(cap))/len(total) if total else 0

#percentage non characters
def f4(line):
	return (0.0+len(re.sub("[a-zA-Z]","",line)))/len(line)

#numeric sequence with length 4-6
def f5(line):
	if re.search("[^0-9][0-9]{4,8}[^0-9]",line) is not None:
		return 1
	else:
		return 0

#website address
def f6(line):
	return re.search("(www|wap|http).|[^@][0-9a-zA-Z]+\. *(com|co|net|tv)[^a-zA-Z]",line) is not None 
	# 	return 1
	# else:
	# 	return 0

#alphanumeric words
def f7(line):
	return re.search("[0-9]+[a-zA-Z]+|[a-zA-Z]+[0-9]+",line) is not None
	# 	return 1
	# else:
	# 	return 0

#number of !
def f8(line):
	tmp=re.sub("[^!]","",line)
	return len(tmp)

#presence of 0,000 and 0.00
def f9(line):
	return re.search("[0-9]+,[0-9]{3}|[0-9]+\.[0-9]{2}",line) is not None
	# 	return 1
	# else:
	# 	return 0

#presence of '[^s]: not 's
def f10(line):
	return re.search("'[^s]",line) is not None
	# 	return 1
	# else:
	# 	return 0

#length of the message
def f11(line):
	return len(line)

def f12(line):
	return '@' in line

ALL_FUNCTIONS=[f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12]
ALL_FUNCTIONS = map(lambda f: lambda x: float(f(x)), ALL_FUNCTIONS)
