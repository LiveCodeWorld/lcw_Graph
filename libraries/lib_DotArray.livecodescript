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
*/

--> Variables
-
constant TemplateBorderWidth = 2


--> Working on
- 


--> Dot | Construct
-
function dot_ConstructNodeParamBit nodeLabel, nodeShape, nodeStyle, nodeColour, nodeFillColour, polyParams, nodeUrl, nodeToolTip
   -- was "node_ConstructParamLine"
   local nodeLine
   
   if nodeLabel is not empty then
      put "label='[[nodeLabel]]'" into nodeLine
   end if
   
   if nodeShape is not empty then
      if nodeLine is not empty then
         put "," & space after nodeLine
      end if
      put "shape=[[nodeShape]]" after nodeLine
      if nodeShape is "polygon" then
         if polyParams is not empty then
            put "," && polyParams after nodeLine
         end if
      end if
   end if
   
   dot_AddStyleToNodeDef nodeStyle, nodeLine, false
   dot_AddParamToNodeDef "color", nodeColour, nodeLine, false
   dot_AddParamToNodeDef "fillcolor", nodeFillColour, nodeLine, false
   dot_AddParamToNodeDef "URL", nodeUrl, nodeLine
   dot_AddParamToNodeDef "tooltip", nodeToolTip, nodeLine
   -- dot_AddParamToNodeDef "shapefile", nodeShapeFile, nodeLine
   
   replace "'" with quote in nodeLine
   put merge(nodeLine) into nodeLine
   
   return nodeLine
end dot_ConstructNodeParamBit

function dot_NodeObjectArray propArray, pNodeUrl
   put propArray ["id"] into objectArray ["_gvid"]
   --
   put propArray ["name"] into nodeName
   dot_NormalizeName nodeName
   put nodeName into objectArray ["name"]
   --
   dot_SetObjectArray "name", "name", propArray, objectArray
   dot_SetObjectArray "label", "label", propArray, objectArray
   dot_SetObjectArray "toolTip", "toolTip", propArray, objectArray
   
   put propArray ["backColor"] into bColour
   if bColour is not empty then
      put dot_GetColour (bColour) into objectArray ["fillcolor"]
   end if
   --
   put propArray ["foreColor"] into fColour
   if bColour is not empty then
      put dot_GetColour (fColour) into objectArray ["color"]
   end if
   --
   put dot_ShapeFromStyle (propArray) into objectArray ["shape"]
   dot_SetObjectArrayStyle objectArray, propArray
   if propArray ["style"] = "regular" then
      put propArray ["polySides"] into objectArray ["polySides"]
   end if
   --
   if pNodeUrl is not empty then
      put pNodeUrl into objectArray ["URL"]
   end if
   --
   -- display_Data propArray
   put propArray ["rect"] into sRect
   put dot_GraphInchSize (sRect) into dotPos
   --
   return objectArray
end dot_NodeObjectArray

command dot_NormalizeName @sName
   put word 1 to -1 of sName into sName
   replace "|" with space in sName
end dot_NormalizeName

private command dot_SetObjectArray propKey, objectKey, propArray, @objectArray
   put propArray [propKey] into propValue
   dot_SetObjectArrayValue propValue, objectKey, objectArray
end dot_SetObjectArray

private command dot_SetObjectArrayValue propValue, objectKey, @objectArray
   if propValue is not empty then
      put propValue into objectArray [objectKey]
   end if
end dot_SetObjectArrayValue

command dot_SetLivecodePropertyArray @propArray, dotStyle   
   switch dotStyle
      case "striped" -- Fills the node with stripes. The colors of the stripes can be specified using the fillcolor attribute with a colon-separated list of colors.
      case "wedged" -- Similar to striped, but used for elliptical shapes.
      case "diagonals" -- Adds diagonal lines to the node.
      case "dashed" -- Draws the node with a dashed outline.
         put "4,2" into propArray ["dashes"]
         break
      case "dotted" -- Draws the node with a dotted outline.
         put "1,1" into propArray ["dashes"]
         break
      case "bold" -- Draws the node with a bold outline.
         put 2 into propArray ["linesize"]
         break
      case "rounded" -- Gives the node rounded corners (this is often combined with the shape=box attribute).
         put "roundrect" into propArray ["style"]
         break
      case "filled" -- Fills the node with a solid color. The color can be specified using the fillcolor attribute.
         put true into propArray ["opaque"]
         break
      case "invis" -- Makes the node invisible in the rendered output.
         put false into propArray ["visible"]
         break
      case "solid" -- (default): Draws the node with a solid outline.
      default
         put empty into propArray ["dashes"]
   end switch
end dot_SetLivecodePropertyArray

private command dot_SetObjectArrayStyle @objectArray, propArray 
   _AddStyleIf "visible", false, "invis", propArray, objectArray
   _AddStyleIf "opaque", true, "filled", propArray, objectArray
   _AddStyleIf "style", "roundrect", "rounded", propArray, objectArray
   --
   switch propArray ["dashes"]
      case empty
         _AddStyleItem objectArray, "solid"
         break
      case "1,1"
         _AddStyleItem objectArray, "dotted"
         break
      case "4,2"
         _AddStyleItem objectArray, "dashed"
         break
   end switch
   --
   if propArray ["linesize"] > 1 then
      _AddStyleItem objectArray, "bold"
   end if
end dot_SetObjectArrayStyle

private command _AddStyleIf ifItem, ifValue, addItem, propArray, @objectArray
   if propArray [ifItem] is ifValue then
      _AddStyleItem objectArray, addItem
   end if
end _AddStyleIf

private command _AddStyleItem @objectArray, addItem
   get objectArray ["style"]
   put item_Add (addItem, it) into objectArray ["style"]
end _AddStyleItem

function dot_ShapeFromStyle pArray
   put pArray ["style"] into graphicStyle
   switch graphicStyle
      case "roundrect"
      case "rectangle"
         return "rectangle"
         return "box"
      case "regular"
         put pArray ["polySides"] - 2 into itemNum
         return item itemNum of "triangle,diamond,pentagon,hexagon,septagon,octagon"
      case "oval"
         -- ellipse,circle,
         put pArray ["rect"] into pRect
         put item 3 of pRect - item 1 of pRect into pWidth
         put item 4 of pRect - item 2 of pRect into pHeight
         if pWidth = pHeight then
            return "circle"
         else
            return "ellipse"
         end if
      default
         return graphicStyle
   end switch
end dot_ShapeFromStyle

function dot_ShapeToStyle
   switch someShape
      case "triangle"
         set the style of gView to regular
         set the polysides of gView to 3
         set the angle of gView to 270
         break
      case "diamond"
         set the style of gView to regular
         set the polysides of gView to 4
         set the angle of gView to 0
         break
      case "pentagon"
         set the style of gView to regular
         set the polysides of gView to 5
         set the angle of gView to 53
         break
      case "hexagon"
         set the style of gView to regular
         set the polysides of gView to 6
         set the angle of gView to 0
         break
      default
         set the style of gView to someShape
   end switch
end dot_ShapeToStyle

function dot_GetColour sColour
   put the colornames into cNames
   if sColour is among the lines of cNames then
      return sColour
   end if
   
   put colour_RgbToName (sColour) into namedColour
   if namedColour = sColour then
      put colour_RgbToHex (sColour) into hexColour
      return hexColour
   else
      return namedColour
   end if
end dot_GetColour

command dotArray_Construct linkArray, @dotArray, pGraphStyle, pGraphName, pDefaultShape, pFile, pBgColour, pConcentrate, pDefSection 
   if pGraphName is empty then put "Link Array" into pGraphName
   --
   put dot_FromLinkArray (linkArray, pGraphStyle, pBgColour, pConcentrate, pDefaultShape, pDefSection, pGraphName) into dotText
   put dot_CreateArray (dotText, pFile) into dotArray
   --
   return dotText
end dotArray_Construct

function dot_CreateArray dotText, pDotFile
   dot_SetText pDotFile, dotText
   put dot_CreateText (dotText, "json", pDotCommand, pDotFile) into dotJSON
   --
   if word 1 of dotJSON = "Warning:" then
      delete line 1 of dotJSON
   end if
   --
   put json_ToArray (dotJSON) into dotArray
   return dotArray
end dot_CreateArray

command dot_CleanJSON @dotJSON
   -- hack
   get token 1 of dotJSON
   if it = "Error" then breakpoint
   --
   if char 1 of dotJSON is not "{" then
      put offset ("{", dotJSON) into charNum
      delete char 1 to (charNum - 1) of dotJSON
      -- put textDecode (dotJSON, "UTF-8") into dotJSON -- strips funny chars
   end if
end dot_CleanJSON

getprop dot_ScreenRect
   put the screen_Rect of the target into sRect
   --
   put dot_BoundingRect(sRect) into bbRect
   return bbRect
end dot_ScreenRect

function dot_BoundingRect sRect
   constant DPI = 96
   put item 3 of sRect - item 1 of sRect into sWidth
   put item 4 of sRect - item 2 of sRect into sHeight
   --
   put sWidth * 72 / DPI into dotWidth
   put sHeight * 72 / DPI into dotHeight
   --
   put 0,0,dotWidth,dotHeight into bbRect
   rect_Normalise sRect
   return bbRect
end dot_BoundingRect

function dotArray_Get dotFile, pGraphStyle, pDontCreateJsonFile, pClean
   if there is not a file dotFile then return empty
   --
   put dotJson_FromDotFile (dotFile, pGraphStyle) into dotJSON
   if pClean is true then
      dot_CleanJSON dotJSON
   end if
   if pDontCreateJsonFile is not true then
      dotJson_Set dotFile, dotJSON
   end if
   --
   put json_ToArray (dotJSON) into dotArray
   return dotArray
end dotArray_Get

command dotArray_Set dotFile, dotArray
   put json_FromArray (dotArray) into dotJSON
   put dotJson_File (dotFile) into dotJsonFile
   dot_SetText dotJsonFile, dotJSON
   return dotJSON
end dotArray_Set

function dotJson_FromDotFile dotFile, pGraphStyle, pClean
   put dot_LayoutEngine (pGraphStyle) into dotCommand
   gv_DoShell dotFile, dotCommand, "json"
   put the result into dotJSON
   if pClean is true then
      dot_CleanJSON dotJSON
   end if
   return dotJSON
end dotJson_FromDotFile

command dotJson_Create dotFile, pGraphStyle
   put dotJson_FromDotFile (dotFile, pGraphStyle) into dotJSON
   --
   dotJson_Set dotFile, dotJSON
   return dotJsonFile
end dotJson_Create

function dotArray_FromJsonFile dotJsonFile
   put dot_GetText (dotJsonFile) into dotJSON
   put json_ToArray (dotJSON) into dotArray
   return dotArray
end dotArray_FromJsonFile

function dotJson_Get dotFile
   put dotJson_File (dotFile) into dotJsonFile
   put dot_GetText (dotJsonFile) into dotJSON
   return dotJSON
end dotJson_Get

command dotJson_Set dotFile, dotJSON
   put dotJson_File (dotFile) into dotJsonFile
   dot_SetText dotJsonFile, dotJSON
   return dotJsonFile
end dotJson_Set

function dotJson_File dotFile
   set the itemdelimiter to "."
   put json into item -1 of dotFile
   return dotFile
end dotJson_File

command dot_SplitAndSaveGraphs dotGraphs, dotFolder
   put dot_ConstructNamedGraphArray (dotGraphs) into namedGraphArray
   repeat for each key gName in namedGraphArray
      put gName & ".gv" into shortFile
      put dotFolder & shortFile into subGraphFile
      --
      put namedGraphArray [gName] into dotText
      dot_SetText subGraphFile, dotText
   end repeat
   return namedGraphArray
end dot_SplitAndSaveGraphs

function dotArray_FindNodeArray nodeID, dotArray
   put dotArray ["objects"] into objectData
   put indexArray_Find (objectData, "_gvid", nodeID) into indexNum
   put objectData [indexNum] into nodeArray
   return nodeArray
end dotArray_FindNodeArray

function dot_ConstructNamedGraphArray dotGraphs
   put "}" & CR & "digraph " into charsToFind
   repeat
      put offset (charsToFind, dotGraphs) into charNum
      if charNum = 0 then exit repeat
      
      put char 1 to charNum of dotGraphs into subGraph
      delete char 1 to (charNum + 1) of dotGraphs
      --
      put word 2 of line 1 of subGraph into subGraphName
      put subGraph into namedGraphArray [subGraphName]
   end repeat
   --
   put word 1 to -1 of dotGraphs into subGraph
   put word 2 of line 1 of subGraph into subGraphName
   if subGraphName is not empty then
      put subGraph into namedGraphArray [subGraphName]
   end if
   return namedGraphArray
end dot_ConstructNamedGraphArray

function dotArray_GetSubraphArray dotArray
   put dotArray ["_subgraph_cnt"] into subgraphNum
   put dotArray ["objects"] into objectData
   repeat with indexNum = 1 to item 2 of the extents of objectData
      put objectData [indexNum] into objectArray
      put objectArray ["nodes"] into nodeArray
      if nodeArray is not an array then next repeat
      
      put objectArray ["name"] into subgraphName
      if subgraphName begins with "cluster" then
         put objectArray ["_gvid"] into subgraphID
         put objectArray ["bb"] into bb
         --
         -- put subgraphName into subGraphData ["subgraphIDs"][subgraphID]["name"]
         -- put bb into subGraphData ["subgraphIDs"][subgraphID]["bb"]
         put objectArray into subGraphData ["subgraphs"][subgraphID]
         --
         repeat with nodeNum = 1 to item 2 of the extents of nodeArray
            put nodeArray [nodeNum] into subgraphNodeID
            -- put subgraphID into subGraphData [subgraphNodeID]["subgraphID"]
            put objectArray into subGraphData ["nodeIDs"][subgraphNodeID]["objectArray"]
         end repeat
      end if
   end repeat
   return subGraphData
end dotArray_GetSubraphArray

private command _SetTemplateGroup dotGroup
   put the template_Margin of dotGroup into tMargin
   --
   -- set the lockloc of the templategroup to true
   set the margins of the templategroup to tMargin
   set the borderwidth of the templategroup to TemplateBorderWidth
   set the showborder of the templategroup to true
   set the opaque of the templategroup to true
   set the threeD of the templategroup to false
   set the backgroundcolor of the templategroup to "red"
end _SetTemplateGroup


--> Dot | Create | Array
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
   -- put the loc of tGroup into oLoc
   put the rect of tGroup into oRect
   --
   -- _DeleteDotGraphics tGroup
   _DeleteDotNodes tGroup
   --
   if dotArray is an array then -- for safety?
      set the lockloc of tGroup to true
      --
      put _GetBackgroudRect (dotArray) into bbRect
      set the bb_Rect of tGroup to bbRect
      --
      put dotArray_GetSubraphArray (dotArray) into subGraphData
      _CreateGroups subGraphData, tGroup
      _CreateEdges dotArray, tGroup, edgeWidth
      _CreateObjects dotArray, tGroup, subGraphData
      --
      set the lockmessages to true
      set the dot_Array of tGroup to dotArray
      set the lockmessages to false
   end if
   --
   -- set the loc of tGroup to oLoc
   dispatch "Layoutcontrol" to tGroup with oRect -- should not need
   unlock screen
   return bbRect
end dot_Array

command dotArray_CreateGraphic nArray, dotGroup, nodeIDArray
   put view_GetTemplateBehavior("View|Node|Graphic") into bObject
   
   put nArray ["_gvid"] into nodeID
   put nArray ["name"] into oName
   put nArray ["label"] into oLabel
   if oLabel = "\N" then
      put empty into oLabel
   else
      replace "\n" with CR in oLabel
   end if
   --
   put nArray ["shape"] into nShape
   put nArray ["style"] is "filled" into isOpaque
   --
   reset templateGraphic
   set the opaque of the templateGraphic to true
   set the showName of the templateGraphic to true
   set the behavior of the templateGraphic to bObject
   --
   put nodeIDArray [nodeID]["objectArray"] into objectArray
   if objectArray is an array then
      put objectArray ["name"] into clusterName
      create graphic oName in group clusterName of dotGroup
   else
      create graphic oName in dotGroup
   end if
   put it into nodeObject
   --
   set the label of nodeObject to oLabel
   --
   put _CreateProps (nShape, nArray) into pArray
   set the node_Properties of nodeObject to pArray
   --
   set the dot_ObjectArray of nodeObject to nArray
   return nodeObject
end dotArray_CreateGraphic

private function _GetBackgroudRect dotArray
   put dotArray ["bb"] into bb
   put trunc (item 3 of bb) into sWidth
   put trunc (item 4 of bb) into sHeight
   -- put rect_FromWidthAndHeight (cRect, sWidth, sHeight) into bbRect
   put 0,0,sWidth,sHeight into bbRect
   --
   return bbRect
end _GetBackgroudRect

private command _CreateObjects dotArray, dotGroup, subGraphData
   set the showName of templateGraphic to true
   --
   put subGraphData ["nodeIDs"] into nodeIDArray
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
            dotArray_CreateGraphic nArray, dotGroup, nodeIDArray
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

command _TweakEdgePoints @edgePoints
   -- hack
   get line -2 of edgePoints
   if it = line -1 of edgePoints then
      delete line -1 of edgePoints
   end if
   get line 2 of edgePoints
   if it = line 1 of edgePoints then
      delete line 1 of edgePoints
   end if
end _TweakEdgePoints

private command _CreateEdge edgeArray, dotGroup, pEdgeWidth
   if pEdgeWidth is not a number then
      put 4 into pEdgeWidth
   end if
   --
   -- put the edge_OriginalPoints [edgeArray] of dotGroup into edgePoints
   put the top_Down of dotGroup into topDown
   put the bb_Rect of dotGroup into bbRect
   put dotArray_GetOriginalEdgePoints (edgeArray, bbRect, topDown) into edgePoints
   -- _TweakEdgePoints edgePoints
   --
   put dotArray_ConstructEdgeName (edgeArray) into edgeName
   --
   reset templateGraphic
   --
   put edgeArray ["arrowhead"] into aHead --"vee"
   --
   switch edgeArray ["dir"]
      case "back"
         set the startArrow of the templateGraphic to true
         break
      default
         set the endArrow of the templateGraphic to true
   end switch
   --
   switch edgeArray ["style"]
      case "invis"
         set the visible of the templateGraphic to false
         break
      default
   end switch
   --
   put edgeArray ["_draw_"][1]["color"] into aColour
   set the backgroundcolor of the templateGraphic to aColour
   --
   set the style of the templateGraphic to curve
   set the lineSize of the templateGraphic to pEdgeWidth
   set the showName of the templateGraphic to false
   --
   lock screen
   create graphic edgeName in dotGroup
   put it into edgeObject
   set the points of edgeObject to edgePoints
   set the uGraphic ["edge_Array"] of edgeObject to edgeArray
   unlock screen
   --
   reset templateGraphic
   return edgeObject
end _CreateEdge

private command _CreateGroups subGraphData, dotGroup
   put subGraphData ["subgraphs"] into subGraphArray
   --
   put item 2 of the extents of subGraphArray into maxNum -- not starting from 1
   repeat for each key gNum in subGraphArray
      put subGraphArray [gNum]["name"] into gName
      put subGraphArray [gNum]["bb"] into gRect
      --
      _SetTemplateGroup dotGroup
      create group gName in dotGroup
      put it into gObject
      set the rect of gObject to gRect
   end repeat
   reset templategroup
end _CreateGroups

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
      if exists (control id nodeID of tGroup) then
         delete control id nodeID of tGroup
      end if
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
   -- put node_ConstructPropertyArray (nShape, nArray) into pArray
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
   
   put nArray ["fontcolor"] into fColour
   put nArray ["fontname"] into fName
   put nArray ["fontsize"] into fSize
   put fName into pArray ["textFont"]
   put fSize into pArray ["textSize"]
   put fColour into pArray ["foregroundColor"]
   --
   put nArray ["color"] into nColour
   put nArray ["fillcolor"] into bColour
   -- put nColour into pArray ["foregroundColor"]
   put bColour into pArray ["backgroundColor"]
   --
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

function dotArray_ConstructEdgeName edgeArray
   put "Edge" && edgeArray ["_gvid"] into edgeName
   return edgeName
end dotArray_ConstructEdgeName


--> DotArray
-
function dotArray_FromLinkArray linkArray, pGraphStyle, pGraphName, pFile, pDefaultShape
   if pDefaultShape is empty then put "rectangle" into pDefaultShape
   --
   dotArray_Construct linkArray, dotArray, pGraphStyle, pGraphName, pDefaultShape, pFile
   put the result into dotText
   return dotArray
end dotArray_FromLinkArray


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

function item_Add someItems, someList, pPartLine, pSkipLines
   list_Add someItems, someList, pPartLine, pSkipLines
   return someList
end item_Add

command list_Add someItems, @someList, pPartLine, pSkipLines
   set the wholematches to (pPartLine is empty)
   repeat for each item someItem in someItems
      if someItem is empty then next repeat
      put itemoffset (someItem, someList, pSkipLines) into itemNum
      if itemNum is 0 then
         put the number of items of someList into maxItem
         put maxItem + 1 into itemNum
         put someItem into item itemNum of someList
      else
         add pSkipLines to itemNum
         put itemNum & comma after itemNums
      end if
   end repeat
   delete char -1 of itemNums
   return itemNums
end list_Add
