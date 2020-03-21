# -*- coding: utf-8 -*-
"""
Created on Thu May 16 16:20:55 2019

@author: Healey  (Luke Remage-Healey)
"""
import numpy as np
import matplotlib.pyplot as plt
import os
from neo import io

"""takes a stack of Igor PMPulse files ('ibw') inside a folder, reads them in, and
generates an overlay as well as mean+sem graph for quick visualization, 
and and array 'arry.npy' to be used later for analysis"""


def addfolder():
    """helper function to add '.ibw' files from a designated folder and feed them iteratively below"""
    textfiles = []
    files = os.listdir()
    for i in range(len(files)):
        if files[i].endswith('.ibw'):
            textfiles.append(files[i])
        
    return textfiles

folder = addfolder()


"""generates an order of the files in the folder, in case this is needed later"""
order = []
for i in folder:
    order.append(i)


"""reads the Igor files using the neo IO, and converts them to Analogsignals.
See neo documentation for more on this format"""

def addtrial2():
    a = []
    for i in folder:
        r = io.IgorIO(filename=i)
             
        a.append(r.read_analogsignal())
    return a

"""below runs the routine and converts to a numpy array. The numpy 'reshape'  converts 
3D arrays into 2D arrays, to allow them to be saved, manipulated, etc. 
There are probably better ways of doing this, but this works."""

arr2 = addtrial2()

arr1 = np.array(arr2)

arr = arr1.reshape(len(arr1), len(arr1[0]))



        
np.savetxt('arry.npy', arr)  #creates new file
np.save('arry.npy', arr)    #saves the array as a numpy array for later use
#arr = np.load('arry.npy')  #loads the array in another console, etc.
    



#once done adding the trials, you can then plot the average:
       
u = np.mean(arr, axis=0).reshape(arr[1].size)
x = np.array([[list(range(u.size))]]) 
std = np.std(arr, axis=0).reshape(arr[1].size)
se = (np.std(arr, axis=0)/np.sqrt(len(arr))).reshape(arr[1].size)
plt.figure('inward currents')
plt.plot(u)
plt.fill_between(list(range(u.size)), (u+se), (u-se), facecolor='blue', alpha=0.5)  
plt.show()

# to get the overlays of all plots:

fig, ax = plt.subplots()

for i in range(len(arr)):
    
    ax.plot(arr[i], linewidth=0.3, markersize=0.005, label = str(i))

    ax.plot()
#    ax.legend()
    
#to add the mean+-se to the plot:

ax.plot(u, label = 'mean + sem')
ax.fill_between(list(range(u.size)), (u+se), (u-se), facecolor='blue', alpha=0.5)
ax.legend()



# """below can bring two recording epochs together to compare them visually"""

# op = np.load('arry.npy')  #"in one directory"
# pre = np.load('arry.npy')  #"in another directory"
# uop = np.mean(op, axis=0).reshape(op[1].size)
# xop = np.array([[list(range(uop.size))]]) 
# stdop = np.std(op, axis=0).reshape(op[1].size)
# seop = (np.std(op, axis=0)/np.sqrt(len(op))).reshape(op[1].size)
# upre = np.mean(pre, axis=0).reshape(pre[1].size)
# xpre = np.array([[list(range(pre.size))]]) 
# stdpre = np.std(pre, axis=0).reshape(pre[1].size)
# sepre = (np.std(pre, axis=0)/np.sqrt(len(pre))).reshape(pre[1].size)


# fig, ax = plt.subplots()
# ax.plot(uop, label = 'mean + sem')
# ax.fill_between(list(range(uop.size)), (uop+seop), (uop-seop), facecolor='blue', alpha=0.5)
# ax.plot(upre, label = 'pre')
# ax.fill_between(list(range(upre.size)), (upre+sepre), (upre-sepre), facecolor='pink', alpha=0.5)
# ax.legend()

