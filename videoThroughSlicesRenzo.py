#!/usr/bin/python
# credit to Sebastian Dresbach 
# execute with python3 videoThroughSlicesRenzo.py 'BOLD.nii' 6
import nibabel as nb
import numpy as np
import imageio
import scipy
from scipy import ndimage
import os
import sys
import glob



print('\n')
print('Starting')
print('\n')


data = sys.argv[1]
print(f'the path to the data is: {data}')


sliceNr = sys.argv[2]
print(f'the chosen slice is: {sliceNr}')


path = os.getcwd()
dumpFolder = path + "/tmpGifImages"


try:
    os.mkdir(dumpFolder)

except OSError:
    print ("Creation of the dump directory %s failed" % path)
else:
    print ("Successfully created the dump directory in: %s " % path)


dataArr = nb.load(data).get_fdata()

globalMax = 0
globalMin = 0

for frame in range(dataArr.shape[3]):
    imgData = dataArr[:,:,int(sliceNr),frame]
    rotated_img = ndimage.rotate(imgData, 90)

    if np.amin(rotated_img) <= globalMin:
        globalMin = np.amin(rotated_img)
    if np.amax(rotated_img) >= globalMax:
        globalMax = np.amax(rotated_img)

for frame in range(dataArr.shape[3]):
    imgData = dataArr[:,:,int(sliceNr),frame]
    rotated_img = ndimage.rotate(imgData, 90)


    rotated_img[0,0] = globalMax
    rotated_img[0,1] = globalMin

    rotated_img = (rotated_img - globalMin)/ (globalMax-globalMin)
    rotated_img = rotated_img.astype(np.float64)  # normalize the data to 0 - 1
    rotated_img = 255 * rotated_img # Now scale by 255
    img = rotated_img.astype(np.uint8)

    imageio.imwrite(f'{dumpFolder}/frame{frame}.png', img)


files = sorted(glob.glob('/home/sebastian/Downloads/tmpGifImages/*.png'))
files = sorted(glob.glob(dumpFolder + '/*.png'))
print(f'Creating gif from {len(files)} images')
images = []
for file in files:
    filedata = imageio.imread(file)
    images.append(filedata)

imageio.mimsave(f'{os.path.splitext(data)[0]}_slice{int(sliceNr)}_movie.gif', images, duration = 1/10)
print('Deleting dump directory')
os.system(f'rm -r {dumpFolder}')
print('Done.')
