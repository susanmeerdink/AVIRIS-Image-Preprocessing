PRO analyze_registration_intermediate_products
;This code helps visualize the intermediate products of Zach Tane and Alex koltunov's code.
;Zach does a run through of all the images and outputs two images using two methods (affine and linear).
;The user needs to go through band by band and compare these two methods
;Ultimately the user will choose which band and method produces an image that is the closest to the base image.
;susan meerdink
;6/2/106
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

origFolder = 'H:\users\meerdink\Image_to_Image_Registration\SB_FL1\AVIRIS\'
affineFolder = 'H:\users\meerdink\Image_to_Image_Registration\SB_FL1\AVIRIS_registered_best_affine_2016-05-31_0956\'
linearFolder = 'H:\users\meerdink\Image_to_Image_Registration\SB_FL1\AVIRIS_registered_best_linear_2016-06-02_0827\'

;read in control file information
cfile = 'H:\users\meerdink\GitHub\AVIRIS-Image-Preprocessing\Img_to_Img_Registration\ControlFile.txt'
openu,1,cfile
readf,1,dateIndex,bandIndex

;Set some variables for displaying
;dates = ['130411','130606','131125','140606','140829'] ;This may have to change based on which dates are available
dates = ['130411','130606','131125','140829'] ;For FL1 & FL6
;dates = ['130411','130606','131125','131204','140606','140829'] ;For FL3
;dates = ['130411','130606','131204','140606','140829'] ;For FL5
;dates = ['130411','130606','131125','140604','140829'] ;For FL7
;dates = ['130411','130606','131125','131204','140604','140606','140829'] ;For FL8 
;dates = ['130411','131125','131204','140604','140829'] ; For FL10
;dates = ['130411','130606','131125','131204','140606','140829'] ;For FL11
channels = [25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100,104,117,120,130,140,150,190,195,200,205,210,220]
dateString = dates[dateIndex]
origIndex = channels[bandIndex]-1

;Find and open original/base file
origFile = FILE_SEARCH(origFolder,'*FL00*') ; For FL 1 -9
;origFile = FILE_SEARCH(origFolder,'*FL01*') ; For FL 10 & 11
ENVI_OPEN_FILE, origFile[0], R_FID = origFID

;Find and open affine file
affineFile = FILE_SEARCH(affineFolder,'*' + dateString+ '*')
ENVI_OPEN_FILE, affineFile[0], R_FID = affineFID

;Find and open linear file
linearFile = FILE_SEARCH(linearFolder,'*' + dateString+ '*')
ENVI_OPEN_FILE, linearFile[0], R_FID = linearFID

;Close any displays open
DN = ENVI_GET_DISPLAY_NUMBERS()
if size(DN,/N_ELEMENTS) GT 1 then begin
  foreach n,DN do begin
    ENVI_CLOSE_DISPLAY, n
  endforeach
endif

;Set Display Size
dimensions = GET_SCREEN_SIZE(RESOLUTION=resolution) ;width by height
imgSize = [dimensions[0]/3,dimensions[1]/2]
zoomSize = [dimensions[0]/3.5,dimensions[1]/4]

;Display Bands
;Ariel Zoom Factor = 14
;Laptop Zoom Factor = 10
zoomFactor = 14
ENVI_DISPLAY_BANDS, origFID, origIndex, $ ;POS = channelCurrent ;one- or three-element array of long integers representing band positions
  IMAGE_SIZE = imgSize,$ ;keyword to specify a two-element array of long integers representing the x and y size in screen pixels
  IMAGE_OFFSET = [0,0],$ ;keyword to specify a two-element array of long integers representing the x and y offset in screen pixels
  ZOOM_FACTOR = zoomFactor, $ ;keyword to specify the initial zoom factor for the Zoom window.
  ZOOM_SIZE = zoomSize, $ ;keyword to specify a two-element array of long integers representing the x and y size in screen pixels
  /NEW ;/NEW ;Set this keyword to create a new display group.
ENVI_DISPLAY_BANDS, affineFID, bandIndex, $ ;POS = channelCurrent ;one- or three-element array of long integers representing band positions
  IMAGE_SIZE = imgSize, $ ;keyword to specify a two-element array of long integers representing the x and y size in screen pixels
  IMAGE_OFFSET = [dimensions[0]/3,40], $ ;keyword to specify a two-element array of long integers representing the x and y offset in screen pixels
  ZOOM_FACTOR = zoomFactor, $ ;keyword to specify the initial zoom factor for the Zoom window.
  ZOOM_SIZE = zoomSize, $ ;keyword to specify a two-element array of long integers representing the x and y size in screen pixels
  /NEW ;/NEW ;Set this keyword to create a new display group.
ENVI_DISPLAY_BANDS, linearFID, bandIndex,$ ;POS = channelCurrent ;one- or three-element array of long integers representing band positions
  IMAGE_SIZE = imgSize, $ ;keyword to specify a two-element array of long integers representing the x and y size in screen pixels
  IMAGE_OFFSET = [dimensions[0]/3 + dimensions[0]/3,40], $ ;keyword to specify a two-element array of long integers representing the x and y offset in screen pixels
  ZOOM_FACTOR = zoomFactor, $ ;keyword to specify the initial zoom factor for the Zoom window.
  ZOOM_SIZE = zoomSize, $ ;keyword to specify a two-element array of long integers representing the x and y size in screen pixels
  /NEW ;/NEW ;Set this keyword to create a new display group.
  
print,'Loaded Band ' + STRING(channels[bandIndex]) + ' for date ' + dateString

;Set next date and channel
; 28 total channels
; 5 total dates
bandIndex = bandIndex + 1 ;advance the band index
if bandIndex GT 27 then begin
  dateIndex = dateIndex + 1 ;If it the last channel move on to the next date
  bandIndex = 0
endif 
if dateIndex GT size(dates,/N_ELEMENTS) then begin
  print,'Flightline completed'
  dateIndex = 0
  bandIndex = 0
endif

;Write values to file
close, 1
openw, 1, cfile
printf, 1, STRING(FIX(dateIndex))
printf, 1, STRING(FIX(bandIndex))
close, 1

END