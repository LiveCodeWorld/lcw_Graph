script "lib_DotConstruct"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_DotConstruct
type: library
version: 0.1

/*Some help*/


--> Working on
-


--> Dot | Construct
-
function dot_FromLinkArray linkArray
   if pGraphName is empty then put "LiveGraph" into pGraphName
   --
   linkArray_IdConstruct linkArray, idLinkArray, idArray
   put linkArray_ConstructGraphData (linkArray, idLinkArray, idArray) into graphData
   put linkArray_ConstructNodeSection (idArray, idLinkArray) into nodeSection
   
   put "digraph" && kwote(pGraphName) && "{" & CR & outline_IncreaseIndent (nodeSection) & CR & "}" into dotText
   --
   return dotText
end dot_FromLinkArray

function dot_FromLinkArray linkArray
   linkArray_IdConstruct linkArray, idLinkArray, idArray
   put linkArray_ConstructGraphData (linkArray, idLinkArray, idArray) into linkData
   put _LinkTypeArray (idArray) into nodeTypeArray
   
   put linkArray_ConstructNodeSection (idArray, idLinkArray, nodeTypeArray) into nodeSection
   --
   put dot_Construct (pOverlayName, nodeSection, graphHeader) into dotText
   return dotText
end dot_FromLinkArray

function linkArray_ConstructNodeSection hIdArray, hLinkArray, modelObject
   -- format defs
   put linkArray_ConstructColourDefs (hIdArray, modelObject) into colourDefs
   
   -- cluster defs
   put hKeyArray_DotNestedObjectClusters (hIdArray, hLinkArray) into clusterDefs
   
   -- node links
   put linkArray_DotNodeLinks (hLinkArray, empty) into linkSection
   
   put colourDefs & CR & CR & clusterDefs into defSection
   if defSection is empty then
      return linkSection
   else
      return defSection & CR & CR & linkSection
   end if
end linkArray_ConstructNodeSection

function linkArray_ConstructColourDefs hIdArray, modelObject
   put _LinkTypeArray (hIdArray) into nodeTypeArray
   --
   repeat for each key handlerType in pNodeTypeArray
      put pNodeTypeArray [handlerType] into nodeIDs
      --
      if nodeIDs is not empty then
         put dot_GetNodeDefs (handlerType, modelObject) into nodeDefs
         put linkArray_ConstructSubGraph (nodeIDs, hIdArray, nodeDefs) & CR after colourDefs
      end if
   end repeat
   return colourDefs
end linkArray_ConstructColourDefs

function linkArray_ConstructSubGraph nodeIDs, idArray, nodeDefs
   put "{" & CR into subGraph
   put tab & nodeDefs & CR after subGraph
   put "}" after subGraph
   return subGraph
end linkArray_ConstructSubGraph

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
   -- linkArray_SetgraphPropertyArray "default_Node", "nodeColour", nodeColour, graphPropertyArray
   -- linkArray_SetgraphPropertyArray "default_Node", "nodeFillColour", nodeFillColour, graphPropertyArray
end dot_SetHandlerProps

function linkArray_ConstructGraphData linkArray, idLinkArray, idArray
   put linkArray into dataArray ["linkArray"]
   put idLinkArray into dataArray ["idLinkArray"]
   put idArray into dataArray ["idArray"]
   put array_ConstructReverseDictionary (idArray) into reversedIdArray
   put reversedIdArray into dataArray ["reverseIdArray"]
   return dataArray
end linkArray_ConstructGraphData

command linkArray_DeconstructGraphData dataArray, @linkArray, @idLinkArray, @idArray, @reversedIdArray
   -- same structure used by overlay_View (stored as local property)
   -- overlayArray = dataArray
   put dataArray ["linkArray"] into linkArray
   put dataArray ["idLinkArray"] into idLinkArray
   put dataArray ["idArray"] into idArray
   put dataArray ["reverseIdArray"] into reversedIdArray
end linkArray_DeconstructGraphData


--> Deps
-
private function _LinkTypeArray hIdArray
   -- this is what splits the nodes into types
   repeat for each key nodeID in hIdArray
      put hIdArray [nodeID] into hKey
      hkey_Deconstruct hKey, handlerName, handlerType, scriptObject, handlerNum
      array_AddToIndex nodeID, handlerType, IdTypeArray
   end repeat
   return IdTypeArray
end _LinkTypeArray
