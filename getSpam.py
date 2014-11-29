import os
fin=open('train_msgs.txt','r')
fout=open('spams.txt','w')

for line in fin:
	tmp=line.split();
	if tmp[0]=="spam":
		fout.write(line)
fout.seek(-1,os.SEEK_END)
fout.truncate()
fout.close()