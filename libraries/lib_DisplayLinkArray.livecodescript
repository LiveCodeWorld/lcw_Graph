script "lib_DisplayLinkArray"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayLinkArray
type: library
version: 0.1

/*Some help*/


--> Working on
-
function linkArray_ConstructDotSimple linkArray, pGraphStyle, pBgColour, pConcentrate, pDefaultShape, pDefSection, pGraphName
   local graphSize, pNodeTypeArray, pClusterArray, dotPropertyArray
   
   if pBgColour is empty then put "lightblue" into pBgColour
   put pBgColour into dotPropertyArray ["bgcolor"]
   --
   put false into overlap
   put true into splines
   put false into cluster
   put "" into dotOrder
   put "" into defaultUrl
   put "" into pDirection
   --
   dot_ConstructPropertyArray dotPropertyArray, overlap, pConcentrate, splines, cluster, pDirection, dotOrder, pDefaultShape, defaultUrl
   put dot_ConstructHeaderBase (graphSize, dotPropertyArray, pGraphStyle) into graphHeader
   dot_AddDefaultNode graphHeader, pDefaultShape
   --
   put linkArray_ConstructLinkSection (linkArray, pNodeTypeArray, pClusterArray) into nodeSection
   put linkArray_DotNodeLinks (linkArray) into linkSection
   if pDefSection is empty then
      put linkSection into nodeSection
   else
      put pDefSection & CR & CR & linkSection into nodeSection
      put word 1 to -1 of nodeSection into nodeSection
   end if
   --
   put dot_Construct (nodeSection, pGraphName, graphHeader) into dotText
   --
   return dotText
end linkArray_ConstructDotSimple


--> OverlayArray
-
command overlayArray_SetData @overlayArray, linkArray
   local dataArray
   overlayArray_ConstructDataArray dataArray, linkArray
   put dataArray into overlayArray ["data"]
end overlayArray_SetData

command overlayArray_ConstructDataArray @dataArray, linkArray
   linkArray_IdConstruct linkArray, idLinkArray, idArray
   put the result into reverseIDArray
   --
   put linkArray into dataArray ["linkArray"]
   put idArray into dataArray ["idArray"]
   put idLinkArray into dataArray ["idLinkArray"]
   put reversedIdArray into dataArray ["reverseIdArray"]
end overlayArray_ConstructDataArray


--> LinkArray | Construct
-
function linkArray_Translate linkArray, reverseIDArray
   local idLinkArray
   repeat for each key parentKey in linkArray
      put reverseIDArray [parentKey] into parentID
      put empty into idLinkArray [parentID] -- in case theere are no children
      
      -- now do children
      put linkArray [parentKey] into childArray
      repeat for each key childKey in childArray
         put reverseIDArray [childKey] into childID
         put empty into idLinkArray [parentID][childID]
      end repeat
   end repeat
   --
   return idLinkArray
end linkArray_Translate

command linkArray_IdConstruct linkArray, @idLinkArray, @idArray
   -- useful to create simple arrays from complex data.
   -- creates simple numbered nodes n1, n2 etc
   
   repeat for each key parentKey in linkArray
      _AddToSimpleKeyArray reverseIDArray, idArray, parentKey
      
      -- now do children
      put linkArray [parentKey] into childArray
      repeat for each key childKey in childArray
         _AddToSimpleKeyArray reverseIDArray, idArray, childKey
      end repeat
   end repeat
   --
   put linkArray_Translate (linkArray, reverseIDArray) into idLinkArray
   return reverseIDArray
end linkArray_IdConstruct

private command _AddToSimpleKeyArray @reverseIDArray, @idArray, someKey
   put reverseIDArray [someKey] into simpleID
   if simpleID is empty then
      put the number of lines of keys (idArray) + 1 into keyNumber
      put "n" & keyNumber into simpleID
      --
      put simpleID into reverseIDArray [someKey]
      put someKey into idArray [simpleID]
   end if
   return simpleID
end _AddToSimpleKeyArray

on mDouble_DisplayLinkArray displayView, safd
   breakpoint
end mDouble_DisplayLinkArray


--> Display | LinkArray
-
command display_LinkArrayGraph linkArray, pGraphStyle, pFile, pBgColour, pGraphName, pDefSection, pConcentrate, pDefaultShape
   if pGraphName is empty then put "Link Array" into pGraphName
   --
   -- put linkArray_DotNodeLinks (linkArray, empty) into nodeSection
   -- put dot_Construct (nodeSection, pGraphName) into dotText
   put linkArray_ConstructDotSimple (linkArray, pGraphStyle, pBgColour, pConcentrate, pDefaultShape, pDefSection, pGraphName) into dotText
   dot_CreateGraph dotText, pFile, pGraphStyle
   put the result into svgFile
   display_SVG svgFile, pGraphName
   display_Text dotText, pGraphName
   --
   return svgFile
end display_LinkArrayGraph

command display_LinkArray linkArray, pTitle, pLabel
   if pLabel is empty then put "Link Array" into pLabel
   --
   display_Data linkArray, pTitle, pLabel
   put the result into displayView
   display_SetInteractions displayView, "LinkArray", "mDouble_DisplayLinkArray"
   --
   return displayView
end display_LinkArray


--> LinkArray | Create
-
function linkArray_ConstructDot linkArray, pDotMetadataArray, pDefSection, pGraphController
   set the cursor to watch
   put pDotMetadataArray ["dot_HeaderArray"] into dotPropertyArray
   put pDotMetadataArray ["graph_PropertyArray"] into graphPropertyArray
   
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
   --
   put graphPropertyArray ["overlay_Name"] into graphName
   if graphName is empty then put "linkArray_ConstructDot" into graphName
   --
   put dot_Construct (nodeSection, graphName, graphHeader) into dotText
   --
   return dotText
end linkArray_ConstructDot


--> Display | Link | Array
-

function linkArray_ConstructLinkSection linkArray, pNodeTypeArray, pClusterArray, pGraphController
   -- all from arrays (with an optional script override in pGraphController)
   -- cloned from "hKeyArray_ConstructNodeSection", see also "hKeyArray_DotNestedObjectClusters"
   
   -- node defs
   if pNodeTypeArray is an array then
      put _ConstructDefSection (nodeTypeArray, pGraphController) into nodeDefs
   end if
   if pClusterArray is an array then
      -- specific (construct object clusters)
      put _ConstructClusterDefs (clusterArray, pGraphController) into clusterDefs
   end if
   put nodeDefs & CR & CR & clusterDefs into defSection
   
   -- node links
   put linkArray_DotNodeLinks (linkArray) into linkSection
   if defSection is empty then
      return word 1 to -1 of linkSection
   else
      return word 1 to -1 of defSection & CR & CR & linkSection
   end if
end linkArray_ConstructLinkSection

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
   
   /*
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
   */
end linkArray_DotNodeLinks


--> Private
-
private function _ConstructClusterDefs idArray, hLinkArray
   -- put hKeyArray_DotNestedObjectClusters (idArray, hLinkArray) into clusterDefs
   return empty
end _ConstructClusterDefs

private function _ConstructDefSection nodeTypeArray, pGraphController
   -- stub
   return empty
end _ConstructDefSection
