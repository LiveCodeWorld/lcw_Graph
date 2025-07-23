script "lib_DotConstruct"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DotConstruct
type: library
version: 0.1

/*Some help*/


--> Working on
-
command dot_AddParamToNodeDef paramTitle, paramContent, @nodeLine, pKwoted
   if paramContent is empty then return false
   --
   if nodeLine is not empty then put "," & space after nodeLine
   if pKwoted is not false then 
      put paramTitle & "=" & kwote(paramContent) after nodeLine
   else
      put paramTitle & "=" & paramContent after nodeLine
   end if
   return true
end dot_AddParamToNodeDef

command dot_AddStyleToNodeDef @nodeLine, nodeStyle
   if paramContent is empty then return false
   if nodeLine is not empty then put "," & space after nodeLine
   --  
   if kwoted is not false then 
      put "style=" & kwote (nodeStyle) after nodeLine
   else
      put "style=" & nodeStyle after nodeLine
   end if
end dot_AddStyleToNodeDef


--> Dot | Construct | HkeyArray (move)
-
function dot_FromHkeyLinkArray linkArray, pGraphName, pModelObject
   linkArray_IdConstruct linkArray, idLinkArray, idArray
   put _ConstructHkeyNodeSection (idArray, idLinkArray, pModelObject) into nodeSection
   put dot_Construct (nodeSection, pGraphName) into dotText
   return dotText
end dot_FromHkeyLinkArray

private function _ConstructHkeyNodeSection idArray, linkArray, pModelObject
   local colourDefs, clusterDefs, linkSection
   
   -- format defs
   put _ConstructHkeyColourDefs (idArray, pModelObject) into colourDefs
   
   -- cluster defs
   put _ConstructClusterDefs (idArray, linkArray) into clusterDefs
   
   -- node links
   put linkArray_DotNodeLinks (linkArray, empty) into linkSection
   
   put colourDefs & CR & CR & clusterDefs into defSection
   if defSection is empty then
      return linkSection
   else
      return defSection & CR & CR & linkSection
   end if
end _ConstructHkeyNodeSection

private function _ConstructHkeyColourDefs hIdArray, modelObject
   repeat for each key nodeID in hIdArray
      put hIdArray [nodeID] into hKey
      hkey_Deconstruct hKey, handlerName, handlerType, scriptObject, handlerNum
      indexArray_Add nodeID, handlerType, idTypeArray
   end repeat
   --
   repeat for each key handlerType in idTypeArray
      put idTypeArray [handlerType] into nodeIDs
      --
      if nodeIDs is not empty then
         put dot_GetNodeDefs (handlerType, modelObject) into nodeDefs
         put linkArray_ConstructSubGraph (nodeIDs, hIdArray, nodeDefs) & CR after colourDefs
      end if
   end repeat
   return colourDefs
end _ConstructHkeyColourDefs

private function _ConstructClusterDefs idArray, hLinkArray
   -- put hKeyArray_DotNestedObjectClusters (idArray, hLinkArray) into clusterDefs
   return empty
end _ConstructClusterDefs


--> Working on
-
command dot_SetHandlerProps handlerType, @nodeColour, @nodeFillColour, @nodeShape, @nodeStyle
   put "filled" into nodeStyle
   put "" into nodeShape
   
   switch handlerType
      case "m"
         if scriptObject is "Missing" then
            put "white" into nodeColour
            put "white" into nodeFillColour
         else
            put "red" into nodeColour
            put "red" into nodeFillColour
         end if
         break
      case "c"
         put "Green4" into nodeColour
         put "GreenYellow" into nodeFillColour
         break
      case "f"
         put "blue" into nodeColour
         put "LightBlue" into nodeFillColour
         break
      case "g"
         put "white" into nodeColour
         put "grey" into nodeFillColour
         break
      case "s"
         put "white" into nodeColour
         put "grey50" into nodeFillColour
         break
      default
         -- put "yellow" into nodeColour
         -- put "yellow" into nodeFillColour
         put "" into nodeColour
         put "" into nodeFillColour
         break
   end switch
end dot_SetHandlerProps

function dot_GetNodeDefs handlerType, modelObject
   dot_SetHandlerProps handlerType, nodeColour, nodeFillColour, nodeShape, nodeStyle
   put dot_ConstructDefaultNodeDefs (nodeShape, nodeStyle, nodeColour, nodeFillColour) into defaultNodeDefs
   --
   if exists (modelObject) then
      repeat for each line nodeID in nodeIDs
         put the dot_NodeDefLine [nodeID] of modelObject into nodeDefLine
         put tab & nodeDefLine & CR after subGraph
      end repeat
   end if
   delete char -1 of subGraph
   --
   return defaultNodeDefs
end dot_GetNodeDefs

function dot_ConstructNodeDef someNode, nodeLabel, nodeShape, nodeFillColour, nodeUrl, nodeToolTip, nodeStyle, nodeColour
   -- same as dot_ConstructShapeDef
   dot_NormalizeNode someNode
   if nodeStyle is empty then put "filled" into nodeStyle
   if nodeColour is empty then put nodeFillColour into nodeColour
   
   get dot_ConstructNodeParamBit (nodeLabel, nodeShape, nodeStyle, nodeColour, nodeFillColour, "", nodeUrl, nodeToolTip, "")
   put someNode && "[" & it & "];" into nodeDef
   return nodeDef
end dot_ConstructNodeDef


--> Dot | Node Defs | ShapeFile
-
function dot_ConstructShapeDef someNode, nodeLabel, nodeShape, nodeFillColour, nodeUrl, nodeToolTip, nodeStyle, nodeColour
   dot_NormalizeNode someNode
   if nodeStyle is empty then put "filled" into nodeStyle
   if nodeColour is empty then put nodeFillColour into nodeColour
   
   get dot_ConstructNodeParamBit (nodeLabel, nodeShape, nodeStyle, nodeColour, nodeFillColour, "", nodeUrl, nodeToolTip, "")
   put someNode && "[" & it & "];" into nodeDef
   put nodeDef & CR after nodeDefs
   
   delete last char of nodeDefs
   return nodeDefs
end dot_ConstructShapeDef

function dot_ConstructShapeFileDefs shapeFileArray, someWidth, someHeight, fixedSize
   -- shapefile is deprecated
   local nodeDefs
   
   put shapeFileArray ["Node titles"] into defNodes
   repeat for each line someNode in defNodes
      set the cursor to busy
      
      put shapeFileArray [someNode] into nodeShapeFile
      put shapeFileArray [someNode,"url"] into nodeUrl
      put shapeFileArray [someNode,"tooltip"] into nodeToolTip
      
      get dot_ConstructShapeFileDef(someNode, nodeShapeFile, someWidth, someHeight, fixedSize, nodeUrl, nodeToolTip)   
      put nodeDef & CR after nodeDefs
   end repeat
   delete last char of nodeDefs
   return nodeDefs
end dot_ConstructShapeFileDefs

function dot_ConstructShapeFileDef nodeName, nodeShapeFile, someWidth, someHeight, fixedSize, nodeUrl, nodeToolTip
   put "shapeFile" into nodeShape
   put empty into polyParams
   put empty into nodeStyle
   put empty into nodeColour
   put empty into nodeFillColour
   
   put " " into nodeLabel
   get dot_ConstructNodeParamBit(nodeName, nodeLabel, nodeShape, nodeStyle, nodeColour, nodeFillColour, polyParams, nodeUrl, nodeToolTip, nodeShapeFile)
   
   if someWidth is not empty then
      dot_ConvertToInches someWidth
      put ", width=" & someWidth after it
   end if
   if someHeight is not empty then
      dot_ConvertToInches someHeight
      put ", height=" & someHeight after it
   end if
   if fixedsize is not empty then put ", fixedsize=" & fixedsize after it
   
   dot_NormalizeNode nodeName
   put nodeName && "[" & it & "];" into nodeDef
   
   return nodeDef
end dot_ConstructShapeFileDef


--> Dot | Node Defs | Poly
-
function dot_ConstructPolyDefs someNodes, polyStyle, polySkew, polyDistortion, nodeColour, nodeFillColour, nodeUrl, nodeToolTip, regular, peripheries, polyOrientation
   return "Not done yet!"
   
   local nodeDefs
   put "polygon" into nodeShape
   put empty into polyParams
   put empty into nodeShapeFile
   repeat for each line someNode in someNodes
      set the cursor to busy
      dot_NormalizeNode someNode
      
      get dot_ConstructNodeParamBit(someNode, nodeShape, nodeStyle, nodeColour, nodeFillColour, polyParams, nodeUrl, nodeToolTip, nodeShapeFile)
      put someNode && "[" & it & "];" into nodeDef
      put nodeDef & CR after nodeDefs
   end repeat
   delete last char of nodeDefs
   return nodeDefs
end dot_ConstructPolyDefs


--> Dot | Node Defs | Defaults
-
function dot_ConstructDefaultNodeDefs nodeShape, nodeStyle, nodeColour, nodeFillColour, nodeUrl, nodeToolTip
   --   node [URL="http://wiki.architex.tv/\N", shape=box, fontsize=22, fontname=arial, style=filled];
   get dot_ConstructNodeParamBit (empty, nodeShape, nodeStyle, nodeColour, nodeFillColour, "", nodeUrl, nodeToolTip, "")
   return "node [" & it & "];"
end dot_ConstructDefaultNodeDefs

function dot_ConstructDefaultEdgeDefs edgeColour, edgeStyle, arrowhead, edgeWidth
   --  edge [color=cyan, style=solid, arrowhead=none, width=2]
   put dot_ConstructEdgeDefParams(edgeColour, edgeStyle, arrowhead, edgeWidth) into nodeLine
   return "edge [" & nodeLine & "];"
end dot_ConstructDefaultEdgeDefs

function dot_ConstructEdgeDefParams edgeColour, edgeStyle, arrowhead, edgeWidth
   local nodeLine
   dot_AddParamToNodeDef "style", edgeStyle, nodeLine, false
   dot_AddParamToNodeDef "color", edgeColour, nodeLine, false
   dot_AddParamToNodeDef "arrowhead", arrowhead, nodeLine, false
   dot_AddParamToNodeDef "width", edgeWidth, nodeLine, false
   return nodeLine
end dot_ConstructEdgeDefParams

function dot_ConstructDefaultNodeDefs nodeShape, nodeStyle, nodeColour, nodeFillColour, nodeUrl, nodeToolTip
   --   node [URL="http://wiki.architex.tv/\N", shape=box, fontsize=22, fontname=arial, style=filled];
   get dot_ConstructNodeParamBit (empty, nodeShape, nodeStyle, nodeColour, nodeFillColour, "", nodeUrl, nodeToolTip, "")
   return "node [" & it & "];"
end dot_ConstructDefaultNodeDefs


--> Dot | Construct
-
function dot_Construct nodeSection, pGraphName, pGraphHeader
   if pGraphName is empty then put "LiveGraph" into pGraphName
   
   put word 1 to -1 of pGraphHeader & CR&CR & nodeSection into dotBit
   --
   put "digraph" && kwote (pGraphName) && "{" & CR into dotText
   put word 1 to -1 of dotBit into dotBit
   line_Indent dotBit
   put dotBit & CR & "}" after dotText
   return dotText
end dot_Construct

function dot_ConstructCluster someLabel, clusterNum, nodeSection, someRank, someStyle, someColour, fillColour
   put "cluster" & clusterNum into subGraphName
   get dot_ConstructSubgraph (subGraphName, nodeSection, someRank, someStyle, someColour, someLabel, fillColour)
   return it
end dot_ConstructCluster

function dot_ConstructSubgraph subGraphName, nodeSection, someRank, someStyle, someColour, someLabel, fillColour
   put "subgraph" into subGraph
   if subGraphName is not empty then put space & subGraphName after subGraph
   put space & "{" & CR after subGraph
   put dot_SubGraphContents (someLabel, nodeSection, someRank, someStyle, someColour, fillColour) after subGraph
   put CR & "}" after subGraph
   return subGraph
end dot_ConstructSubgraph

function dot_SubGraphContents someLabel, nodeSection, someRank, someStyle, someColour, fillColour
   dot_EscapeQuotes someLabel
   
   -- if someRank is empty then put "same" into someRank
   if someStyle is empty then put "filled" into someStyle
   if someColour is empty then put "grey60" into someColour
   if fillColour is empty then put "grey90" into fillColour
   
   if someLabel is not empty then
      put tab & "tooltip=" & kwote(someLabel) & ";" after subGraph
      put tab & "label=" & kwote(someLabel) & ";" after subGraph
   end if
   if someRank is not empty then put CR & tab & "rank = [[someRank]];" after subGraph
   put CR & tab & "style=[[someStyle]];" after subGraph
   put CR & tab & "color=[[someColour]];" after subGraph
   put CR & tab & "fillcolor=[[fillColour]];" after subGraph
   
   put CR after subGraph
   if nodeSection is not empty then
      line_Indent nodeSection
      put CR & nodeSection after subGraph
   end if
   return merge(subGraph)
end dot_SubGraphContents

function linkArray_ConstructSubGraph nodeIDs, idArray, nodeDefs
   put "{" & CR into subGraph
   line_Indent nodeDefs
   put nodeDefs & CR after subGraph
   put "}" after subGraph
   return subGraph
end linkArray_ConstructSubGraph

command linkArray_DeconstructGraphData dataArray, @linkArray, @idLinkArray, @idArray, @reversedIdArray
   -- same structure used by overlay_View (stored as local property)
   -- overlayArray = dataArray
   put dataArray ["linkArray"] into linkArray
   put dataArray ["idLinkArray"] into idLinkArray
   put dataArray ["idArray"] into idArray
   put dataArray ["reverseIdArray"] into reversedIdArray
end linkArray_DeconstructGraphData
