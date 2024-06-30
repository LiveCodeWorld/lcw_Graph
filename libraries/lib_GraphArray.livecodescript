script "lib_GraphArray"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_GraphArray
type: library
version: 0.1

/*
Moved from lib_Fedwiki
*/


--> Working on
-
function graph_ConstructCluster idArray, linkArray
   return empty
   
   -- seem to be the hack for nested
   -- put overlayArray_DotNestedObjectClusters (idArray, linkArray) into clusterSection
   -- return clusterSection
end graph_ConstructCluster


--> Graph | Array
-
command graph_CreateDotFiles linkArray, pGraphStyle, pDotFile, pGraphTitle
   -- simplified version of "overlayArray_CreateAndDisplayGraph"
   -- creates all the dot and PNG and SVG files
   if linkArray is not an array then return empty
   --
   if pDotFile is empty then
      put lcw_Ask ("Choose a short file name for your dot file...", "bigdata.dot") into shortFile
      put folder_GetDefault() & shortFile into pDotFile
   end if
   set the cursor to watch
   --
   put graph_ConstructDot (linkArray, pGraphStyle, pGraphTitle) into dotText
   --
   dot_SaveTemporaryFile dotText, pDotFile
   if pGraphStyle = "hierarchical" then dot_Flatten pDotFile, 9
   
   set the itemdelimiter to "."
   --
   put pDotFile into imageFile
   put "png" into item -1 of imageFile
   put pDotFile into svgFile
   put "svg" into item -1 of svgFile
   
   shell_BashParamEscape pDotFile
   put pGraphStyle into dotCommand
   dot_GraphStyleToLayoutEngine dotCommand -- converts a graphStyle to a dotCommand
   put dotCommand & space & pDotFile into someShell
   
   put space & "-Tsvg" after someShell
   shell_BashParamEscape svgFile
   put space & "-o" && svgFile after someShell
   
   put space & "-Tpng" after someShell
   get imageFile
   shell_BashParamEscape it
   put space & "-o" && it after someShell
   --
   set the itemdelimiter to "."
   
   put shell (someShell) into gvResult
   put the result into gvResult
   if gvResult is empty then
      return imageFile
   else
      return "error," && gvResult
   end if
end graph_CreateDotFiles

function graph_ConstructDot linkArray, pGraphStyle, pGraphTitle
   local nodeLinkArray, nodeIdArray
   if pGraphStyle is empty then put "hierarchical" into pGraphStyle
   
   linkArray_RemoveSelfLinks linkArray
   linkArray_IdConstruct linkArray, nodeLinkArray, nodeIdArray
   put linkArray_DotNodeLinks (nodeLinkArray) into linkSection
   --
   put graph_ConstructHeader (pGraphStyle) into dotHeader
   put graph_ConstructDefSection (nodeIdArray) into defSection
   put graph_ConstructCluster (nodeIdArray, linkArray) into clusterSection
   
   put dot_TextFromSections (dotHeader, defSection, clusterSection, linkSection, pGraphTitle) into dotText
   return dotText
end graph_ConstructDot

function graph_ConstructHeader pGraphStyle, graphSize
   put empty into graphSize
   put "overlayArray_ConstructDot" into graphTitle
   put dot_ConstructHeaderArray() into pDotHeaderArray
   put false into pUseInches
   put dot_ConstructHeader (graphSize, pDotHeaderArray, pGraphStyle, pUseInches) into dotHeader
   return dotHeader
end graph_ConstructHeader


--> Graph | Def
-
function graph_ConstructDefSection nodeIdArray
   put graph_ConstructGroupStyleArray (nodeIdArray) into dotGroupStyleArray
   put dot_ConstructDefSection (dotGroupStyleArray, nodeIdArray) into defSection
   return defSection
end graph_ConstructDefSection

function graph_ConstructGroupStyleArray nodeIdArray
   return empty
end graph_ConstructGroupStyleArray

command graph_AddToGroupStyleArray @dotGroupStyleArray, nodeType, nodeIDs, someColour, someFillcolor, nodeUrl
   put nodeIDs into dotGroupStyleArray [nodeType]["nodeIDs"]
   graph_SetNodeTypeStyle dotGroupStyleArray, nodeType, someColour, someFillcolor, nodeUrl
end graph_AddToGroupStyleArray

command graph_SetNodeLabel @dotGroupStyleArray, nodeLabel, nodeUrl
   if nodeLabel is not empty then put nodeLabel into dotGroupStyleArray [nodeType]["node_StyleArray"]["label"]
   if nodeUrl is not empty then put nodeUrl into dotGroupStyleArray [nodeType]["node_StyleArray"]["URL"]
end graph_SetNodeLabel

command graph_SetNodeTypeStyle @dotGroupStyleArray, nodeType, someColour, someFillcolor
   put someColour into dotGroupStyleArray [nodeType]["node_StyleArray"]["color"]
   if someFillcolor is not empty then
      put "filled" into dotGroupStyleArray [nodeType]["node_StyleArray"]["style"]
      put someFillcolor into dotGroupStyleArray [nodeType]["node_StyleArray"]["fillcolor"]
   end if
end graph_SetNodeTypeStyle

on graph_SetGroupStyleArray @overlayArray, dotGroupStyleArray
   put dotGroupStyleArray into overlayArray ["metadata"]["dot_GroupStyleArray"]
end graph_SetGroupStyleArray

function graph_GetGroupStyleArray overlayArray
   -- put overlayArray ["data"]["idArray"] into idArray
   put overlayArray ["metadata"]["dot_GroupStyleArray"] into dotGroupStyleArray
   return dotGroupStyleArray
end graph_GetGroupStyleArray



--> Deps
-
command linkArray_RemoveSelfLinks @linkArray, pIsNested
   if pIsNested is empty then
      put linkArray_IsNested (linkArray) into pIsNested
   end if
   
   if pIsNested is not true then
      repeat for each key someKey in linkArray
         put linkArray [someKey] into someLinks
         line_Delete someKey, someLinks
         put someLinks into linkArray [someKey]
      end repeat
   else
      repeat for each key someKey in linkArray
         delete variable linkArray [someKey][someKey]
      end repeat
   end if
end linkArray_RemoveSelfLinks

function linkArray_IsNested linkArray
   put line 1 of keys (linkArray) into testKey
   put linkArray [testKey] is an array into isNested
   return isNested
end linkArray_IsNested

command dot_Flatten dotFile, overlayFlattenNum
   put dot_UnFlatten (dotFile, overlayFlattenNum) into unFlatDotText
   if word 1 of unFlatDotText is among the items of "digraph,graph" then
      file_CreateText unFlatDotText, dotFile
      return unFlatDotText
   else
      return empty
   end if
end dot_Flatten


--> Private 
-
private command line_Delete someLine, @someIndex
   set the wholematches to true
   put lineoffset (someLine, someIndex) into lineNum
   delete line lineNum of someIndex
   return lineNum
end line_Delete
