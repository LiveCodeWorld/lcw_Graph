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
*/

--> Variables
-
local LocalArray


--> Working on
-
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


--> Deps | lib_DotCreate
-
function dot_CreateArray dotText, pDotCommand, pFile
   put dot_CreateText (dotText, "json", pDotCommand, pFile) into dotJSON
   put json_ToArray(dotJSON) into dotArray
   return dotArray
end dot_CreateArray

function dot_CreateText dotText, pImageFormat, pDotCommand, pFile
   -- "neato,circo,twopi,fdp,sfdp,dot"
   if pImageFormat is empty then put "svg" into pImageFormat
   if pDotCommand is empty then put "dot" into pDotCommand -- "neato,circo,twopi,fdp,sfdp,dot"
   
   file_CreateText dotText, pFile
   put the result into dotFile
   --
   -- put dot_DoShell (dotFile, "dot", pImageFormat) into dotExport
   put pDotCommand into someShell
   put space & "-T" & pImageFormat after someShell
   put space & quote & dotFile & quote after someShell
   --
   put shell(someShell) into dotExport
   return dotExport
end dot_CreateText

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

getprop scale_Test
   get the bb_Rect of me
   put item 3 of it - item 1 of it into bbWidth
   put item 4 of it - item 2 of it into bbHeight
   put the card_Object of me into cObject
   put the auto_ScaleFactor of grp 1 into sFactor
   put 2*the card_Margin of grp 1 into twiceMargin
   --
   get sFactor * bbWidth
   -- subtract the width of me from it
   subtract the width of cObject from it
   put round (it + twiceMargin) into widthZero
   put widthZero = 0 into widthGood
   --   
   get sFactor * bbHeight
   -- subtract the height of me from it
   subtract the height of cObject from it
   put round (it + twiceMargin) into heightZero
   put heightZero = 0 into heightGood
   --
   get widthGood && heightGood &CR& widthZero && heightZero
   return it
end scale_Test


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
         put _EdgeName (edgeArray) into edgeName
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
      
      put _EdgeName (edgeArray) into edgeName
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


--> Events | Custom
-
on refreshDisplay
   put the rect of me into viewRect
   LayoutControl viewRect
end refreshDisplay

command LayoutControl pRect
   lock screen
   -- if pRect is empty then put the rect of me into pRect
   put the inner_Rect [pRect] of me into innerRect
   
   if the auto_Scale of me is true then
      put the auto_ScaleFactor [pRect] of me into sFactor
      put rect_GetCentre (pRect) into graphLoc
      set the graph_Scale [graphLoc] of me to sFactor
   else
      put rect_GetCentre (pRect) into newLoc
      set the loc of me to newLoc
   end if
   --
   set the rect of _BrowserControl() to innerRect
   unlock screen
end LayoutControl

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

setprop graph_Scale [graphLoc] sFactor
   put the dot_Array of me into dotArray
   put the top_Down of me into pTopDown
   --
   if graphLoc is empty then
      put the loc of me into graphLoc
   end if
   
   lock screen
   --
   _ScaleGraph dotArray, sFactor, pTopDown
   set the loc of me to graphLoc
   --
   unlock screen
end graph_Scale

private command _ScaleGraph dotArray, sFactor, pTopDown
   -- sets position of all graph elements with topleft at 0,0
   put _GetBackgroudRect (dotArray) into bbRect
   put rect_GetCentre (bbRect) into bbCentre
   
   -- scale nodes
   put dotArray ["objects"] into objectArray
   repeat with nodeNum = 1 to item 2 of the extents of objectArray
      put objectArray [nodeNum] into nodeArray
      put nodeArray ["name"] into nodeName
      --
      if exists (graphic nodeName of me) is false then next repeat
      put the long id of graphic nodeName of me into nodeObject
      --
      put _NodeRect (nodeArray, pTopDown) into nodeRect
      if sFactor is not 1 then
         put rect_ScaleFromCentre (nodeRect, sFactor, bbCentre) into nodeRect
      end if
      set the rect of nodeObject to nodeRect
   end repeat
   
   -- scale edges
   put dotArray ["edges"] into edgesArray
   repeat with itemNum = 1 to item 2 of the extents of edgesArray
      put edgesArray [itemNum] into edgeArray
      put _EdgeName (edgeArray) into edgeName
      --
      if exists (graphic edgeName of me) is false then next repeat
      put the long id of graphic edgeName of me into edgeObject
      --
      put _GetEdgePoints (edgeArray, bbRect, bbCentre, pTopDown, sFactor) into edgePoints
      set the points of edgeObject to edgePoints
   end repeat   
end _ScaleGraph

private function _GetEdgePoints edgeArray, bbRect, bbCentre, pTopDown, pScaleFactor
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
end _GetEdgePoints

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

private function _NodeRect oArray, pTopDown
   put oArray ["shape"] into oShape
   switch
      case oShape = "box"
         -- put _GetDrawRect (oArray, 2) into gRect
         put _RectFromArray (oArray) into gRect
         break
      case oShape = "ellipse"
      case oShape = "circle"
      default
         put _GetDrawRect (oArray, 2) into gRect
   end switch
   --
   _ConvertRect gRect, pTopDown
   return gRect
end _NodeRect

private function _GetBackgroudRect dotArray
   put dotArray ["bb"] into bb
   put trunc (item 3 of bb) into sWidth
   put trunc (item 4 of bb) into sHeight
   -- put rect_FromWidthAndHeight (cRect, sWidth, sHeight) into bbRect
   put 0,0,sWidth,sHeight into bbRect
   --
   return bbRect
end _GetBackgroudRect


--> Geometry
-
getprop original_Rect
   put the dot_Array of me into dotArray
   put _GetBackgroudRect (dotArray) into v
   return bbRect
end original_Rect

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
      put _EdgeName (edgeArray) into edgeName
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
   put dot_CreateArray (dotText, dotCommand, dotFile) into dotArray
   set the dot_Array of me to dotArray
   --
   LayoutControl gRect
   unlock screen
   return dotArray
end dot_Text

getprop dot_Array
   put the dot_Array of me into dotArray
   return dotArray
end dot_Array

setprop dot_Array [edgeWidth] dotArray
   local bbRect
   
   lock screen
   put the loc of me into oLoc
   --
   _DeleteGraphics 
   --
   if dotArray is an array then
      put _GetBackgroudRect (dotArray) into bbRect
      set the bb_Rect of me to bbRect
      --
      set the lockloc of me to false
      _CreateEdges dotArray, edgeWidth
      _CreateObjects dotArray
      --
      -- set the lockloc of me to true
      set the dot_Array of me to dotArray
   end if
   --
   set the loc of me to oLoc
   unlock screen
   return bbRect
end dot_Array

private command _DeleteGraphics
   put the number of graphics of me into gNums
   repeat with gNum = gNums down to 1
      delete graphic gNum of me
   end repeat
end _DeleteGraphics

getprop graph_Controls
   put the number of graphics of me into gNums
   repeat with gNum = 1 to gNums
      get the long id of  graphic gNum of me
      put it & CR after graphControls
   end repeat
   delete char -1 of graphControls
   return graphControls
end graph_Controls

private command _CreateObjects dotArray, dotGroup
   set the showName of templateGraphic to true
   --
   put dotArray ["objects"] into objectsArray
   repeat with itemNum = 1 to item 2 of the extents of objectsArray
      put objectsArray [itemNum] into oArray
      put oArray ["name"] into oName
      --
      put oArray ["nodes"] into nodeArray
      switch
         case nodeArray is an array
            break
         default
            _CreateGraphic oArray, dotGroup
      end switch
      --
   end repeat
end _CreateObjects

private command _CreateGraphic oArray
   put oArray ["name"] into oName
   put oArray ["label"] into oLabel
   put oArray ["shape"] into oShape
   put oArray ["style"] is "filled" into isOpaque
   --
   reset templateGraphic
   set the opaque of the templateGraphic to true
   set the showName of the templateGraphic to true
   --
   create graphic oName in me
   put it into gObject
   --
   switch oLabel
      case "\N"
         break -- don't set (same as name)
      default
         set the label of gObject to oLabel
   end switch
   --
   switch
      case oArray ["nodes"] is an array
         break -- creeate a group
      case oShape = "box"
         set the style of gObject to "rectangle"
         -- put _GetDrawRect (oArray, 2) into gRect
         put _RectFromArray (oArray) into gRect
         set the graphic_Rect of gObject to gRect
         break
      case oShape = "triangle"
         set the style of gObject to "polygon"
         put _GetDrawPoints (oArray, 3) into gPoints
         set the graphic_Points of gObject to gPoints
         break
      case oShape = "diamond"
         set the style of gObject to "polygon"
         put _GetDrawPoints (oArray, 3) into gPoints
         set the graphic_Points of gObject to gPoints
         break
      case oShape = "pentagon"
         set the style of gObject to "regular"
         set the polysides of gObject to 5
         break
      case oShape = "ellipse"
      case oShape = "circle"
      default
         set the style of gObject to "oval"
         --
         put _GetDrawRect (oArray, 2) into oRect
         set the graphic_Rect of gObject to oRect
   end switch
   --
   return gObject
end _CreateGraphic

private command _CreateEdges dotArray, pEdgeWidth
   set the showName of templateGraphic to true
   --
   put dotArray ["edges"] into edgesArray
   repeat with itemNum = 1 to item 2 of the extents of edgesArray
      put edgesArray [itemNum] into edgeArray
      _CreateEdge edgeArray, pEdgeWidth
   end repeat
end _CreateEdges

private function _EdgeName edgeArray
   put "Edge" && edgeArray ["_gvid"] into edgeName
   return edgeName
end _EdgeName

private command _CreateEdge edgeArray, pEdgeWidth
   if pEdgeWidth is not a number then
      put 4 into pEdgeWidth
   end if
   --
   put the top_Down of me into topDown
   put the bb_Rect of me into bbRect
   put rect_GetCentre (bbRect) into bbCentre
   put _GetEdgePoints (edgeArray, bbRect, bbCentre, topDown) into edgePoints
   --
   put _EdgeName (edgeArray) into edgeName
   --
   reset templateGraphic
   set the style of the templateGraphic to curve
   set the lineSize of the templateGraphic to pEdgeWidth
   set the endArrow of the templateGraphic to true
   set the showName of the templateGraphic to false
   --
   lock screen
   create graphic edgeName in me
   put it into edgeObject
   -- set the graphic_Points of edgeObject to edgePoints
   set the points of edgeObject to edgePoints
   unlock screen
   --
   reset templateGraphic
   return edgeObject
end _CreateEdge


--> Geometry | Create
-
private function _GetDrawPoints oArray, itemNum
   get oArray ["_draw_"]
   put it [itemNum]["points"] into pArray
   repeat with itemNum = 1 to item 2 of the extents of pArray
      put pArray [itemNum][1] into item 1 of pLoc
      put pArray [itemNum][2] into item 2 of pLoc
      put pLoc & CR after gPoints
   end repeat
   put line 1 of gPoints after gPoints
   return gPoints
end _GetDrawPoints

private function _RectFromArray oArray
   -- basic way
   get oArray["pos"]
   put item 1 of it into cx
   put item 2 of it into cy
   put 72/2 * oArray["width"] into rx
   put 72/2 * oArray["height"] into ry
   --
   put _ConvertCrxy (cx, cy, rx, ry) into newRect
   return newRect 
end _RectFromArray

private function _GetDrawRect oArray, itemNum
   get oArray ["_draw_"]
   put it [itemNum]["rect"] into rArray
   --
   put rArray [1] into cx
   put rArray [2] into cy
   put rArray [3] into rx
   put rArray [4] into ry
   --
   put _ConvertCrxy (cx, cy, rx, ry) into newRect
   return newRect
end _GetDrawRect

function _ConvertCrxy cx, cy, rx, ry
   put cx,cy into someLoc
   put 2*rx into newW
   put 2*ry into newH
   --
   put rect_LocWidthHeight (someLoc, newW, newH) into newRect
   return newRect
end _ConvertCrxy


--> Objects
-
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
