script "lib_DotArray"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DotArray
type: library
version: 0.1

/*
DotArray is an array in the form returned as json by graphviz.
It is rich complicated and we use it as the canonical standard.
However we need simpler stuff to work with - such as linkArrays.

command _CreateGraphic nArray, dotGroup
   -- lib_DotCreate
   put nArray ["name"] into oName
   put nArray ["label"] into oLabel
   put nArray ["shape"] into nShape
   put nArray ["style"] is "filled" into isOpaque
   --
   reset templateGraphic
   set the opaque of the templateGraphic to true
   set the showName of the templateGraphic to true
   --
   create graphic oName in dotGroup -- card cardNum of stack stackName
   put it into nodeObject
   --
   switch oLabel
      case "\N"
         break -- don't set (same as name)
      default
         set the label of nodeObject to oLabel
   end switch
   --
   switch
      case nArray ["nodes"] is an array
         -- creeate a group
         break
      case nShape = "box"
         -- set the style of nodeObject to "rectangle"
         -- set the rect of nodeObject to oRect
         put dotArray_GetDrawPoints (nArray, 3) into gPoints
         set the style of nodeObject to "polygon"
         set the points of nodeObject to gPoints
         break
      case nShape = "triangle"
         -- set the style of nodeObject to "regular"
         -- set the polysides of nodeObject to 3
         set the style of nodeObject to "polygon"
         put dotArray_GetDrawPoints (nArray, 3) into gPoints
         set the points of nodeObject to gPoints
         break
      case nShape = "diamond"
         -- set the style of nodeObject to "regular"
         -- set the polysides of nodeObject to 4
         --
         set the style of nodeObject to "polygon"
         put dotArray_GetDrawPoints (nArray, 3) into gPoints
         set the points of nodeObject to gPoints
         break
      case nShape = "pentagon"
         set the style of nodeObject to "regular"
         set the polysides of nodeObject to 5
         break
      case nShape = "ellipse"
      case nShape = "circle"
      default
         set the style of nodeObject to "oval"
         --
         put dotArray_GetDrawRect (nArray, 2) into oRect
         set the rect of nodeObject to oRect
   end switch
   --
   set the node_Array of nodeObject to nArray
   return nodeObject
end _CreateGraphic
*/


--> Working on
-
private command _DeleteDotGraphics tGroup
   put the node_Ids of tGroup into nodeIds
   --
   put the number of graphics of tGroup into gNums
   repeat with gNum = gNums down to 1
      delete graphic gNum of tGroup
   end repeat
end _DeleteDotGraphics

private command _DeleteDotNodes tGroup
   put the node_Ids of tGroup into nodeIds
   repeat for each line nodeID in nodeIds
      delete control id nodeID of tGroup
   end repeat
end _DeleteDotNodes

function dotArray_FindPointArray edgeArray   
   put edgeArray ["_draw_"] into drawData
   put item 2 of the extents of drawData into maxItem
   repeat with itemNum = maxItem down to 1
      put drawData [itemNum]["points"] into pArray
      if pArray is an array then
         return pArray
      end if
   end repeat
   return empty
end dotArray_FindPointArray

function dotArray_FindEdgePoints edgeArray   
   put edgeArray ["_draw_"] into drawData
   put item 2 of the extents of drawData into maxItem
   repeat with itemNum = maxItem down to 1
      put drawData [itemNum]["points"] into pArray
      if pArray is an array then
         put _GetDrawPoints (pArray) into fPoints
         return fPoints
      end if
   end repeat
   return empty
end dotArray_FindEdgePoints

private function _GetDrawPoints pArray
   repeat with pointLineNum = 1 to item 2 of the extents of pArray
      put pArray [pointLineNum][1] into sX
      put pArray [pointLineNum][2] into sY
      put sX,sY & CR after sPoints
   end repeat
   delete char -1 of sPoints
   return sPoints
end _GetDrawPoints


--> Node
-
function dot_NodeShapes
   return the hkey_CaseConditions ["F node_ConstructPropertyArray"] of me
end dot_NodeShapes

function node_ConstructPropertyArray nShape, pNodeArray
   switch nShape
      case "rectangle"
      case "box"
         put "rectangle" into pArray ["style"]
         if pNodeArray is an array then
            put dotArray_RectFromArray (pNodeArray) into nodeRect
            put nodeRect into pArray ["rectangle"]
         end if
         break
      case "-"
      case "triangle"
      case "invtriangle"
         put "polygon" into pArray ["style"]
         if pNodeArray is an array then
            put dotArray_GetDrawPoints (pNodeArray, 3) into nodePoints
            put nodePoints into pArray ["points"]
         end if
         break
      case "diamond"
         put "polygon" into pArray ["style"]
         if pNodeArray is an array then
            put dotArray_GetDrawPoints (pNodeArray, 3) into nodePoints
            put nodePoints into pArray ["points"]
         end if
         break
      case "pentagon"
         put "regular" into pArray ["style"]
         put 5 into pArray ["polysides"]
         break
      case "hexagon"
         put "regular" into pArray ["style"]
         put 6 into pArray ["polysides"]
         break
      case "invtrapezium"
         break
      case "circle"
      case "-"
      case "ellipse"
         put "oval" into pArray ["style"]
   end switch
   return pArray
end node_ConstructPropertyArray

private function _CreateProps nShape, nArray
   switch
      case nShape = "rectangle"
      case nShape = "box"
         put "rectangle" into pArray ["style"]
         put dotArray_RectFromArray (nArray) into pArray ["rectangle"]
         break
      case "invtriangle"
      case nShape = "triangle"
         put "polygon" into pArray ["style"]
         
         put dotArray_GetDrawPoints (nArray, 3) into gPoints
         put gPoints into pArray ["graphic_Points"]
         break
      case nShape = "diamond"
         put "polygon" into pArray ["style"]
         
         put dotArray_GetDrawPoints (nArray, 3) into gPoints
         put gPoints into pArray ["graphic_Points"]
         break
      case nShape = "pentagon"
         put "regular" into pArray ["style"]
         put 5 into pArray ["polysides"]
         break
      case nShape = "hexagon"
         put "regular" into pArray ["style"]
         put 6 into pArray ["polysides"]
         break
      case nShape = "invtrapezium"
         break
      case nShape = "ellipse"
      case nShape = "circle"
      default
         put "oval" into pArray ["style"]
         --
         put dotArray_FindDrawRect (nArray) into gRect
         put gRect into pArray ["graphic_Rect"]
   end switch
   return pArray
end _CreateProps

function dot_ConvertRevShape revShape, pSides
   -- was "graphViz_ConvertRevShape"
   if revShape is empty then
      return "ellipse"
   else if revShape is "regular" then
      switch pSides
         case 3
            return "triangle"
         case 4
            return "rectangle"
         case 5
            return "pentagon"
         case 6
            return "hexagon"
      end switch
   else if revShape is "oval" then
      return "ellipse"
   else
      return revShape
   end if
end dot_ConvertRevShape

command dotArray_CreateGraphic nArray, dotGroup
   put nArray ["name"] into oName
   put nArray ["label"] into oLabel
   put nArray ["shape"] into nShape
   put nArray ["style"] is "filled" into isOpaque
   --
   reset templateGraphic
   set the opaque of the templateGraphic to true
   set the showName of the templateGraphic to true
   --
   create graphic oName in dotGroup
   put it into nodeObject
   --
   switch oLabel
      case "\N"
         break -- don't set (same as name)
      default
         set the label of nodeObject to oLabel
   end switch
   
   if nArray ["nodes"] is an array then
      break -- creeate a group
   end if
   
   --
   put _CreateProps (nShape, nArray) into pArray
   -- put node_ConstructPropertyArray (nShape, nArray) into pArray
   set the node_Properties of nodeObject to pArray
   --
   set the node_Array of nodeObject to nArray
   return nodeObject
end dotArray_CreateGraphic

setprop node_Properties pArray
   local customArray
   put the node_Object of the target into nodeObject
   if exists (nodeObject) is false then return empty
   --
   repeat for each key propName in pArray
      if propName contains "_" then
         put pArray [propName] into customArray [propName]
         delete variable pArray [propName]
      end if
   end repeat
   
   lock screen
   set the properties of nodeObject to pArray
   repeat for each key cProp in customArray
      put customArray [cProp] into cValue
      set the cProp of nodeObject to cValue
   end repeat
   unlock screen
   return nodeObject
end node_Properties


--> Display
-
on mDouble_DotArray displayView, someLine
   breakpoint
   put the title_Text of displayView into someTitle
end mDouble_DotArray

command display_GraphFromDotArray dotArray, pDotText
   put dotArray ["name"] && "Graph" into graphName
   display_Clone "View|Dot|Graph", graphName, dotArray, "dot_Array"
   put the result into graphView
   --
   set the lockmessages to true
   set the dot_Text of graphView to pDotText
   set the lockmessages to false
   --
   return graphView
end display_GraphFromDotArray


--> Dot |Create | Array
-
getprop dot_Array
   set the lockmessages to true
   put the dot_Array of the target into dotArray
   set the lockmessages to false
   return dotArray
end dot_Array

setprop dot_Array [edgeWidth] dotArray
   put the long id of the target into tGroup
   
   lock screen
   put the loc of tGroup into oLoc
   --
   -- _DeleteDotGraphics tGroup
   _DeleteDotNodes tGroup
   --
   if dotArray is an array then -- for safety?
      put _GetBackgroudRect (dotArray) into bbRect
      set the bb_Rect of tGroup to bbRect
      --
      set the lockloc of tGroup to true
      _CreateEdges dotArray, tGroup, edgeWidth
      _CreateObjects dotArray, tGroup
      --
      set the lockmessages to true
      set the dot_Array of tGroup to dotArray
      set the lockmessages to false
   end if
   --
   set the loc of tGroup to oLoc
   unlock screen
   return bbRect
end dot_Array

private function _GetBackgroudRect dotArray
   put dotArray ["bb"] into bb
   put trunc (item 3 of bb) into sWidth
   put trunc (item 4 of bb) into sHeight
   -- put rect_FromWidthAndHeight (cRect, sWidth, sHeight) into bbRect
   put 0,0,sWidth,sHeight into bbRect
   --
   return bbRect
end _GetBackgroudRect

private command _CreateObjects dotArray, dotGroup
   set the showName of templateGraphic to true
   --
   put dotArray ["objects"] into objectsArray
   repeat with itemNum = 1 to item 2 of the extents of objectsArray
      put objectsArray [itemNum] into nArray
      put nArray ["name"] into oName
      --
      put nArray ["nodes"] into nodeArray
      switch
         case nodeArray is an array
            break
         default
            dotArray_CreateGraphic nArray, dotGroup
      end switch
      --
   end repeat
end _CreateObjects

private command _CreateEdges dotArray, dotGroup, pEdgeWidth
   set the showName of templateGraphic to true
   --
   put dotArray ["edges"] into edgesArray
   repeat with itemNum = 1 to item 2 of the extents of edgesArray
      put edgesArray [itemNum] into edgeArray
      _CreateEdge edgeArray, dotGroup, pEdgeWidth
   end repeat
end _CreateEdges

private command _CreateEdge edgeArray, dotGroup, pEdgeWidth
   if pEdgeWidth is not a number then
      put 4 into pEdgeWidth
   end if
   --
   put the edge_OriginalPoints [edgeArray] of dotGroup into edgePoints
   put dotArray_ConstructEdgeName (edgeArray) into edgeName
   --
   reset templateGraphic
   set the style of the templateGraphic to curve
   set the lineSize of the templateGraphic to pEdgeWidth
   set the endArrow of the templateGraphic to true
   set the showName of the templateGraphic to false
   --
   lock screen
   create graphic edgeName in dotGroup
   put it into edgeObject
   -- set the graphic_Points of edgeObject to edgePoints
   set the points of edgeObject to edgePoints
   set the uGraphic ["edge_Array"] of edgeObject to edgeArray
   unlock screen
   --
   reset templateGraphic
   return edgeObject
end _CreateEdge

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

private function _RectFromFoundArray rArray
   put rArray [1] into cx
   put rArray [2] into cy
   put rArray [3] into rx
   put rArray [4] into ry
   --
   put dotArray_ConvertCrxy (cx, cy, rx, ry) into newRect
   return newRect
end _RectFromFoundArray

function dotArray_ConstructEdgeName edgeArray
   put "Edge" && edgeArray ["_gvid"] into edgeName
   return edgeName
end dotArray_ConstructEdgeName

function dotArray_ConvertCrxy cx, cy, rx, ry
   put cx,cy into someLoc
   put 2*rx into newW
   put 2*ry into newH
   --
   put rect_LocWidthHeight (someLoc, newW, newH) into newRect
   return newRect
end dotArray_ConvertCrxy


--> DotArray
-
function dotArray_FromLinkArray linkArray, pGraphStyle, pGraphName, pFile
   if pDefaultShape is empty then put "rectangle" into pDefaultShape
   --
   dotArray_Construct linkArray, dotArray, pGraphStyle, pGraphName, pFile, pDefaultShape
   put the result into dotText
   return dotArray
end dotArray_FromLinkArray

command dotArray_Construct linkArray, @dotArray, pGraphStyle, pGraphName, pDefaultShape, pFile, pBgColour, pConcentrate, pDefSection 
   if pGraphName is empty then put "Link Array" into pGraphName
   --
   put dot_FromLinkArray (linkArray, pGraphStyle, pBgColour, pConcentrate, pDefaultShape, pDefSection, pGraphName) into dotText
   put dot_CreateArray (dotText, pFile) into dotArray
   --
   return dotText
end dotArray_Construct


--> Dot
-
function dot_CreateArray dotText, pFile
   put dot_CreateText (dotText, "json", pFile) into dotJSON
   --
   if word 1 of dotJSON = "Warning:" then
      delete line 1 of dotJSON
   end if
   --
   put json_ToArray (dotJSON) into dotArray
   return dotArray
end dot_CreateArray

function dot_CreateText dotText, pExportFormat, pFile
   file_CreateText dotText, pFile
   put the result into dotFile
   put dot_DoShell (dotFile, "dot", pExportFormat) into dotExport
   return dotExport
end dot_CreateText

function dot_DoShell dotFile, pDotCommand, pExportFormat
   dot_NormalizeDotCommand pDotCommand
   if pExportFormat is empty then put "svg" into pExportFormat
   put graphViz_GetShellPath() into gvPath
   --
   put gvPath & pDotCommand into someShell
   put space & "-T" & pExportFormat after someShell
   put space & quote & dotFile & quote after someShell
   --
   put shell(someShell) into gvResult
   --
   put dot_CheckResult (gvResult, pExportFormat, someShell) into shellResult
   return shellResult
end dot_DoShell


--> Deps
-
function loc_ScaleFromCentre someLoc, someScale, pScaleCentre
   if pScaleCentre is empty then
      put item 1 of someLoc * someScale into item 1 of newLoc
      put item 2 of someLoc * someScale into item 2 of newLoc
   else
      put item 1 of pScaleCentre into xVector
      put item 2 of pScaleCentre into yVector
      --
      put loc_TranslateByVector (someLoc, -xVector, -yVector) into tLoc
      --
      put item 1 of tLoc * someScale into item 1 of scaledLoc
      put item 2 of tLoc * someScale into item 2 of scaledLoc
      --
      put loc_TranslateByVector (scaledLoc, xVector, yVector) into newLoc
   end if
   return newLoc
end loc_ScaleFromCentre
