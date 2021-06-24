script "lib_DotCreate"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DotCreate
type: library
version: 0.1

/*Some help*/


--> Working on
-
command display_LinkArrayGraph linkArray, pFile, pStackLabel
   linkArray_CreateDot linkArray, pFile, pGraphName, pDefSection, pDotPropertyArray
   put the result into svgFile
   display_SVG svgFile, pStackLabel
end display_LinkArrayGraph


--> LinkArray | Construct | ID
-
command linkArray_IdConstruct linkArray, @nodeLinkArray, @nodeIdArray, pKeyStyle
   -- usefull to create simple arrays from complex data.
   -- that is it creates simple numbered nodes 1, 2 etc and stores references to these in arrays.
   local nodeBackArray
   repeat for each key someKey in linkArray
      put linkArray [someKey] into frontLinkArray
      linkArray_Add frontLinkArray, someKey, nodeLinkArray, nodeIdArray, nodeBackArray, pKeyStyle
   end repeat
   return allLinks
end linkArray_IdConstruct

private command linkArray_Add newLinkArray, someNode, @hLinkArray, @hIdArray, @backArray, pKeyStyle
   -- modified to work with nested newLinkArray
   put linkarray_RenameKeys (someNode, hIdArray, backArray, pKeyStyle) into nodeID
   put linkarray_RenameKeys (newLinkArray, hIdArray, backArray, pKeyStyle) into linkIDs   
   array_AddToIndex linkIDs, nodeID, hLinkArray
   return the result
end linkArray_Add

function linkarray_RenameKeys someKeyArray, @idArray, @keyArray, pKeyStyle
   -- modified to use nested someKeyArray instead of just an index of keys
   -- a general technique for building incremental unique ids and their translations (as in a database id)
   -- for a single key this returns the (new) or existing simlified translation
   -- while building the two way arrays
   -- will also add multiple keys if needed (as with childNodes)
   
   if someKeyArray is an array then -- quick hack
      put keys (someKeyArray) into someKeys
   else
      put someKeyArray into someKeys
   end if
   
   repeat for each line someKey in someKeys
      -- at moment someKey is an old stylye hKey
      put keyArray [someKey] into simpleID
      if simpleID is empty then
         -- not already indexed (work out new incremental ID and add to idArray and keyArray)
         put the number of lines of keys(idArray) + 1 into keyNumber
         switch pKeyStyle
            case "hName"
               hkey_Deconstruct someKey, hName, hType, hObject, hNum
               put hName into simpleID
               break
            case "short hkey"
               hkey_Deconstruct someKey, hName, hType, hObject, hNum
               put quote & hType && hName & quote into simpleID
               break
            case "number"
               put keyNumber into simpleID
               break
            default
               put "n" & keyNumber into simpleID
         end switch
         put simpleID into keyArray [someKey]
         put someKey into idArray [simpleID]
      end if
      put simpleID & CR after simpleIDs
   end repeat
   delete char -1 of simpleIDs
   return simpleIDs
end linkarray_RenameKeys


--> LinkArray | Display
-
function linkArray_ConstructDot linkArray, pDotMetadataArray, pDefSection, pGraphController
   set the cursor to watch
   put pDotMetadataArray ["dot_HeaderArray"] into dotPropertyArray
   put pDotMetadataArray ["graph_PropertyArray"] into graphPropertyArray
   
   put graphPropertyArray ["overlay_Name"] into graphName
   if graphName is empty then put "linkArray_ConstructDot" into graphName
   put graphPropertyArray ["overlay_Size"] into graphSize
   put graphPropertyArray ["overlay_Style"] into graphStyle
   put graphPropertyArray ["overlay_UseInches"] into graphUseInches
   --
   put dot_ConstructHeader (graphSize, dotPropertyArray, graphStyle, graphUseInches) into graphHeader
   --
   put linkArray_DotNodeLinks (linkArray) into linkSection
   put linkArray_ConstructLinkSection (linkArray, pNodeTypeArray, pClusterArray, pGraphController) into nodeSection
   --
   if pDefSection is empty then
      put linkSection into nodeSection
   else
      put pDefSection & CR & CR & linkSection into nodeSection
   end if
   put dot_Construct (graphName, nodeSection, graphHeader) into dotText
   --
   return dotText
end linkArray_ConstructDot


--> Dot | Create
-
command linkArray_CreateDot linkArray, pFile, pGraphName, pDefSection, pDotPropertyArray
   local graphSize
   
   dot_ConstructPropertyArray pDotPropertyArray, false, true, true, false, "BT"
   put dot_ConstructHeaderBase (graphSize, pDotPropertyArray, "hierarchy") into graphHeader
   put linkArray_DotNodeLinks (linkArray) into linkSection
   put linkArray_ConstructLinkSection (linkArray) into nodeSection
   if pDefSection is empty then
      put linkSection into nodeSection
   else
      put pDefSection & CR & CR & linkSection into nodeSection
   end if
   put dot_Construct (pGraphName, nodeSection, graphHeader) into dotText
   --
   dot_CreateGraph dotText, pFile
   --
   return svgFile
end linkArray_CreateDot


--> LinkArray
-
function linkArray_ConstructLinkSection linkArray, pNodeTypeArray, pClusterArray, pGraphController
   -- all from arrays (with an optional script override in pGraphController)
   -- cloned from "hKeyArray_ConstructNodeSection", see also "hKeyArray_DotNestedObjectClusters"
   
   -- node defs
   if pNodeTypeArray is an array then put linkArray_ConstructDefSection (nodeTypeArray, pGraphController) into nodeDefs
   if pClusterArray is an array then put linkArray_ConstructClusterDefs (clusterArray, pGraphController) into clusterDefs  -- specific (construct object clusters)
   put nodeDefs & CR & CR & clusterDefs into defSection
   
   -- node links
   put linkArray_DotNodeLinks (linkArray) into linkSection
   if defSection is empty then
      return linkSection
   else
      return defSection & CR & CR & linkSection
   end if
end linkArray_ConstructLinkSection

function linkArray_ConstructDefSection nodeTypeArray, pGraphController
   -- stub
   return empty
end linkArray_ConstructDefSection

function linkArray_ConstructClusterDefs clusterArray, pGraphController
   -- cloned from "hKeyArray_DotNestedObjectClusters"
   -- needs a recursive function to turn a nested array into a nested cluster def in dot
   return empty -- array_ToXml 
end linkArray_ConstructClusterDefs

function linkArray_DotNodeLinks linkArray, pNodeIDs
   if pNodeIDs is not empty then
      breakpoint -- not done
   end if
   
   -- this version uses nested array values
   repeat for each key someKey in linkArray
      put linkArray [someKey] into someLinkArray
      if the number of words of someKey > 1 then put kwote(someKey) into someKey
      
      if someLinkArray is an array then
         repeat for each key someLink in someLinkArray
            if the number of words of someLink > 1 then put kwote(someLink) into someLink
            put someKey && "->" && someLink & ";" & CR after linkSection
         end repeat
      else
         put someLinkArray into someLinks
         repeat for each line someLink in someLinks
            if the number of words of someLink > 1 then put kwote(someLink) into someLink
            put someKey && "->" && someLink & ";" & CR after linkSection
         end repeat
      end if
   end repeat
   delete char -1 of linkSection
   return linkSection
end linkArray_DotNodeLinks

--  function linkArray_DotNodeLinks linkArray, pNodeIDs
-- without translating ids
if pNodeIDs is empty then put keys(linkArray) into pNodeIDs
repeat for each line someKey in pNodeIDs
   put linkArray [someKey] into someLinks
   repeat for each line someLink in someLinks
      put someKey && "->" && someLink & ";" & CR after linkSection
   end repeat
end repeat
delete char -1 of linkSection
return linkSection
end linkArray_DotNodeLinks

function dot_Construct graphName, nodeSection, graphHeader
   put graphHeader into dotText
   put CR & nodeSection after dotText
   --
   put "digraph" && kwote(graphName) && "{" & CR into dsaf
   put outline_IncreaseIndent (dotText) & CR & "}" after dotText
   return word 1 to -1 of dotText
end dot_Construct

command dot_CreateGraph dotText, pFile
   file_CreateText dotText, pFile
   put the result into dotFile
   --
   put dotFile & ".svg" into svgFile
   dot_Render dotFile, svgFile
   --
   return svgFile
end dot_CreateGraph

command dot_Render dotFile, svgFile, dotCommand, pImageFormat
   put "dot" into dotCommand
   put dotCommand into someShell
   if pImageFormat is empty then put "svg" into pImageFormat
   -- shell_BashParamEscape dotFile
   -- shell_BashParamEscape svgFile
   
   put space & kwote (dotFile) after someShell
   put space & "-T" & pImageFormat after someShell
   put space & "-o" && kwote (svgFile) after someShell
   --
   put shell (someShell) into gvResult
   return gvResult
end dot_Render

function dot_ConstructHeaderBase graphSize, dotPropertyArray, graphStyle, pUseInches  
   dot_DeconstructPropertyArray dotPropertyArray, overlap, concentrate, splines, cluster, direction, dotOrder, defaultShape, defaultUrl
   put the result into dotPropertyArray
   put CR into endChar
   
   if pUseInches is not false then
      -- think there is a bug here (graphs too large)
      put dot_RectFromSize (graphSize) into bbRect
      put dot_GraphInchSize (bbRect, true) into inchSize
      if inchSize is not empty then
         put "size=" & kwote(inchSize) & endChar after graphHeaderBase
      end if
   else
      put dot_RectFromSize (graphSize) into bbRect
      if bbRect is not empty then
         put "bb=" & kwote(bbRect) & endChar after graphHeaderBase
      end if
   end if
   
   -- if overlap is empty then put false into overlap
   if graphStyle is not "hierarchical"  then
      if overlap is not empty then put "overlap=" & overlap & endChar after graphHeaderBase
      
      if dotOrder is not empty then put  "ordering=" & dotOrder & endChar after graphHeaderBase
      
      if concentrate is not empty then
         put "concentrate=" & concentrate & endChar after graphHeaderBase
      end if
   end if
   
   -- if cluster is "none" then
   if cluster is "none" and graphStyle = "hierarchical" then
      put "clusterrank=" & cluster & endChar after graphHeaderBase
   end if
   
   if splines is not empty then put "splines=" & splines & endChar after graphHeaderBase
   if direction is not empty then put "rankdir=" & direction & endChar after graphHeaderBase
   
   repeat for each key someKey in dotPropertyArray
      put dotPropertyArray [someKey] into someValue
      put someKey & "=" & kwote(someValue) & CR after graphHeaderBase
   end repeat
   
   delete char -1 of graphHeaderBase
   return graphHeaderBase
end dot_ConstructHeaderBase

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
      default -- "none"
         if graphSize is a rect then
            put dot_BboxSize (graphSize) into someRect
            return someRect
         else
            return empty
         end if
   end switch 
end dot_RectFromSize

function dot_BboxSize someRect
   put item 3 of someRect - item 1 of someRect into someWidth
   put item 4 of someRect - item 2 of someRect into someHeight
   put 0,0,someWidth,someHeight into someRect
   return someRect
end dot_BboxSize

command dot_ConvertToInches @pixelSize, screenRez
   -- was "dot_ConvertSizeToInches"
   if screenRez is empty then put 96 into screenRez
   set the numberformat to "0.0000"
   repeat with itemNum = 1 to the number of items of pixelSize
      put item itemNum of pixelSize into someNumber
      put someNumber / screenRez  into item itemNum of pixelSize
   end repeat
end dot_ConvertToInches

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


--> Private
-
private command dot_ConstructPropertyArray @propertyArray, overlap, concentrate, splines, cluster, direction, dotOrder, defaultShape, defaultUrl
   -- wa "dot_ConstructHeaderArray"
   put overlap into propertyArray ["overlap"]
   put concentrate into propertyArray ["concentrate"]
   put splines into propertyArray ["splines"]
   put cluster into propertyArray ["cluster"]
   put direction into propertyArray ["direction"]
   put dotOrder into propertyArray ["dotOrder"]
   put defaultShape into propertyArray ["defaultShape"]
   put defaultUrl into propertyArray ["defaultUrl"]
end dot_ConstructPropertyArray

private command dot_DeconstructPropertyArray pDotPropertyArray, @overlap, @concentrate, @splines, @cluster, @direction, @dotOrder, @defaultShape, @defaultUrl
   put pDotPropertyArray ["graphRect"] into graphRect
   put pDotPropertyArray ["overlap"] into overlap
   put pDotPropertyArray ["concentrate"] into concentrate
   put pDotPropertyArray ["splines"] into splines
   put pDotPropertyArray ["cluster"] into cluster
   put pDotPropertyArray ["direction"] into direction
   put pDotPropertyArray ["dotOrder"] into dotOrder
   put pDotPropertyArray ["defaultShape"] into defaultShape
   put pDotPropertyArray ["defaultUrl"] into defaultUrl
end dot_DeconstructPropertyArray

private function outline_IncreaseIndent someOsSection, byIndentLevel, indentString
   if indentString is empty then put tab into indentString
   if byIndentLevel is not a number then put 1 into byIndentLevel
   if byIndentLevel = 0 then return someOsSection
   if byIndentLevel < 0 then
      return outline_DecreaseIndent (someOsSection, abs(byIndentLevel))
   end if
   put text_RepeatString (indentString, byIndentLevel) into indentWhiteSpace
   repeat with ii = 1 to the number of lines of someOsSection
      put indentWhiteSpace before line ii of someOsSection
   end repeat
   return someOsSection
end outline_IncreaseIndent

private function outline_DecreaseIndent someOsSection, byIndentLevel
   if byIndentLevel = 0 then return someOsSection
   repeat with ii = 1 to the number of lines of someOsSection
      put line ii of someOsSection into osTitle
      repeat byIndentlevel
         if char 1 of osTitle is tab then
            delete char 1 of osTitle
         else
            exit repeat
         end if
      end repeat
      put osTitle into line ii of someOsSection
   end repeat
   return someOsSection
end outline_DecreaseIndent

private command file_CreateText someText, pFile
   if pFile is empty then put the tempname into pFile
   --
   put folder_Above (pFile) into someFolder
   folder_CreateNested someFolder
   put someText into url ("file:" & pFile)
   return pFile
end file_CreateText

private function folder_Above fileOrFolder
   set the itemdelimiter to "/"
   if char -1 of fileOrFolder is "/" then delete char -1 of fileOrFolder
   delete last item of fileOrFolder
   if fileOrFolder is empty then 
      return "."
   else
      return fileOrFolder & "/"
   end if
end folder_Above

private command folder_CreateNested someFolder
   if there is a folder someFolder then return empty   
   set the itemdelimiter to "/"
   repeat with itemNum = 2 to the number of items of someFolder
      put item 1 to itemNum of someFolder & "/" into testFolder
      if there is a folder testFolder then next repeat
      create folder testFolder
   end repeat
   text_AddTrailing someFolder, slash
   return someFolder
end folder_CreateNested

private function kwote someText, pQuoteChar
   if pQuoteChar is empty then put quote into pQuoteChar
   return pQuoteChar & someText & pQuoteChar
end kwote

private command text_AddTrailing @someText, someChar
   if char -1 of someText is not someChar then
      put someChar after someText
   end if
end text_AddTrailing

private function text_RepeatString someString, repeatNum
   repeat repeatNum
      put someString after repeatString
   end repeat
   return repeatString
end text_RepeatString
