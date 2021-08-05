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
      array_AddToIndex nodeID, handlerType, idTypeArray
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

function dot_ConstructDefaultNodeDefs nodeShape, nodeStyle, nodeColour, nodeFillColour, nodeUrl, nodeToolTip
   --   node [URL="http://wiki.architex.tv/\N", shape=box, fontsize=22, fontname=arial, style=filled];
   get dot_ConstructDefLine (empty, nodeShape, nodeStyle, nodeColour, nodeFillColour, "", nodeUrl, nodeToolTip, "")
   return "node [" & it & "];"
end dot_ConstructDefaultNodeDefs

function dot_ConstructDefLine nodeLabel, nodeShape, nodeStyle, nodeColour, nodeFillColour, polyParams, nodeUrl, nodeToolTip, nodeShapeFile
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
   
   dot_AddParamToNodeDef "style", nodeStyle, nodeLine, false
   dot_AddParamToNodeDef "color", nodeColour, nodeLine, false
   dot_AddParamToNodeDef "fillcolor", nodeFillColour, nodeLine, false
   dot_AddParamToNodeDef "URL", nodeUrl, nodeLine
   dot_AddParamToNodeDef "tooltip", nodeToolTip, nodeLine
   dot_AddParamToNodeDef "shapefile", nodeShapeFile, nodeLine
   
   replace "'" with quote in nodeLine
   put merge(nodeLine) into nodeLine
   
   return nodeLine
end dot_ConstructDefLine


--> Dot | Construct
-
function dot_Construct nodeSection, pGraphName, pGraphHeader
   if pGraphName is empty then put "LiveGraph" into pGraphName
   
   put word 1 to -1 of pGraphHeader & CR&CR & nodeSection into dotBit
   --
   put "digraph" && kwote (graphName) && "{" & CR into dotText
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
   
   if someLabel is not empty then put tab & "label=" & kwote(someLabel) & ";" after subGraph
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

command dot_AddParamToNodeDef paramTitle, paramContent, @nodeLine, kwoted
   if paramContent is empty then return false
   --
   if nodeLine is not empty then put "," & space after nodeLine
   if kwoted is not false then 
      put paramTitle & "=" & kwote(paramContent) after nodeLine
   else
      put paramTitle & "=" & paramContent after nodeLine
   end if
   return true
end dot_AddParamToNodeDef

command linkArray_DeconstructGraphData dataArray, @linkArray, @idLinkArray, @idArray, @reversedIdArray
   -- same structure used by overlay_View (stored as local property)
   -- overlayArray = dataArray
   put dataArray ["linkArray"] into linkArray
   put dataArray ["idLinkArray"] into idLinkArray
   put dataArray ["idArray"] into idArray
   put dataArray ["reverseIdArray"] into reversedIdArray
end linkArray_DeconstructGraphData


--> Private
-
