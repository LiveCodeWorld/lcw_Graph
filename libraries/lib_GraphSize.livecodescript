script "lib_GraphSize"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_GraphSize
type: library
version: 0.1

/*
This library contains a collection of handlers used to set the size of a graphviz image or output.
It is a core use of graphvi to be able to fit a graph layout to a given rectangle.
*/


--> Working on
-
function dot_PixelsFromInch inchSize, pDPI 
   put dot_PointFromInch (inchSize, pDPI) into pointValue
   put dot_PointsToPixels (pointValue) into pixelValue
   return pixelValue
end dot_PixelsFromInch

function dot_PointFromInch inchSize, pDPI 
   if pDPI is empty then put 96 into pDPI 
   put inchSize * pDPI into pointValue
   return pointValue
end dot_PointFromInch

function dot_PointsToPixels sPoints
   -- PNG is in pixels at 96 dpi and xdot is in points at at 72 dpi
   put sPoints * 96 / 72 into sPixels 
   if pRound is true then
      return round (sPixels)
   else
      return sPixels
   end if
end dot_PointsToPixels

function dot_PixelsToPoints sPixels, pRound
   put sPixels * 72/96 into sPoints
   if pRound is true then
      return round (sPoints)
   else
      return sPoints
   end if
end dot_PixelsToPoints



--> DotArray | Geometry
-
function dotArray_RectFromArray nArray
   -- basic way
   get nArray["pos"]
   put item 1 of it into cx
   put item 2 of it into cy
   put 72/2 * nArray["width"] into rx
   put 72/2 * nArray["height"] into ry
   --
   put dotArray_ConvertCrxy (cx, cy, rx, ry) into newRect
   return newRect 
end dotArray_RectFromArray

function dotArray_GetRectangleRect nArray, itemNum, pScaleFactor
   get nArray ["_draw_"]
   put it [itemNum]["rect"] into rArray
   --
   put rArray [1]["color"] into bColour
   put rArray [2]["color"] into fColour
   put rArray [3]["points"] into pArray
   --
   -- put dotArray_ConvertCrxy (cx, cy, rx, ry) into newRect
   repeat with pNum = 1 to item 2 of the extents of pArray
      put pArray [pNum][1] into pX
      put pArray [pNum][2] into pY
      put pX,pY into sPoint
      --
      if pScaleFactor is a number AND pScaleFactor is not 1 then
         put loc_ScaleFromCentre (sPoint, pScaleFactor, bbCentre) into sPoint
      end if
      put sPoint & CR after sPoints
   end repeat
   delete char -1 of sPoints
   return sPoints
end dotArray_GetRectangleRect

function dotArray_GetDrawPoints nArray, itemNum
   get nArray ["_draw_"]
   put it [itemNum]["points"] into pArray
   repeat with itemNum = 1 to item 2 of the extents of pArray
      put pArray [itemNum][1] into item 1 of pLoc
      put pArray [itemNum][2] into item 2 of pLoc
      put pLoc & CR after gPoints
   end repeat
   put line 1 of gPoints after gPoints
   return gPoints
end dotArray_GetDrawPoints

function dotArray_FindDrawRect nArray
   put nArray ["_draw_"] into drawData
   put item 2 of the extents of drawData into maxItem
   repeat with itemNum = maxItem down to 1
      put drawData [itemNum]["rect"] into rArray
      if rArray is an array then
         put _RectFromFoundArray (rArray) into newRect
         return newRect
      end if
   end repeat
   return empty
end dotArray_FindDrawRect

function dotArray_GetDrawRect nArray, itemNum
   get nArray ["_draw_"]
   put it [itemNum]["rect"] into rArray
   put _RectFromFoundArray (rArray) into newRect
   return newRect
end dotArray_GetDrawRect

function dotArray_ConvertCrxy cx, cy, rx, ry
   put cx,cy into someLoc
   put 2*rx into newW
   put 2*ry into newH
   --
   put rect_LocWidthHeight (someLoc, newW, newH) into newRect
   return newRect
end dotArray_ConvertCrxy

function dotArray_GetOriginalEdgePoints edgeArray, bbRect, pTopDown
   put item 4 of bbRect - item 2 of bbRect into mY
   --
   put edgeArray ["_draw_"][2]["points"] into pArray
   repeat with itemNum = 1 to item 2 of the extents of pArray
      put pArray [itemNum][1] into sPoint
      put pArray [itemNum][2] into sY
      --
      if pTopDown is true then
         put mY - sY into item 2 of sPoint -- flip vertical
      else
         put sY into item 2 of sPoint
      end if
      --
      put sPoint & CR after edgePoints
   end repeat
   delete char -1 of edgePoints
   return edgePoints
end dotArray_GetOriginalEdgePoints

private function _RectFromFoundArray rArray
   put rArray [1] into cx
   put rArray [2] into cy
   put rArray [3] into rx
   put rArray [4] into ry
   --
   put dotArray_ConvertCrxy (cx, cy, rx, ry) into newRect
   return newRect
end _RectFromFoundArray


--> Dot | Geometry
-
command dot_ConvertFromInches @inchSizes, pScreenRez
   if pScreenRez is empty then put 96 into pScreenRez
   --
   set the numberformat to "0.0000"
   repeat with itemNum = 1 to the number of items of inchSizes
      put item itemNum of inchSizes into someNumber
      put someNumber * pScreenRez  into item itemNum of inchSizes
   end repeat
end dot_ConvertFromInches

command dot_ConvertToInches @pixelSize, pScreenRez
   if pScreenRez is empty then put 96 into pScreenRez
   set the numberformat to "0.0000"
   repeat with itemNum = 1 to the number of items of pixelSize
      put item itemNum of pixelSize into someNumber
      put someNumber / pScreenRez  into item itemNum of pixelSize
   end repeat
end dot_ConvertToInches

command dot_ConvertToPngPixels @xdotValue
   put dot_PointsToPixels (xdotValue) into xdotValue
end dot_ConvertToPngPixels

command dot_ResizeImage someView, pDotGraphSize
   put the dot_Text of someView into dotText
   if pDotGraphSize is empty then
      put the dot_InchSize [false] of someView into pDotGraphSize
   end if
   --
   put dot_GetResizedHeader (dotText, pDotGraphSize) into newHeader
   
   dot_SetHeader dotText, newHeader
   set the dot_Text of someView to dotText
   return oldHeaderArray
end dot_ResizeImage

function dot_GetResizedHeader dotText, dotGraphSize
   -- put "0,0,3000,3000" into headerArray ["bb"]
   -- put the dot_BboxSize of someView into headerArray ["bb"]
   -- delete local headerArray ["size"]
   -- put the dot_BboxSize [false] of someView into headerArray ["bb"]
   
   switch dotGraphSize
      case "none"
         put empty into newHeader
         break
      case "full"
         put empty into newHeader
         break
      default
         -- put the dot_InchSize [false] of someView into inchItems
         put dotGraphSize into inchItems
   end switch
   
   put dot_GetGraphHeader (dotText) into oldHeader
   if oldHeader is empty then
      put empty into oldHeaderArray
      if inchItems is not empty then put "size =" && kwote(inchItems) into graphSize
      dotHeader_ConstructArray dotPropertyArray
      put dot_ConstructHeader (graphSize, dotPropertyArray) into newHeader
   else
      put _ArrayFromHeader (oldHeader) into headerArray
      delete local headerArray ["bb"]
      delete local headerArray ["size"]
      if inchItems is not empty then put inchItems into headerArray ["size"]
      put dot_HeaderFromArrays (headerArray) into newHeader
   end if
   return newHeader
end dot_GetResizedHeader


--> Props
-
getprop dot_BboxSize
   put the rect of the target into someRect
   put dot_BboxSize (someRect) into targetSize
   return targetSize
end dot_BboxSize

getprop dot_InchSize [expandIfNeeded]
   put the rect of the target into someRect
   put dot_GraphInchSize (someRect, expandIfNeeded) into targetSize
   return targetSize
end dot_InchSize

getprop dot_TargetSizeLine
   put the rect of the target into graphRect
   put dot_ConvertGraphRect (graphRect, false, false) into targetSize
   return targetSize
end dot_TargetSizeLine


--> Dot | Size | Model
-
function dot_GetGraphSize dotText
   put dot_GetGraphHeader (dotText) into dotHeader
   put _ArrayFromHeader (oldHeader) into headerArray
   --
   put headerArray ["bb"] into bbSize
   if bbSize is not empty then return bbSize
   --
   put headerArray ["size"] into graphSize
   return graphSize
end dot_GetGraphSize

command dot_SetGraphSize @dotText, inchItems
   local newHeader
   
   put dot_GetGraphHeader (dotText) into oldHeader
   if oldHeader is empty then
      put empty into oldHeaderArray
      if inchItems is not empty then put "size =" && kwote(inchItems) into graphSize
      dotHeader_ConstructArray dotPropertyArray
      put dot_ConstructHeader (graphSize, dotPropertyArray) into newHeader
   else
      put _ArrayFromHeader (oldHeader) into headerArray
      delete local headerArray ["bb"]
      delete local headerArray ["size"]
      if inchItems is not empty then put inchItems into headerArray ["size"]
      put dot_HeaderFromArrays (headerArray) into newHeader
   end if
   
   dot_SetHeader dotText, newHeader
   return newHeader
end dot_SetGraphSize


--> Dot | Resize
-
function dot_RectFromSize graphSize
   switch graphSize
      case empty
         return empty
      case "full"
         put "0,0,3000,3000" into someRect
         return someRect
      case "screen"
         put dot_BboxSize (the screenrect) into someRect
         return someRect
      case "image"
         put default_FirstStackControl ("View|Image|OPN Image") into imageView
         put the rect of imageView into graphRect
         put dot_BboxSize (graphRect) into someRect
         return someRect
      default -- "none"
         if graphSize is a rect then
            put dot_BboxSize (graphSize) into someRect
            return someRect
         else
            return empty
         end if
   end switch 
end dot_RectFromSize

command dot_StripGraphSize @dotText
   put dot_GetGraphHeader (dotText) into dotHeader
   put _ArrayFromHeader (dotHeader) into headerArray
   delete local headerArray ["bb"]
   delete local headerArray ["size"]
   put dot_HeaderFromArrays (headerArray) into newHeader
   dot_SetHeader dotText, newHeader
   return dotText
end dot_StripGraphSize

command dot_ExtractGraphSize dotText, @graphWidth, @graphHeight
   -- was "xdot_ExtractGraphSize"
   repeat 5
      put dot_GetGraphHeader (dotText) into dotHeader
      if dotHeader is empty then exit repeat
      get _ArrayFromHeader (dotHeader)
      if keys(headerArray) is empty then
         put it into headerArray
      else
         union it with headerArray
         put it into headerArray
      end if
      dot_SetHeader dotText
   end repeat
   
   put headerArray ["bb"] into bb
   if bb is empty then
      put headerArray ["size"] into inchItems
      put round (96 * item 1 of inchItems) into graphWidth
      put round(96 * item 2 of inchItems) into graphHeight
   else
      put item 3 of bb into graphWidth
      put item 4 of bb into graphHeight
   end if
end dot_ExtractGraphSize


--> Dot | Geometry | Size
-
function dot_BboxSize someRect
   put item 3 of someRect - item 1 of someRect into someWidth
   put item 4 of someRect - item 2 of someRect into someHeight
   put 0,0,someWidth,someHeight into someRect
   return someRect
end dot_BboxSize

function dot_GraphInchSize someRect, expandIfNeeded
   if someRect is empty then return empty
   put item 3 of someRect - item 1 of someRect into someWidth
   put item 4 of someRect - item 2 of someRect into someHeight
   
   put someWidth,someHeight into someSize
   dot_ConvertToInches someSize
   if expandIfNeeded is true then
      put "!" after someSize
   end if
   return someSize
end dot_GraphInchSize


--> Dot | Size | Convert
-
function dot_ConvertGraphRect someRect, expandIfNeeded, useBbox
   if useBbox is false then
      put dot_GraphInchSize (someRect, expandIfNeeded) into someRect
   else
      put dot_BboxSize (someRect) into someRect
   end if
   return someRect
end dot_ConvertGraphRect

function dot_ConvertDrawRect drawPoints, gHeight, @pointNum, @revRect
   -- was "graphViz_ConvertDrawRect"
   local revPoints
   if word 1 of drawPoints is "P" then
      put word 2 of drawPoints into pointNum
      put word 3 to -1 of drawPoints into drawPoints
      repeat pointNum
         put word 1 of drawPoints into nodeX
         put word 2 of drawPoints into nodeY
         
         put gHeight - nodeY into reflectedY
         
         dot_ConvertToPngPixels nodeX
         add 7 to nodeX
         dot_ConvertToPngPixels reflectedY
         add 7 to reflectedY
         put nodeX,reflectedY into reflectedLoc
         
         put reflectedLoc & CR after revPoints
         delete word 1 to 2 of drawPoints
      end repeat
   end if
   -- delete last char of revPoints
   put line 1 of revPoints after revPoints
   
   if pointNum = 4 then
      put line 2 of revPoints & "," & line 4 of revPoints into revRect
   else
      put empty into revRect
   end if
   return revPoints
end dot_ConvertDrawRect

function dot_ReflectPoint someLoc, gHeight
   -- was "graphViz_ReflectPoint"
   put item 1 of someLoc into nodeX
   put item 2 of someLoc into nodeY
   
   put gHeight - nodeY into reflectedY
   put nodeX,reflectedY into reflectedLoc
   return reflectedLoc
end dot_ReflectPoint


--> Private
-
private function _ArrayFromHeader dotHeader
   -- was "dot_HeaderToArray"
   put text_GetBetween ("[", "]", dotHeader) into innerBit
   repeat for each line someLine in innerBit
      put word 1 to -1 of someLine into someLine
      if someLine is empty then next repeat
      repeat 50
         set the itemdelimiter to "="
         put word 1 to -1 of item 1 of someLine into someKey
         delete item 1 of someLine
         
         put word 1 of someLine into someValue
         if char -1 of someValue is comma then delete char -1 of someValue
         replace quote with empty in someValue
         delete word 1 of someLine
         
         put someValue into headerArray [someKey]
         
         if word 1 of someLine is comma then delete word 1 of someLine
         put word 1 to -1 of someLine into someLine
         if someLine is empty then exit repeat
      end repeat
   end repeat
   return headerArray
end _ArrayFromHeader
