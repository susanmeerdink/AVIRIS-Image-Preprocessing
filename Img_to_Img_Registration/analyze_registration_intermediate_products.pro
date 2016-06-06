PRO analyze_registration_intermediate_products
;susan meerdink
;6/2/106
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

origFolder = 'H:\users\meerdink\Image_to_Image_Registration\SB_FL4\AVIRIS\'
affineFolder = 'H:\users\meerdink\Image_to_Image_Registration\SB_FL4\AVIRIS_registered_best_affine_2016-05-31_1012\'
linearFolder = 'H:\users\meerdink\Image_to_Image_Registration\SB_FL4\AVIRIS_registered_best_linear_2016-06-01_1630\'

;read in control file information
cfile = 'H:\users\meerdink\GitHub\AVIRIS-Image-Preprocessing\Img_to_Img_Registration\ControlFile.txt'
openu,1,cfile
readf,1,dateIndex,bandIndex

;Set some variables for displaying
dates = ['130411','130606','131125','140606','140829']
channels = [25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100,104,117,120,130,140,150,190,195,200,205,210,220]
dateString = dates[dateIndex]

;Find and open original/base file
origFile = FILE_SEARCH(origFolder,'*FL00*')
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
ENVI_DISPLAY_BANDS, origFID, bandIndex, $ ;POS = channelCurrent ;one- or three-element array of long integers representing band positions
  IMAGE_SIZE = imgSize,$ ;keyword to specify a two-element array of long integers representing the x and y size in screen pixels
  IMAGE_OFFSET = [0,0],$ ;keyword to specify a two-element array of long integers representing the x and y offset in screen pixels
  ZOOM_FACTOR = 10, $ ;keyword to specify the initial zoom factor for the Zoom window.
  ZOOM_SIZE = zoomSize, $ ;keyword to specify a two-element array of long integers representing the x and y size in screen pixels
  /NEW ;/NEW ;Set this keyword to create a new display group.
ENVI_DISPLAY_BANDS, affineFID, bandIndex, $ ;POS = channelCurrent ;one- or three-element array of long integers representing band positions
  IMAGE_SIZE = imgSize, $ ;keyword to specify a two-element array of long integers representing the x and y size in screen pixels
  IMAGE_OFFSET = [dimensions[0]/3,0], $ ;keyword to specify a two-element array of long integers representing the x and y offset in screen pixels
  ZOOM_FACTOR = 10, $ ;keyword to specify the initial zoom factor for the Zoom window.
  ZOOM_SIZE = zoomSize, $ ;keyword to specify a two-element array of long integers representing the x and y size in screen pixels
  /NEW ;/NEW ;Set this keyword to create a new display group.
ENVI_DISPLAY_BANDS, linearFID, bandIndex,$ ;POS = channelCurrent ;one- or three-element array of long integers representing band positions
  IMAGE_SIZE = imgSize, $ ;keyword to specify a two-element array of long integers representing the x and y size in screen pixels
  IMAGE_OFFSET = [dimensions[0]/3 + dimensions[0]/3,0], $ ;keyword to specify a two-element array of long integers representing the x and y offset in screen pixels
  ZOOM_FACTOR = 10, $ ;keyword to specify the initial zoom factor for the Zoom window.
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
if dateIndex GT 4 then begin
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