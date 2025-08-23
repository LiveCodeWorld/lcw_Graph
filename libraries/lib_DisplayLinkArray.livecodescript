script "lib_DisplayLinkArray"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayLinkArray
type: library
version: 0.1

/*Some help*/


--> Display | LinkArray
-
command display_HkeyLinkArray hkey, pGraphStyle
   put hKey_GetArray (hkey) into hkeyArray
   --
   display_LinkArray hkeyArray, hKey, "Hkey LinkArray"
   put the result into dView
   --
   set the displayed_Hkey of dView to hKey
   set the displayed_GraphStyle of dView to pGraphStyle
   set the link_Array of dView to hkeyArray
   --
   return dView
end display_HkeyLinkArray

command display_LinkArrayGraph linkArray, pGraphStyle, pFile, pBgColour, pGraphName, pDefSection, pConcentrate, pDefaultShape
   if pGraphName is empty then put "Link Array" into pGraphName
   --
   put dot_FromLinkArray (linkArray, pGraphStyle, pBgColour, pConcentrate, pDefaultShape, pDefSection, pGraphName) into dotText
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


--> Working on
-
private function _ConstructDefSection linkArray, nodeTypeArray
   if pNodeTypeArray is an array then
      return empty -- stub
   end if
   
   repeat for each key fromKey in linkArray
      put linkArray [fromKey] into toArray
      repeat for each key toKey in toArray
         put toArray [toKey] ["label"] into toLabel
         if toLabel is not empty then
            -- put 
         end if
      end repeat
   end repeat
end _ConstructDefSection


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
   
   ## Node defs
   put _ConstructDefSection (linkArray, nodeTypeArray) into nodeDefs
   if pClusterArray is an array then
      put _ConstructClusterDefs (clusterArray, pGraphController) into clusterDefs
   end if
   put nodeDefs & CR & CR & clusterDefs into defSection
   
   ## Node links
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
      --
      _QuoteNode someKey
      if someLinkArray is an array then
         repeat for each key someLink in someLinkArray
            _QuoteNode someLink
            put someKey && "->" && someLink & ";" & CR after linkSection
         end repeat
      else
         put someLinkArray into someLinks
         repeat for each line someLink in someLinks
            _QuoteNode someLink
            put someKey && "->" && someLink & ";" & CR after linkSection
         end repeat
      end if
   end repeat
   delete char -1 of linkSection
   return linkSection
end linkArray_DotNodeLinks

private command _QuoteNode @sNode
   if the number of words of sNode > 1 then
      put kwote(sNode) into sNode
      -- put kwote (word 1 to -1 of sNode) into sNode
   end if
end _QuoteNode


--> Private
-
private function _ConstructClusterDefs idArray, hLinkArray
   -- put hKeyArray_DotNestedObjectClusters (idArray, hLinkArray) into clusterDefs
   return empty
end _ConstructClusterDefs
