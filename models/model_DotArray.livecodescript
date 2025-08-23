script "model_DotArray"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_DotArray
type: model
version: 0.1


--> Working on
-

--> Dot
-
function dot_ConstructHeader graphSize, pDotArray, graphStyle, pUseInches
   -- see dotArray_ConstructHeader
   put _StartDotGraph (pDotArray) into graphHeader
   --
   put dot_ConstructHeaderBase (graphSize, pDotArray, graphStyle, pUseInches) into graphHeaderBase
   line_Indent graphHeaderBase
   put graphHeaderBase & CR after graphHeaderBase
   
   delete last char of graphHeader
   return graphHeader
end dot_ConstructHeader

function dot_FromArray dotArray, pRemovePos, pTabChars
   if pTabChars is empty then put tab into pTabChars
   local headerSection, graphArray, defaultNodeArray, graphName
   
   ## Prepare
   dotArray_SetHeaderArrays dotArray, graphArray, defaultNodeArray, graphName
   put _HeaderKeyArray (graphArray, defaultNodeArray) into headerKeyArray
   
   ## Graph and default node sections
   put _HeaderAndDefaultNodeSections (graphArray, defaultNodeArray) into headerSection
   put _StartDotGraph (dotArray) into dotText
   if headerSection is not empty then
      line_Indent headerSection, pTabChars
      put headerSection & CR&CR after dotText
   end if
   
   ## Node and subgraph sections
   put dotArray_ConstructNodeSection (dotArray, headerKeyArray, pRemovePos, pTabChars) into nodeSection
   line_Indent nodeSection, pTabChars
   put nodeSection & CR after dotText
   
   ## Edge Connections
   put CR after dotText
   put _ConstructEdgeSection (dotArray, headerKeyArray, pRemovePos, pTabChars) into edgeSection
   put edgeSection & CR after dotText
   
   put "}" after dotText
   return dotText
end dot_FromArray


--> DotArray
-
function dotArray_ConstructNodeSection dotArray, headerKeyArray, pRemovePos, pTabChars
   put dotArray ["objects"] into objectData
   repeat with indexNum = 1 to item 2 of the extents of objectData
      put objectData [indexNum] into nodeArray
      --
      if nodeArray ["nodes"] is an array then
         put indexNum & comma after subgraphNodes
      else
         put empty into gIndexArray [indexNum]
      end if
   end repeat
   delete char -1 of subgraphNodes
   
   if subgraphNodes is not empty then
      put _ConstructSubgraphSection (subgraphNodes, objectData, headerKeyArray, pRemovePos, pTabChars) into subgraphSection
      put subgraphSection after nodeSection
   end if
   
   _StripSubGraphNodes gIndexArray, subgraphNodes, objectData
   repeat for each key graphIndexNum in gIndexArray
      put objectData [graphIndexNum] into nodeData
      put CR after nodeSection
      put _ConstructNodeLine (nodeData, headerKeyArray, pRemovePos) after nodeSection
   end repeat
   return word 1 to -1 of nodeSection
end dotArray_ConstructNodeSection

function dotArray_HeaderSection dotArray
   local headerSection, graphArray, defaultNodeArray, graphName
   dotArray_SetHeaderArrays dotArray, graphArray, defaultNodeArray, graphName
   put _HeaderAndDefaultNodeSections (graphArray, defaultNodeArray) into defaultNodeSection
   return defaultNodeSection
end dotArray_HeaderSection

private function _HeaderKeyArray graphArray, defaultNodeArray
   union graphArray with defaultNodeArray
   return graphArray
end _HeaderKeyArray

private function _HeaderAndDefaultNodeSections graphArray, defaultNodeArray
   if graphArray is not empty then
      put _HeaderSection ("graph", graphArray) into defaultNodeSection
   end if
   if defaultNodeArray is not empty then
      put CR&CR after defaultNodeSection
      put _HeaderSection ("node", defaultNodeArray) after defaultNodeSection
   end if
   return defaultNodeSection
end _HeaderAndDefaultNodeSections

private function _ConstructSubgraphSection subgraphNodes, objectData, headerKeyArray, pRemovePos, pTabChars
   repeat for each item subgraphIndexNum in subgraphNodes
      put objectData [subgraphIndexNum] into subgraphArray
      --
      put subgraphArray ["bb"] into bbRect
      put subgraphArray ["name"] into subgraphName
      put subgraphArray ["label"] into subgraphLabel
      put subgraphArray ["_gvid"] into subgraphID
      -- other props "fontname" etc
      
      put "subgraph" && subgraphName after subgraphSection
      put pTabChars & "{" & CR after subgraphSection
      
      put subgraphArray ["nodes"] into nodeIndexArray
      repeat with nodeIndexNum = 1 to item 2 of the extents of nodeIndexArray
         put nodeIndexArray [nodeIndexNum] into subgraphNodeGvid
         put indexArray_Find (objectData, "_gvid", subgraphNodeGvid) into foundNum
         put objectData [foundNum] into foundNodeArray
         --
         put pTabChars after subgraphSection
         put _ConstructNodeLine (foundNodeArray, headerKeyArray, pRemovePos) & CR after subgraphSection
      end repeat
      put "}" & CR after subgraphSection
   end repeat
   -- delete char -1 of subgraphSection
   return subgraphSection
end _ConstructSubgraphSection

private function _ConstructNodeLine nodeArray, pHeaderKeyArray, pRemovePos
   put nodeArray ["name"] into nodeName
   if the number of words of nodeName = 1 then
      put nodeName after nodeLine
   else
      put kwote (nodeName) after nodeLine 
   end if
   
   put " [" after nodeLine
   put _ConstructNodeParams (nodeArray, pHeaderKeyArray, pRemovePos) into nodeParams
   put nodeParams after nodeLine
   put "];" after nodeLine
   --
   return nodeLine
end _ConstructNodeLine

function _ConstructEdgeParams edgeArray, pHeaderKeyArray, pRemovePos
   -- put "[pos=" & kwote (pos) & "];" into edgeParams
   get _ConstructNodeParams (edgeArray, pHeaderKeyArray, pRemovePos)
   put "[" & it & "];" into edgeParams
   if it is empty then
      return empty
   else
      return edgeParams
   end if
end _ConstructEdgeParams

private function _ConstructNodeParams nodeArray, headerKeyArray, pRemovePos, pDelimChar
   local nodeLine
   if pDelimChar is empty then put space into pDelimChar
   
   put nodeArray ["_gvid"] into gvid
   put nodeArray ["name"] into nodeName
   delete variable nodeArray ["name"]
   --
   put "n" & (gvid) into nodeID
   --
   repeat for each key sKey in nodeArray
      switch
         case skey is among the items of "tail,head" -- hack for edges
         case char 1 of sKey = "_"
         case headerKeyArray [sKey] is not empty
         case sKey is among the items of "pos,height,width" AND pRemovePos is true
            next repeat
         default
            put nodeArray [sKey] into nodeValue
            _AddNodeParam nodeLine, sKey, nodeValue, pDelimChar
      end switch
   end repeat
   return nodeLine
end _ConstructNodeParams

private function _ConstructEdgeSection dotArray, pHeaderKeyArray, pRemovePos, pTabChars
   if pTabChars is empty then put tab into pTabChars
   --
   put dotArray ["edges"] into edgeData
   put dotArray ["objects"] into objectArray
   repeat with indexNum = 1 to item 2 of the extents of edgeData
      put edgeData [indexNum] into edgeArray
      put _ConstructEdgeLine (edgeArray, objectArray, pHeaderKeyArray, pRemovePos, pTabChars) into edgeLine
      put edgeLine & CR after edgeLines
   end repeat
   delete char -1 of edgeLines
   return edgeLines
end _ConstructEdgeSection

private function _ConstructEdgeLine edgeArray, objectArray, pHeaderKeyArray, pRemovePos, pTabChars
   put edgeArray ["_gvid"] into edgeID
   put edgeArray ["tail"] into tailID
   put edgeArray ["head"] into headID
   put edgeArray ["pos"] into pos
   --
   put indexArray_Find (objectArray, "_gvid", tailID) into tailNum
   put indexArray_Find (objectArray, "_gvid", headID) into headNum
   --
   put objectArray [tailNum] into tailNodeArray
   put tailNodeArray ["name"] into tailName
   put objectArray [headNum] into headNodeArray
   put headNodeArray ["name"] into headName
   --
   put pTabChars into edgeLine
   if the number of words of tailName > 1 then
      put kwote (tailName) after edgeLine
   else
      put tailName after edgeLine
   end if
   put " -> " after edgeLine
   if the number of words of headName > 1 then
      put kwote (headName) after edgeLine
   else
      put headName after edgeLine
   end if
   --
   put _ConstructEdgeParams (edgeArray, pHeaderKeyArray, pRemovePos) after edgeLine
   return edgeLine
end _ConstructEdgeLine

private function _StartDotGraph pDotArray
   if "strict" is among the keys of pDotArray and pDotArray ["strict"] then
      put "strict " after graphHeader
   end if
   if "type" is among the keys of pDotArray and pDotArray["type"] = "graph" then
      put "graph " after graphHeader
   else
      put "digraph " after graphHeader
   end if
   --
   put pDotArray ["name"] into gName
   switch
      case the number of words of gName > 1
         put kwote (gName) after graphHeader
         break
      case gName is not empty
         put gName after graphHeader
         break
   end switch
   --
   put " {" & CR after graphHeader
   return graphHeader
end _StartDotGraph

private command _StripSubGraphNodes @gIndexArray, subgraphNodes, objectData
   repeat for each item subgraphIndexNum in subgraphNodes
      put objectData [subgraphIndexNum]["nodes"] into nodeIndexArray
      repeat with nodeIndexNum = 1 to item 2 of the extents of nodeIndexArray
         put nodeIndexArray [nodeIndexNum] into subgraphNodeGvid
         put indexArray_Find (objectData, "_gvid", subgraphNodeGvid) into gIndexNum
         -- put subgraphNodeGvid + 1 into gIndexNum
         delete variable gIndexArray [gIndexNum]
      end repeat
   end repeat
end _StripSubGraphNodes

private command _AddNodeParam @nodeLine, paramTitle, paramContent, pDelimChar
   if pDelimChar is empty then put space into pDelimChar
   if paramContent is empty then return false
   if nodeLine is not empty then
      put "," & pDelimChar after nodeLine
   end if
   --
   switch
      case paramContent is a boolean
      case paramContent is a number
         put paramTitle & "=" & paramContent after nodeLine
         break
      default
         put paramTitle & "=" & kwote(paramContent) after nodeLine
   end switch
   return true
end _AddNodeParam

private function _HeaderSection sName, headerArray
   local nodeLines
   repeat for each key sKey in headerArray
      put headerArray [sKey] into nodeValue
      _AddNodeParam nodeLines, sKey, nodeValue, CR
   end repeat
   --
   line_Indent nodeLines
   put word 1 to -1 of line 1 of nodeLines into line 1 of nodeLines
   put sName && "[" & nodeLines &CR& "];" into defaultNodeSection
   return defaultNodeSection
end _HeaderSection


--> Elements
-
function dotArray_GraphHeaderArray dotArray
   dotArray_SetHeaderArrays dotArray, graphArray, defaultNodeArray, graphName
   return graphArray
end dotArray_GraphHeaderArray

function dotArray_DefaultNodeArray dotArray
   dotArray_SetHeaderArrays dotArray, graphArray, defaultNodeArray, graphName
   return defaultNodeArray
end dotArray_DefaultNodeArray

command dotArray_SetHeaderArrays dotArray, @graphArray, @defaultNodeArray, @graphName
   put dot_ListGraphProps() into graphProps
   put dotArray ["name"] into graphName
   --
   delete variable dotArray ["edges"]
   delete variable dotArray ["objects"]
   delete variable dotArray ["name"]
   --
   delete variable dotArray ["strict"]
   delete variable dotArray ["xdotversion"]
   
   repeat for each key sKey in dotArray
      if char 1 of sKey = "_" then next repeat
      --
      put dotArray [sKey] into sValue
      if sKey is among the items of graphProps then
         put sValue into graphArray [sKey]
      else
         put sValue into defaultNodeArray [sKey]
      end if
   end repeat
end dotArray_SetHeaderArrays
