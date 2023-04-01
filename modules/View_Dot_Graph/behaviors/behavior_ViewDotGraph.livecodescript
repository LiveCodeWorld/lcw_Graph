script "behavior_ViewDotGraph"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewDotGraph
type: behavior
version: 0.1

/*
Here you make make notes as a basic form of help for this view.
Full help text can be found on the linked wiki for the view.

function dotArray_GetEdgePoints edgeArray, bbRect, bbCentre, pTopDown, pScaleFactor
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
      if pScaleFactor is a number AND pScaleFactor is not 1 then
         put loc_ScaleFromCentre (sPoint, pScaleFactor, bbCentre) into sPoint
      end if
      --
      put sPoint & CR after edgePoints
   end repeat
   delete char -1 of edgePoints
   return edgePoints
end dotArray_GetEdgePoints

private command _OldScaleNodes dotArray, pTopDown, sFactor, bbCentre
   -- scales from centre and moves group hack
   put dotArray ["objects"] into objectArray
   repeat with nodeNum = 1 to item 2 of the extents of objectArray
      put objectArray [nodeNum] into nodeArray
      put nodeArray ["name"] into nodeName
      --
      if exists (graphic nodeName of me) is false then next repeat
      put the long id of graphic nodeName of me into nodeObject
      --
      put graph_ScaledNodeRect (nodeArray, pTopDown, sFactor, bbCentre) into nodeRect      
      set the rect of nodeObject to nodeRect
   end repeat
end _OldScaleNodes
*/

--> Variables
-
local LocalArray


--> Edge | Props
-
getprop edge_ScaledPoints [pTargetFrameRect]
   if pTargetFrameRect is empty then
      put the rect of me into pTargetFrameRect
   end if
   --
   put the long id of the target into edgeObject
   put the edge_Array of edgeObject into edgeArray
   --
   put true into scaleProportionally
   put the top_Down of me into topDown
   put the bb_Rect of me into bbRect
   --
   put dotArray_TransformPoints (edgeArray, bbRect, pTargetFrameRect, topDown, scaleProportionally) into scaledEdgePoints
   return scaledEdgePoints
end edge_ScaledPoints

getprop edge_OriginalPoints [pEdgeArray]
   if pEdgeArray is empty then
      put the long id of the target into edgeObject
      put the edge_Array of edgeObject into pEdgeArray
   end if
   put the long id of me into dotGroup
   --
   put the top_Down of dotGroup into topDown
   put the bb_Rect of dotGroup into bbRect
   --
   put dotArray_GetOriginalEdgePoints (pEdgeArray, bbRect, topDown) into edgePoints
   return edgePoints
end edge_OriginalPoints

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

getprop edge_Array
   put the long id of the target into edgeObject
   if word 1 of edgeObject is not "graphic" then return empty
   if the style of edgeObject is not "curve" then return empty
   --
   put the uGraphic ["edge_Array"] of edgeObject into edgeArray
   return edgeArray
end edge_Array


--> Events | Custom
-
command LayoutControl pRect
   lock screen
   _SetFrameRect pRect
   -- 
   put the inner_Rect [pRect] of me into innerRect
   put the dot_Array of me into dotArray
   put the top_Down of me into topDown
   put _GetBackgroudRect (dotArray) into bbRect
   
   /*
   if the auto_Scale of me is not false then
   else
      put rect_GetCentre (pRect) into newLoc
      set the loc of me to newLoc
   end if
   */
   
   _ScaleNodes dotArray, innerRect, topDown, true
   _ScaleEdges dotArray, bbRect, topDown, innerRect
   --
   set the rect of _BrowserControl() to innerRect
   unlock screen
end LayoutControl

private command _SetFrameRect @pRect
   set lockmessages to true
   if pRect is empty then
      put the rect of me into pRect
   else if the lockloc  of me is true then
      set the rect of me to pRect
   end if
   set lockmessages to false
end _SetFrameRect


--> Working on | Edges
-
private command _ScaleEdges dotArray, bbRect, topDown, targetFrameRect
   put true into scaleProportionally
   
   put dotArray ["edges"] into edgesArray
   repeat with itemNum = 1 to item 2 of the extents of edgesArray
      put edgesArray [itemNum] into edgeArray
      put dotArray_ConstructEdgeName (edgeArray) into edgeName
      if exists (graphic edgeName of me) is false then next repeat
      put the long id of graphic edgeName of me into edgeObject
      --
      put dotArray_TransformPoints (edgeArray, bbRect, targetFrameRect, topDown, scaleProportionally) into scaledEdgePoints
      --
      set the points of edgeObject to scaledEdgePoints
   end repeat   
end _ScaleEdges

function dotArray_TransformPoints edgeArray, bbRect, targetFrameRect, pTopDown, pScaleProportionally
   # Get scaleX, scaleY
   rect_SetScaleVectors bbRect, targetFrameRect, scaleX, scaleY, pScaleProportionally
   put item 1 of targetFrameRect - item 1 of bbRect into xVector
   put item 2 of targetFrameRect - item 2 of bbRect into yVector
   put item 4 of bbRect - item 2 of bbRect into bbHeight -- = item 4 of bbRect
   --
   put dotArray_FindPointArray (edgeArray) into pArray
   repeat with itemNum = 1 to item 2 of the extents of pArray
      put pArray [itemNum][1] into sX
      put pArray [itemNum][2] into sY
      
      # Flip
      if pTopDown is true then
         put bbHeight - sY into sY -- flip vertical
      end if
      
      # Scale
      put sX * scaleX into scaledX
      put sY * scaleY into scaledY
      
      # Translate to target locs
      add xVector to scaledX
      add yVector to scaledY
      
      put scaledX,scaledY & CR after edgePoints
   end repeat
   delete char -1 of edgePoints
   return edgePoints
end dotArray_TransformPoints


--> Working on
-
function loc_Transform someLoc, someScale, pScaleCentre
   breakpoint
   # Get scaleX, scaleY
   rect_SetScaleVectors oFrameRect, targetFrameRect, scaleX, scaleY, pScaleProportionally
   
   # Translate to origin
   put item 1 of pScaleCentre into xVector
   put item 2 of pScaleCentre into yVector
   put loc_TranslateByVector (someLoc, -xVector, -yVector) into oLoc
   
   # Scale
   put item 1 of oLoc * scaleX into item 1 of scaledLoc
   put item 2 of oLoc * scaleY into item 2 of scaledLoc
   
   # Translate to target locs
   put loc_TranslateByVector (scaledLoc, xVector, yVector) into newLoc
   return newLoc
end loc_Transform

function rect_Transform oRect, oFrameRect, targetFrameRect, pScaleProportionally
   
end rect_Transform

function transform_RectFromOrigin rectArray, tObject, targetFrameRect, pScaleProportionally
   -- Transformed means "scaled and translated"
   -- We assume "target" "rect" is a card so has 0,0 topleft
   
   # No need to Translate
   put rectArray ["target"]["rect"] into oCardRect
   put rectArray_FindObjectArray (rectArray, tObject) into objectArray
   put objectArray ["rect"] into oRect -- original object rect
   
   put rect_TransformFromOrigin (oRect, oCardRect, targetFrameRect, pScaleProportionally) into transformedRect
   rect_Normalise transformedRect -- for animationEngine
   return transformedRect
end transform_RectFromOrigin

setprop graphic_Rect gRect
   if the long id of the target = the long id of me then return false
   --
   put the top_Down of me into topDown
   _ConvertRect gRect, topDown
   if gRect is a rect then
      set the rect of the target to gRect
   end if
end graphic_Rect

setprop graphic_Points gPoints
   if the long id of the target = the long id of me then return false
   --
   _ConvertPoints gPoints
   set the points of the target to gPoints
end graphic_Points

setprop graph_Scale [graphLoc] sFactor
   breakpoint
   put the dot_Array of me into dotArray
   put the top_Down of me into pTopDown
   put _GetBackgroudRect (dotArray) into bbRect
   put the rect of me into targetFrameRect
   
   lock screen
   --
   _ScaleNodes dotArray
   _ScaleEdges dotArray, bbRect, topDown, targetFrameRect
   --
   unlock screen
end graph_Scale


--> Node
-
private command _ScaleNodes dotArray, pTargetRect, pTopDown, pScaleProportionally
   if pTargetRect is empty then put the rect of me into pTargetRect
   if pTopDown is empty then put true into pTopDown
   if pScaleProportionally is empty then put true into pScaleProportionally
   --
   put _GetBackgroudRect (dotArray) into bbRect
   put dotArray ["objects"] into objectArray
   repeat with nodeNum = 1 to item 2 of the extents of objectArray
      put objectArray [nodeNum] into nodeArray
      put nodeArray ["name"] into nodeName
      if exists (graphic nodeName of me) is false then next repeat
      put the long id of graphic nodeName of me into nodeObject
      --
      -- put _GetNodeRect (nodeArray, dotArray, pTargetRect, pTopDown, pScaleProportionally) into scaledNodeRect
      put graph_OriginalNodeRect (nodeArray, pTopDown) into oNodeRect -- at origin
      put rect_TransformFromOrigin (oNodeRect, bbRect, pTargetRect, pScaleProportionally) into scaledNodeRect
      set the rect of nodeObject to scaledNodeRect
   end repeat
end _ScaleNodes

function rect_TransformFromOrigin oRect, oFrameRect, targetFrameRect, pScaleProportionally
   # Get translation vectors
   -- using topleft positions scaled graph in topleft of targetFrameRect
   put item 1 to 2 of oFrameRect into fromPoint -- will be 0,0 for now
   put item 1 to 2 of targetFrameRect into toPoint
   
   /*
   put rect_GetCentre (oFrameRect) into fromPoint
   put rect_GetCentre (targetFrameRect) into toPoint
   */
   loc_SetTranslationVector fromPoint, toPoint, xVector, yVector
   
   # Get scaleX, scaleY
   rect_SetScaleVectors oFrameRect, targetFrameRect, scaleX, scaleY, pScaleProportionally
   
   # Scale before translating
   put rect_ScaleByVectors (oRect, scaleX, scaleY) into transformedRect   
   
   # Translate
   rect_Translate transformedRect, xVector, yVector
   --
   return transformedRect
end rect_TransformFromOrigin

private function _GetNodeRect nodeArray, dotArray, targetRect, pTopDown, pScaleProportionally
   put graph_OriginalNodeRect (nodeArray, pTopDown) into oNodeRect
   put _GetBackgroudRect (dotArray) into bbRect
   put rect_TransformFromOrigin (oNodeRect, bbRect, targetRect, pScaleProportionally) into scaledNodeRect
   return scaledNodeRect
end _GetNodeRect

function graph_OriginalNodeRect nodeArray, pTopDown
   -- original rect in points of a graphviz node with origin at 0,0
   put nodeArray ["shape"] into oShape
   switch
      case "rectangle"
         put dotArray_GetRectangleRect (nodeArray) into gRect
         break
      case oShape = "box"
         put dotArray_RectFromArray (nodeArray) into gRect
         break
      case oShape = "ellipse"
      case oShape = "circle"
      default
         put dotArray_FindDrawRect (nodeArray) into gRect
   end switch
   --
   _ConvertRect gRect, pTopDown
   return gRect
end graph_OriginalNodeRect

function graph_ScaledNodeRect nodeArray, pTopDown, pScaleFactor, pBBCentre
   -- original rect in points of a graphviz node 
   -- then scaled by pScaleFactor around the orginal graphs centre pBBCentre
   put graph_OriginalNodeRect (nodeArray, pTopDown) into nodeRect
   if pScaleFactor is not 1 then
      put rect_ScaleFromCentre (nodeRect, pScaleFactor, pBBCentre) into nodeRect
   end if
   return nodeRect
end graph_ScaledNodeRect

getprop node_ScaledRect [pTargetRect]
   if pTargetRect is empty then
      put the rect of me into pTargetRect
   end if
   --
   put the node_Array of the target into nodeArray
   put the dot_Array of me into dotArray
   put the top_Down of me into topDown
   --
   put _GetNodeRect (nodeArray, dotArray, pTargetRect, topDown, true) into nodeRect
   rect_Normalise nodeRect
   return nodeRect
end node_ScaledRect

getprop node_OriginalRect
   put the node_Array of the target into nodeArray
   put the top_Down of me into pTopDown
   put graph_OriginalNodeRect (nodeArray, pTopDown) into nodeRect
   rect_Normalise nodeRect
   return nodeRect
end node_OriginalRect

function dotArray_GetDrawRect nodeArray, itemNum
   get nodeArray ["_draw_"]
   put it [itemNum]["rect"] into rArray
   --
   put rArray [1] into cx
   put rArray [2] into cy
   put rArray [3] into rx
   put rArray [4] into ry
   --
   put dotArray_ConvertCrxy (cx, cy, rx, ry) into newRect
   return newRect
end dotArray_GetDrawRect

private function _GetBackgroudRect dotArray
   put dotArray ["bb"] into bb
   put trunc (item 3 of bb) into sWidth
   put trunc (item 4 of bb) into sHeight
   -- put rect_FromWidthAndHeight (cRect, sWidth, sHeight) into bbRect
   put 0,0,sWidth,sHeight into bbRect
   --
   return bbRect
end _GetBackgroudRect


--> Node | Model
-
function node_FindArray
   put the object_Array of the target into objectArray
   put the dot_Array of me into dotArray
   put the node_Number of me into sdfg
   
end node_FindArray

getprop node_Shape
   put the node_Array of the target into nodeArray
   return nodeArray ["shape"]
end node_Shape

setprop node_Shape nShape
   put the node_Object of the target into nodeObject
   if exists (nodeObject) is false then return nodeObject
   --
   put the node_Array of nodeObject into nodeArray
   put node_ConstructPropertyArray (nShape, nodeArray) into pArray
   set the properties of nodeObject to pArray
   --
   put nShape into nodeArray ["shape"]
   set the node_Array of nodeObject to nodeArray
   return nodeObject
end node_Shape

getprop node_Array   
   put the node_Object of the target into nodeObject
   if exists (nodeObject) is false then return nodeObject
   --
   put the uGraph ["node_Array"] of nodeObject into nodeArray
   return nodeArray
end node_Array

setprop node_Array nodeArray
   put the node_Object of the target into nodeObject
   if exists (nodeObject) is false then return nodeObject
   --
   set the uGraph ["node_Array"] of nodeObject to nodeArray
   return nodeObject
end node_Array

getprop node_Object
   put the long id of the target into nodeObject
   if nodeObject = the long id of me then
      return empty
   else
      return nodeObject
   end if
end node_Object

getprop node_Number
   
end node_Number


--> Array | Model
-
getprop descendent_LevelArray
   put the descendent_Array of the target into dArray
   put _ConstructDescendentLevelArray (dArray) into dLevelArray
   return dLevelArray
end descendent_LevelArray

getprop descendent_Array
   if the long id of the target = the long id of me then
      return empty -- not sure what to do?
   else
      put the short name of the target into nodeName
      put the link_Array of me into linkArray
      --
      put linkArray_GetDescendentArray (nodeName, linkArray) into dArray
   end if
   return dArray 
end descendent_Array

getprop parent_Array
   put the link_Array of me into linkArray
   put linkArray_GetParentArray (linkArray) into parentArray
   --
   if the long id of the target = the long id of me then
      return parentArray
   else
      put the short name of the target into nodeName
      return parentArray [nodeName]
   end if
end parent_Array

getprop child_Array
   put the link_Array of me into linkArray
   if the long id of the target = the long id of me then
      return linkArray
   else
      put the short name of the target into nodeName
      put linkArray [nodeName] into cArray
      return cArray
   end if
end child_Array

getprop link_Array
   put the dot_Array of me into dotArray
   put dotArray ["objects"] into objectsArray
   put dotArray ["edges"] into edgesArray
   --
   put _ConstructLinkArray (objectsArray, edgesArray) into linkArray
   return linkArray
end link_Array

getprop object_Array
   put the dot_Array of me into dotArray
   put dotArray ["objects"] into objectsArray
   return objectsArray
end object_Array


--> Deps | lib_DotCreate
-
function dot_CreateText dotText, pImageFormat, pDotCommand, pFile
   -- "neato,circo,twopi,fdp,sfdp,dot"
   
   file_CreateText dotText, pFile
   put the result into dotFile
   dot_CreateTextFile dotFile, pImageFormat, pDotCommand
   put the result into dotExport
   return dotExport
end dot_CreateText

command dot_CreateTextFile dotFile, pImageFormat, pDotCommand
   if pImageFormat is empty then put "svg" into pImageFormat
   if pDotCommand is empty then put "dot" into pDotCommand -- "neato,circo,twopi,fdp,sfdp,dot"
   
   -- put dot_DoShell (dotFile, "dot", pImageFormat) into dotExport
   put pDotCommand into someShell
   put space & "-T" & pImageFormat after someShell
   put space & quote & dotFile & quote after someShell
   --
   put shell(someShell) into dotExport
   return dotExport
end dot_CreateTextFile

command file_CreateText someText, pFile
   if pFile is empty then put the tempname into pFile
   --
   put folder_Above (pFile) into someFolder
   folder_CreateNested someFolder
   put someText into url ("file:" & pFile)
   return pFile
end file_CreateText


--> Tests
-
getprop max_Factor
   return false
end max_Factor


--> Appearance
-
getprop browser_Visible
   return the visible of _BrowserControl()
end browser_Visible

setprop browser_Visible sBoolean
   set the visible of _BrowserControl() to (sBoolean is true)
end browser_Visible

setprop faded_Nodes [bLevel] nodeNames
   if bLevel is not a number then put 80 into bLevel
   
   switch nodeNames
      case empty
         if the long id of the target = the long id of me then
            put the node_Names of me into nodeNames
         else
            put the short name of the target into nodeNames
         end if
         break
      case "all"
         put the node_Names of me into nodeNames
         break
      default
         replace comma with CR in nodeNames
   end switch
   
   lock screen
   repeat for each line nodeName in nodeNames
      set the fade_Level of control nodeName of me to bLevel
   end repeat
   unlock screen
end faded_Nodes

setprop fade_Level bLevel
   if the long id of the target = the long id of me then return empty
   
   lock screen
   put the long id of the target into tNode
   set the blendlevel of tNode to bLevel
   --
   put the parent_Edges of tNode into parentEdges
   repeat for each line edgeName in parentEdges
      set the blendlevel of graphic edgeName of me to bLevel
   end repeat
   --
   put the child_Edges of tNode into childEdges
   repeat for each line edgeName in childEdges
      set the blendlevel of graphic edgeName of me to bLevel
   end repeat
   --
   unlock screen
end fade_Level


--> Colour
-
setprop edge_Colour [edgeNames] sColour
   switch edgeNames
      case empty
         if the long id of the target = the long id of me then
            put the edge_Names of me into edgeNames
         else
            put the short name of the target into edgeNames
         end if
         break
      case "all"
         put the edge_Names of me into edgeNames
         break
      default
         replace comma with CR in edgeNames
   end switch
   
   lock screen
   repeat for each line edgeName in edgeNames
      set the foregroundcolor of graphic edgeName of me to sColour
      set the blendlevel of graphic edgeName of me to 0
   end repeat
   unlock screen
end edge_Colour

setprop node_Colour [nodeNames] sColour
   switch nodeNames
      case empty
         if the long id of the target = the long id of me then
            put the node_Names of me into nodeNames
         else
            put the short name of the target into nodeNames
         end if
         break
      case "all"
         put the node_Names of me into nodeNames
         break
      default
         replace comma with CR in nodeNames
   end switch
   
   lock screen
   repeat for each line nodeName in nodeNames
      set the backgroundcolor of control nodeName of me to sColour
      set the blendlevel of control nodeName of me to 0
   end repeat
   unlock screen
   return nodeNames
end node_Colour

setprop descendent_Colour sColour
   -- put the descendent_LevelArray of the target into dLevelArray
   -- put the descendent_Array of the target into dArray
   put the short name of the target into nodeName
   put the dot_Array of me into dotArray
   put dotArray ["objects"] into objectsArray
   put dotArray ["edges"] into edgesArray
   put _ConstructLinkArray (objectsArray, edgesArray) into linkArray
   
   put linkArray_GetDescendentArray (nodeName, linkArray) into dArray
   put _ConstructDescendentLevelArray (dArray) into dLevelArray
   --
   lock screen
   repeat with levelNum = 1 to item 2 of the extents of dLevelArray
      put the keys of dLevelArray [levelNum] into levelNames
      put colour_GetLevel (sColour, levelNum) into nColour
      set the node_Colour [levelNames] of me to nColour
   end repeat
   unlock screen
   --
   put the keys of dArray into dNames
   repeat for each element objectArray in objectsArray
      get objectArray ["name"]
      if it is not among the lines of dNames then
         put it & CR after missingNames
      end if
   end repeat
   delete char -1 of missingNames
   sort missingNames
   return missingNames
end descendent_Colour


--> Names
-
getprop edge_Names
   if the long id of the target = the long id of me then
      get the dot_Array of me
      put it ["edges"] into edgesArray
      repeat for each element edgeArray in edgesArray
         put dotArray_ConstructEdgeName (edgeArray) into edgeName
         put edgeName & CR after edgeNames
      end repeat
      sort numeric edgeNames by word 2 of each
   else
      put the short name of the target into nodeName
      put the link_Array of me into linkArray
      --
      put linkArray_GetEdgeNames (nodeName, linkArray) into edgeNames
   end if
   return edgeNames 
end edge_Names

getprop descendent_Names
   if the long id of the target = the long id of me then
      put the node_Names of me into dNames
   else
      put the short name of the target into nodeName
      put the link_Array of me into linkArray
      --
      put linkArray_GetDescendents (nodeName, linkArray) into dNames
   end if
   return dNames 
end descendent_Names

getprop descendent_Names
   if the long id of the target = the long id of me then
      put the node_Names of me into dNames
   else
      put the short name of the target into nodeName
      put the link_Array of me into linkArray
      --
      put linkArray_GetDescendents (nodeName, linkArray) into dNames
   end if
   return dNames 
end descendent_Names

getprop parent_Names
   put the parent_Array of the target into parentArray
   put keys (parentArray) into parentNames
   sort parentNames
   return parentNames
end parent_Names

getprop child_Names
   if the long id of the target = the long id of me then
      put the node_Names of me into cNames
   else
      put the short name of the target into nodeName
      put the link_Array of me into linkArray
      --
      put linkArray [nodeName] into cArray
      delete variable cArray [nodeName]
      --
      put the keys of cArray into cNames
   end if
   return cNames
end child_Names

getprop parent_Edges
   put the parent_Array of the target into pArray
   put _GetEdgeNames (pArray) into edgeNames
   return edgeNames
end parent_Edges

getprop child_Edges
   put the child_Array of the target into cArray
   put _GetEdgeNames (cArray) into edgeNames
   return edgeNames
end child_Edges

getprop node_Names
   put the dot_Array of me into dotArray
   --
   put dotArray ["objects"] into objectsArray
   repeat with itemNum = 1 to item 2 of the extents of objectsArray
      put objectsArray [itemNum]["name"] into oName
      put oName & CR after nodeNames
   end repeat
   delete char -1 of nodeNames
   return nodeNames
end node_Names


--> Handlers
-
private function _ConstructLinkArray objectsArray, edgesArray
   repeat with itemNum = 1 to item 2 of the extents of edgesArray
      put edgesArray [itemNum] into edgeArray
      --
      put edgeArray ["head"] + 1 into headNum
      put edgeArray ["tail"] + 1 into tailNum
      put objectsArray [tailNum] into fromObjectArray
      put objectsArray [headNum] into toObjectArray
      put fromObjectArray ["name"] into fromName
      put toObjectArray ["name"] into toName
      
      put dotArray_ConstructEdgeName (edgeArray) into edgeName
      put edgeName into linkArray [fromName][toName]["edgeName"]
   end repeat
   return linkArray
end _ConstructLinkArray

function linkArray_GetEdgeNames nodeName, linkArray
   put linkArray [nodeName] into nodeArray
   repeat for each element edgeArray in nodeArray
      put edgeArray ["edgeName"] & CR after edgeNames
   end repeat
   delete char -1 of edgeNames
   sort edgeNames
   return edgeNames
end linkArray_GetEdgeNames

function _ConstructDescendentLevelArray dArray
   repeat for each key nodeName in dArray
      put dArray [nodeName]["level"] into levelNum
      put empty into dLevelArray [levelNum][nodeName]
   end repeat
   return dLevelArray
end _ConstructDescendentLevelArray

function colour_GetLevel sColour, levelNum
   put 2.5 into sFactor
   put sFactor * (levelNum - 1) * 10 into sPercent
   --
   put colour_Lighten (sColour, sPercent) into nColour
   return nColour
end colour_GetLevel

function colour_Lighten rgbColour, pPercent
   if rgbColour is empty then put "256,256,256" into rgbColour
   if pPercent is empty then put 10 into pPercent
   colour_RgbNormalise rgbColour
   put colour_RgbToHSV (rgbColour) into hsvColour
   --
   put (100 - pPercent)/100 * item 2 of hsvColour into newSaturation
   put min (newSaturation, 100) into newSaturation
   put max(newSaturation, 0) into newSaturation
   put newSaturation into item 2 of hsvColour
   --
   put colour_HsvToRgb (hsvColour) into newRgbColour
   return newRgbColour
end colour_Lighten

function linkArray_GetParentArray linkArray
   repeat for each key parentName in linkArray
      put linkArray [parentName] into childArray
      repeat for each key childName in childArray
         put childArray [childName]["edgeName"] into edgeName
         put edgeName into parentArray [childName][parentName]["edgeName"]
      end repeat
   end repeat
   return parentArray
end linkArray_GetParentArray

function linkArray_GetDescendents nodeName, linkArray
   put linkArray_GetDescendentArray (nodeName, linkArray) into dArray
   delete variable dArray [nodeName]
   put the keys of dArray into dNames
   sort numeric dNames by char 2 to -1 of each
   return dNames
end linkArray_GetDescendents

function linkArray_GetDescendentArray nodeName, linkArray
   local dArray
   _ConstructDescendentArray dArray, nodeName, linkArray, 1
   return dArray
end linkArray_GetDescendentArray

private command _ConstructDescendentArray @dArray, nodeName, linkArray, levelNum
   put dArray [nodeName]["level"] into oLevelNum
   --
   switch
      case oLevelNum is empty
         put levelNum into dArray [nodeName]["level"]
         break
      case levelNum >= oLevelNum
         break -- don't rewrite level
      default
         -- should not happen
         put levelNum into dArray [nodeName]["level"]
   end switch
   --
   add 1 to levelNum
   put linkArray [nodeName] into childArray
   repeat for each key childName in childArray
      _ConstructDescendentArray dArray, childName, linkArray, levelNum
   end repeat
end _ConstructDescendentArray

private function _GetEdgeNames pArray
   repeat for each key pName in pArray
      put pArray [pName]["edgeName"] & CR after edgeNames
   end repeat
   delete char -1 of edgeNames
   return edgeNames
end _GetEdgeNames


--> Events
-
on preOpenControl
   get the behavior of _BrowserControl()
   if exists (stack "behavior_ViewImageSVG") then
      put the name of stack "behavior_ViewImageSVG" into bObject
      set the behavior of _BrowserControl() to bObject
   end if
   pass preOpenControl
end preOpenControl

on mouseDown
   put the long id of the target into tObject
   if word 1 of tObject is not "graphic" then pass mouseDown
   
   put the style of tObject into gStyle
   switch gStyle
      case "curve"
         menu_PopUp "Global | Dot | Edge | Menu", empty, tObject
         break
      default
         menu_PopUp "Global | Dot | Node | Menu", empty, tObject
   end switch
end mouseDown

on resizeControl
   put the rect of me into viewRect
   LayoutControl viewRect
end resizeControl


function rect_GetCentre someRect
   put item 1 of someRect into someLeft
   put trunc((item 3 of someRect - someLeft)/2) into halfWidth
   put item 2 of someRect into someTop
   put trunc((item 4 of someRect - someTop)/2) into halfHeight
   put someLeft + halfWidth into item 1 of someMiddle
   put someTop + halfHeight into item 2 of someMiddle
   return someMiddle
end rect_GetCentre


--> Scale
-
getprop auto_Scale
   return LocalArray ["autoScale"] is true
end auto_Scale

setprop auto_Scale sBoolean
   put sBoolean into LocalArray ["autoScale"]
   LayoutControl
end auto_Scale

getprop auto_ScaleFactor [targetRect]
   -- returns correct scale factor
   if targetRect is empty then
      put the view_RectOnCard of me into targetRect
   end if
   put the bb_Rect of me into bbRect
   -- set the rect_Test ["blue"] of the card_Object of me to bbRect
   rect_SetScaleVectors bbRect, targetRect, scaleX, scaleY
   
   return min (scaleX, scaleY)
end auto_ScaleFactor

command rect_SetScaleVectors someRect, targetRect, @scaleX, @scaleY
   put item 3 of someRect - item 1 of someRect into someWidth
   put item 3 of targetRect - item 1 of targetRect into targetWidth
   put targetWidth/someWidth into scaleX
   
   put item 4 of someRect - item 2 of someRect into someHeight
   put item 4 of targetRect - item 2 of targetRect into targetHeight
   put targetHeight/someHeight into scaleY
   
   return scaleX,scaleY
end rect_SetScaleVectors


--> Geometry
-
getprop original_Rect
   put the dot_Array of me into dotArray
   put _GetBackgroudRect (dotArray) into bbRect
   return bbRect
end original_Rect

getprop bb_Width
   get the bb_Rect of me
   return item 3 of it - item 1 of it
end bb_Width

getprop bb_Rect
   put LocalArray ["bbRect"] into bbRect
   if bbRect is not a rect then
      put the dot_Array of me into dotArray
      put _GetBackgroudRect (dotArray) into bbRect
      put bbRect into LocalArray ["bbRect"]
   end if
   return bbRect
end bb_Rect

setprop bb_Rect bbRect
   put bbRect into LocalArray ["bbRect"]
end bb_Rect

command _ConvertPoints @gPoints
   -- works for loc,and points but not rect
   if the top_Down of me is true then
      -- flip vertical
      put the bb_Rect of me into bbRect
      put item 4 of bbRect - item 2 of bbRect into mY
      repeat with lineNum = 1 to the number of lines of gPoints
         put item 2 of line lineNum of gPoints into sY
         put mY - sY into item 2 of line lineNum of gPoints
      end repeat 
   else
      -- do nothing
   end if
end _ConvertPoints

command _ConvertRect @sRect, pTopDown
   if pTopDown is true then
      -- flip vertical
      put the bb_Rect of me into bbRect
      put item 4 of bbRect - item 2 of bbRect into mY
      
      put sRect into nRect
      put item 2 of sRect into rTop
      put item 4 of sRect into rBottom
      
      put mY - rTop into item 4 of nRect
      put mY - rBottom into item 2 of nRect
      put nRect into sRect
   else
      -- do nothing
   end if
end _ConvertRect


--> Props
-
getprop show_Nodes
   return LocalArray ["showNodes"] is not false
end show_Nodes

setprop show_Nodes showNodes
   put the node_Objects of me into nodeObjects
   --
   lock screen
   repeat for each line nodeObject in nodeObjects
      set the visible of nodeObject to showNodes
   end repeat
   unlock screen
   --
   put showNodes into LocalArray ["showNodes"]
   return nodeObjects
end show_Nodes

getprop show_NodeLabels
   return LocalArray ["showNodeLabels"] is not false
end show_NodeLabels

setprop show_NodeLabels showNodeLabels
   put the dot_Array of me into dotArray
   put dotArray ["objects"] into objectArray
   --
   lock screen
   repeat with oNum = 1 to item 2 of the extents of objectArray
      put objectArray [oNum]["name"] into oName
      put the long id of graphic oName of me into nodeObject
      --
      if showNodeLabels is false then
         set the label of nodeObject to empty
      else
         put objectArray [oNum]["label"] into oLabel
         switch oLabel
            case "\N"
            case empty
               set the label of nodeObject to empty
               break
            default
               set the label of nodeObject to oLabel
         end switch
      end if 
   end repeat
   unlock screen
   
   put showNodeLabels into LocalArray ["showNodeLabels"]
   return objectArray
end show_NodeLabels

getprop show_Names
   return LocalArray ["showNames"] is not false
end show_Names

setprop show_Names sBoolean
   put the dot_Array of me into dotArray
   put dotArray ["objects"] into objectArray
   --
   lock screen
   repeat with oNum = 1 to item 2 of the extents of objectArray
      put objectArray [oNum]["name"] into oName
      put the long id of graphic oName of me into nodeObject
      set the showname of nodeObject to sBoolean
   end repeat
   unlock screen
   
   put sBoolean into LocalArray ["showNames"]
   return objectArray
end show_Names

getprop show_Edges
   return LocalArray ["showEdges"] is not false
end show_Edges

setprop show_Edges showEdges
   put the edge_Objects of me into edgeObjects
   --
   lock screen
   repeat for each line edgeObject in edgeObjects
      set the visible of edgeObject to showEdges
   end repeat
   unlock screen
   --
   put showEdges into LocalArray ["showEdges"]
   return nodeObjects
end show_Edges

getprop edge_Width
   return LocalArray ["edgeWidth"]
end edge_Width

setprop edge_Width edgeWidth
   put the edge_Objects of me into edgeObjects
   --
   lock screen
   repeat for each line edgeObject in edgeObjects
      set the lineSize of edgeObject to edgeWidth
   end repeat
   unlock screen
   --
   put edgeWidth into LocalArray ["edgeWidth"]
   return nodeObject
end edge_Width

getprop edge_Objects
   put the dot_Array of me into dotArray
   put dotArray ["edges"] into edgesArray
   repeat with itemNum = 1 to item 2 of the extents of edgesArray
      put edgesArray [itemNum] into edgeArray
      put dotArray_ConstructEdgeName (edgeArray) into edgeName
      put the long id of graphic edgeName of me into edgeObject
      put edgeObject & CR after edgeObjects
   end repeat
   delete char -1 of edgeObjects
   return edgeObjects
end edge_Objects

getprop node_Objects
   put the dot_Array of me into dotArray
   put dotArray ["objects"] into objectArray
   repeat with oNum = 1 to item 2 of the extents of objectArray
      put objectArray [oNum]["name"] into oName
      put the long id of graphic oName of me into nodeObject
      put nodeObject & CR after nodeObjects
   end repeat
   delete char -1 of nodeObjects
   return nodeObjects
end node_Objects

getprop top_Down
   put LocalArray ["topDown"] is not false into topDown
   return topDown
end top_Down

getprop top_Down
   put LocalArray ["topDown"] is not false into topDown
   return topDown
end top_Down

setprop top_Down topDown
   put topDown is true into LocalArray ["topDown"]
   set the dot_Array of me to the dot_Array of me
end top_Down


--> Graph | Data
-
getprop dot_URL
   put the dot_URL of me into dotURL
   return dotURL
end dot_URL

setprop dot_URL [gRect] dotURL
   switch dotURL
      case "minimal"
         put dot_GetMinimal() into dotText
         break
      default
         put url dotURL into dotText
   end switch
   set the dot_Text [gRect] of me to dotText
   put the result into dotArray
   return dotArray
end dot_URL

getprop dot_Text
   put the dot_Text of me into dotText
   return dotText
end dot_Text

setprop dot_Text [gRect] dotText
   if gRect is empty then put the rect of me into gRect
   set the dot_Text of me to dotText
   --
   lock screen
   put the dot_Command of me into dotCommand
   put the dot_File of me into dotFile
   --
   -- put dot_CreateArray (dotText, dotCommand, dotFile) into dotArray
   file_CreateText dotText, dotFile
   put the result into dotFile
   set the dot_File of me to dotFile
   --
   dot_CreateTextFile dotFile, "json", dotCommand
   put the result into dotJSON
   put json_ToArray(dotJSON) into dotArray   
   --
   set the dot_Array of me to dotArray
   --
   LayoutControl gRect
   unlock screen
   return dotArray
end dot_Text


--> Dot
-
getprop dot_Name
   put LocalArray ["dotName"] into dotName
   if dotName is empty then
      put the dot_Array of me into dotArray
      put dotArray ["name"] into dotName
   end if
   return dotName
end dot_Name

setprop dot_Name dotName
   put dotName into LocalArray ["dotName"]
end dot_Name

getprop dot_File
   put the dot_File of me into dotFile
   if there is a file dotFile then
      return dotFile
   else
      put the dot_Folder of me into dotFolder
      if dotFolder is empty then return empty
      --
      put the dot_Name of me into dotName
      if dotName is empty then put "graphviz" into dotName
      put dotFolder & dotName & ".dot" into dotFile
      return dotFile
   end if
end dot_File

setprop dot_File dotFile
   set the dot_File of me to dotFile
end dot_File

getprop dot_Folder
   # Use the asset folder if this is a module
   put the module_AssetFolder of me into dotFolder
   if there is a folder dotFolder then return dotFolder
   
   # Get a custom or temporary folder
   put the dot_Folder of me into dotFolder
   if there is a folder dotFolder then
      text_AddTrailing dotFolder, slash
      return dotFolder
   else
      return empty
   end if
end dot_Folder

setprop dot_Folder dotFolder
   set the dot_Folder of me to dotFolder
end dot_Folder

getprop dot_Command
   put the dot_Command of me into dotCommand
   if dotCommand is empty then
      return "dot"
   else
      return dotFile
   end if
end dot_Command

setprop dot_Command dotCommand
   set the dot_Command of me to dotCommand
end dot_Command


--> Objects
-
getprop graph_Controls
   put the number of graphics of me into gNums
   repeat with gNum = 1 to gNums
      get the long id of  graphic gNum of me
      put it & CR after graphControls
   end repeat
   delete char -1 of graphControls
   return graphControls
end graph_Controls

getprop browser_View
   return _BrowserControl()
end browser_View

private function _BrowserControl
   put the long id of widget "Browser" of me into browserControl
   return browserControl
end _BrowserControl

getprop graph_View
   return the long id of me
end graph_View

getprop view_Object
   return the long id of me
end view_Object

