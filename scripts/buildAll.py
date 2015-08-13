import sys
import os
import itertools

firmVersions=["OLD", "NEW"]
ironVersions=["10", "11", "10_eu", "11_eu"]
saveSlots=["0", "1", "2"]

a=[firmVersions, ironVersions, saveSlots]

cnt=0
for v in (list(itertools.product(*a))):
	os.system("make clean")
	os.system("make FIRM_VERSION="+str(v[0])+" IRON_VERSION="+str(v[1])+" IRON_SAVESLOT="+str(v[2]))
	cnt+=1
print(cnt)
