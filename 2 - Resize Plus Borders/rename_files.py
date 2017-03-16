##Renaming Files
#This script runs through a directory and renames AVIRIS files.
#Susan Meerdink
#5/4/16
#--------------------------------------------------------------

import os # os is a library that gives us the ability to make OS changes
import glob
 
directory = 'R:\\Image-To-Image Registration\\' #Set directory
#fl_list = ['01','02','03','04','05','06','07','08','09','10','11'] #Set the flightlines you want to rename
fl_list = ['02'] #Set the flightlines you want to rename

for folder in fl_list: #Loop through folders
    os.chdir(directory + 'SB_FL' + folder + '\\AVIRIS\\') #Change directory to the current folder
    files_list = glob.glob('*') #Get list of all files in directory
    print('Renaming files in folder: ' + 'FL' + folder)

    for one in files_list: #Loop through files
        if 'FL' not in one: #If it hasn't already been renamed
            if '140416' in one:
                new = 'FL0' + folder + '_' + one #New Folder name
                os.rename(one, new) #Rename the file
            else:
                new = 'FL'+ folder + '_' + one #New Folder name
                os.rename(one, new) #Rename the file
            
    
print('Done Renaming Files')
