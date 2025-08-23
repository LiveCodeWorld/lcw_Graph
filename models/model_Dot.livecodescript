script "model_Dot"
--> MetaData
-
license: GPLv3
name: model_Dot
type: model
version: 0.1

/* 
This model contains handlers that store the arrays (models) required to draw dot graphs.

Arrays can be stored to file, 
but also loaded into global variables where they can be accessed by getprop and setprop handlers.
This allows local getprops to override the behavior of the gloabl model.

See stack "model_Hkey"
*/


--> Dot | Plurals
-
getprop dot_ExportedStyles sObject
   put the script_MetadataFiles [false] of the target into dotFiles
   filter dotFiles with "*.dot" into graphStyles
   replace ".dot" with empty in graphStyles
   return graphStyles
end dot_ExportedStyles

function dot_ListGraphStyles
   return "radial,spring,circular,-,hierarchical,-,undirected spring,fast undirected spring,-,tree map,nested" 
end dot_ListGraphStyles

function dot_ListGraphProps
   put "bb,beautify,bgcolor,center,charset,class,clusterrank,colorscheme,comment" into gProps
   put ",compound,concentrate,Damping,defaultdist,dim,dimen,directed,diredgeconstraints,dpi,epsilon,esep,fontcolor,fontname,fontnames,fontpath,fontsize" after gProps
   put ",forcelabels,gradientangle,href,id,imagepath,inputscale,K,label,label_scheme,labeljust,labelloc,landscape,layerlistsep" after gProps
   put ",layers,layerselect,layersep,layout,levels,levelsgap,lheight,linelength,lp,lwidth,margin,maxiter,mclimit,mindist,mode,model,newrank,nodesep" after gProps
   put ",nojustify,normalize,notranslate,nslimit,nslimit1,oneblock,ordering,orientation,outputorder,overlap,overlap_scaling,overlap_shrink,pack" after gProps
   put ",packmode,pad,page,pagedir,quadtree,quantum,rankdir,ranksep,ratio,remincross,repulsiveforce,resolution,root,rotate,rotation,scale,searchsize" after gProps
   put ",sep,showboxes,size,smoothing,sortv,splines,start,strict,style,stylesheet,target,TBbalance,tooltip,truecolor,URL,viewport,voro_margin,xdotversion" after gProps
   return gProps
end dot_ListGraphProps

function dot_AllGraphFlattenNums
   return "0,1,2,3,4,5,6,7,8,9,10,11,12,-,none"
end dot_AllGraphFlattenNums


--> Dot | Model
-
function dot_GetText dotFile
   -- get url ("file:" & dotFile)
   put url ("binfile:" & dotFile) into utf8Text
   put textDecode (utf8Text, "UTF-8") into dotText
   return dotText
end dot_GetText

command dot_SetText dotFile, dotText
   if dotFile is empty then put the tempname into dotFile
   --
   put folder_Above (dotFile) into someFolder
   folder_CreateNested someFolder
   --
   put textEncode (dotText, "utf-8") into utf8Text
   put utf8Text into url ("binfile:" & dotFile)
   return dotFile
end dot_SetText


--> Props
-
/*
These properties are only used localy by the linkArray_Model to change the way nodes are named.
They are not essential, and graphs will otherwise be drawn using the node IDs in the linkArray and hIdArray (nodeDictionary)
*/

getprop hkey_DotText [hKey]
   -- was "linkarray_ModelDotText", then "hkey_DotText"
   put the long id of the target into pTargetObject
   if hKey is empty then put the displayed_Hkey of pTargetObject into hKey
   
   put hkey_GetLinkArray (hKey) into hkeyArray
   linkArray_IdConstruct hkeyArray, hLinkArray, hIdArray
   
   put the overlay_Name of pTargetObject into graphName
   put the dot_ClusterType of pTargetObject into dotClusterType
   switch dotClusterType
      case "Object"
         put the dot_Header of pTargetObject into graphHeader
         put hKeyArray_ConstructObjectDot (hLinkArray, hIdArray, graphName, graphHeader, pTargetObject) into dotText
         return dotText
      case "Nested Trac Text"
         put the linkarray_TracGraphHeader [defaultNodeUrl] of pTargetObject into graphHeader
         put _ConstructNestedObjectDot (hLinkArray, hIdArray, graphName, graphHeader, pTargetObject) into dotText
         
         put "{{{" & CR after tracMacro
         put "#!graphviz" & CR after tracMacro
         put dotText & CR after tracMacro
         put "}}}" & CR after tracMacro
         
         delete char -1 of tracMacro
         return tracMacro
      default -- case "Nested"
         put the dot_Header of pTargetObject into graphHeader
         put _ConstructNestedObjectDot (hLinkArray, hIdArray, graphName, graphHeader, pTargetObject) into dotText
         return dotText
   end switch
end hkey_DotText

getprop dot_NodeID [nodeID]
   -- a default (Should not change it)
   return nodeID
end dot_NodeID

getprop dot_NodeType [nodeID]
   -- default value
   put the uOPN ["dot_NodeType"] of the linkArray_Model of the target into nodeType
   if nodeType is empty then
      put "nodeID" into nodeType
      set the uOPN ["dot_NodeType"] of the linkArray_Model of the target to nodeType
   end if
   return nodeType
end dot_NodeType

setprop dot_NodeType [nodeID] graphNodeType
   set the uOPN ["dot_NodeType"] of the linkArray_Model of the target to graphNodeType
end dot_NodeType

getprop dot_NodeTypes
   return the hKey_CaseConditions ["dot_ConstructNodeID,f"] of me
end dot_NodeTypes

-- setprop dot_Header dotHeader
-- could also update arrays?
-- a default value, which you can override locally
put the dot_Text of the target into dotText
dot_SetHeader dotText, dotHeader
set the dot_Text of the target to dotText
return dotText
end dot_Header

getprop dot_Header [pOverlayName]
   -- a default value, which you can override locally
   if pOverlayName is empty then put the displayed_OverlayName of the target into pOverlayName
   put the overlay_Array of the target into overlayArray
   put overlayArray_ConstructHeader (overlayArray, pOverlayName) into dotHeader
   return dotHeader
end dot_Header

getprop dot_DefSection [pOverlayName]
   -- a default value, which you can override locally
   put the overlay_Array of the target into overlayArray
   put dot_DefSectionFromArray (overlayArray, pOverlayName) into defSection
   return defSection
end dot_DefSection

getprop dot_LinkSection
   put the displayed_OverlayName of the target into graphName
   put the overlay_Array of the target into overlayArray
   
   if dotClusterArray is an array then
      -- put linkArray_ConstructClusterDefs (overlayArray, pGraphController) into linkSection
      put overlayData_ConstructClusterSection (overlayArray, graphName) into linkSection
   else
      overlayArray_DeconstructData overlayArray, linkArray, idArray, idLinkArray, reverseIdLinkArray, dotClusterArray
      put linkArray_DotNodeLinks (linkArray) into linkSection
   end if
   return linkSection
end dot_LinkSection


--> Dot | Node
-
/*
dot_Nodexxx props allow setting the styles of default nodes for groups of the whole graph.
*/

getprop node_Shape [groupNameOrNum]
   put the dot_GroupStyleArray of the target into dotGroupStyleArray
   put dotGroupStyleArray [groupNameOrNum]["node_StyleArray"] into nodeStyleArray
   return nodeStyleArray ["shape"]
end node_Shape

setprop node_Shape [groupNameOrNum] someShape
   put the dot_GroupStyleArray of the target into dotGroupStyleArray
   put someShape into dotGroupStyleArray [groupNameOrNum]["node_StyleArray"]["shape"]
   set the dot_GroupStyleArray of the target to dotGroupStyleArray
   
   dispatch "dot_Reconstruct" to the target
   return dotGroupStyleArray
end node_Shape

function dot_AllShapes
   -- put "rect,rectangle" & comma after nodeStyles
   put "none" & comma after nodeStyles
   put "-" & comma after nodeStyles
   put "box,ellipse,circle,point,triangle,plaintext" & comma after nodeStyles
   put "-" & comma after nodeStyles
   put "shapefile" & comma after nodeStyles
   put "-" & comma after nodeStyles
   put "polygon,diamond,pentagon,hexagon,septagon,octagon" & comma after nodeStyles
   put "-" & comma after nodeStyles
   put "doublecircle,doubleoctagon,tripleoctagon" & comma after nodeStyles
   put "Mdiamond,Msquare,Mcircle" & comma after nodeStyles
   put "-" & comma after nodeStyles
   put "egg,trapezium,parallelogram,house,invtriangle,invtrapezium,invhouse" & comma after nodeStyles
   
   delete char -1 of nodeStyles
   return nodeStyles
end dot_AllShapes

getprop node_FillColour [groupNameOrNum]
   put the dot_GroupStyleArray of the target into dotGroupStyleArray
   put dotGroupStyleArray [groupNameOrNum]["node_StyleArray"] into nodeStyleArray
   put nodeStyleArray ["fillcolor"] into dotColour
   put text_SplitCaps (dotColour) into someColour
   return someColour
end node_FillColour

setprop node_FillColour [groupNameOrNum] someColour
   put the dot_GroupStyleArray of the target into dotGroupStyleArray
   put someColour into dotGroupStyleArray [groupNameOrNum]["node_StyleArray"]["fillcolor"]
   set the dot_GroupStyleArray of the target to dotGroupStyleArray
   
   dispatch "dot_Reconstruct" to the target
   return dotGroupStyleArray
end node_FillColour

getprop node_BorderColour [groupNameOrNum]
   put the dot_GroupStyleArray of the target into dotGroupStyleArray
   put dotGroupStyleArray [groupNameOrNum]["node_StyleArray"] into nodeStyleArray
   return nodeStyleArray ["color"]
end node_BorderColour

setprop node_BorderColour [groupNameOrNum] someColour
   put the dot_GroupStyleArray of the target into dotGroupStyleArray
   put someColour into dotGroupStyleArray [groupNameOrNum]["node_StyleArray"]["color"]
   set the dot_GroupStyleArray of the target to dotGroupStyleArray
   
   dispatch "dot_Reconstruct" to the target
   return dotGroupStyleArray
end node_BorderColour


--> Overaly | Props | Plurals
-
getprop overlay_Styles
   return dot_ListGraphStyles()
end overlay_Styles

getprop overlay_Sizes
   return dot_GetGraphSizes()
end overlay_Sizes

getprop overlay_FlattenNums
   return dot_AllGraphFlattenNums()
end overlay_FlattenNums

getprop overlay_DefaultMaximumDepths
   return dot_GetGraphMaximumDepths()
end overlay_DefaultMaximumDepths


--> Dot | Node Style
-
getprop dot_NodeStyle [groupNameOrNum]
   put the displayed_OverlayName of the target into pOverlayName
   put the overlay_Array of the target into overlayArray
   put overlayArray_GetGroupStyleArray (overlayArray, pOverlayName) into dotGroupStyleArray
   
   put dotGroupStyleArray [groupNameOrNum] into nodeStyleArray
   return nodeStyleArray
end dot_NodeStyle

setprop dot_NodeStyle [groupNameOrNum] nodeStyleArray
   put the displayed_OverlayName of the target into pOverlayName
   put the overlay_Array of the target into overlayArray
   put overlayArray_GetGroupStyleArray (overlayArray, pOverlayName) into dotGroupStyleArray
   
   put dotGroupStyleArray [groupNameOrNum] into oldStyleArray
   union nodeStyleArray with oldStyleArray
   put nodeStyleArray into dotGroupStyleArray [groupNameOrNum]
   
   overlayArray_SetGroupStyleArray overlayArray, dotGroupStyleArray, pOverlayName
   set the overlay_Array of the target to overlayArray
   return overlayArray
end dot_NodeStyle

setprop dot_NodeAddStyle [groupNameOrNum] nodeStyleArray
   put the displayed_OverlayName of the target into pOverlayName
   put the overlay_Array of the target into overlayArray
   put overlayArray_GetGroupStyleArray (overlayArray, pOverlayName) into dotGroupStyleArray
   
   put dotGroupStyleArray [groupNameOrNum] into oldStyleArray
   union nodeStyleArray with oldStyleArray
   put nodeStyleArray into dotGroupStyleArray [groupNameOrNum]
   
   overlayArray_SetGroupStyleArray overlayArray, dotGroupStyleArray, pOverlayName
   set the overlay_Array of the target to overlayArray
   return overlayArray
end dot_NodeAddStyle

getprop dot_NodeStyleNames
   put the displayed_OverlayName of the target into pOverlayName
   put the overlay_Array of the target into overlayArray
   put overlayArray_GetGroupStyleArray (overlayArray, pOverlayName) into dotGroupStyleArray
   put keys(dotGroupStyleArray) into nodeStyleNames
   return nodeStyleNames
end dot_NodeStyleNames


--> Dot | Model | Props
-
/*
Wrappers around overlay_Array

*/

getprop dot_DefaultShape [pOverlayName]
   return _GetHeaderProperty (word 1 of the params, pOverlayName)
end dot_DefaultShape

setprop dot_DefaultShape [pOverlayName] someShape
   _SetHeaderProperty word 1 of the params, someShape, pOverlayName
   return the result
end dot_DefaultShape

getprop dot_Splines [pOverlayName]
   return _GetHeaderProperty (word 1 of the params, pOverlayName)
end dot_Splines

setprop dot_Splines [pOverlayName] someBoolean
   _SetHeaderProperty word 1 of the params, someBoolean, pOverlayName
   return the result
end dot_Splines

getprop dot_Concentrate [pOverlayName]
   return _GetHeaderProperty (word 1 of the params, pOverlayName)
end dot_Concentrate

setprop dot_Concentrate [pOverlayName] someBoolean
   _SetHeaderProperty word 1 of the params, someBoolean, pOverlayName
   return the result
end dot_Concentrate

getprop dot_Overlap [pOverlayName]
   return _GetHeaderProperty (word 1 of the params, pOverlayName)
end dot_Overlap

setprop dot_Overlap [pOverlayName] someOverlap
   _SetHeaderProperty word 1 of the params, someOverlap, pOverlayName
   return the result
end dot_Overlap

getprop dot_Order [pOverlayName]
   return _GetHeaderProperty (word 1 of the params, pOverlayName)
end dot_Order

setprop dot_Order [pOverlayName] dotOrder
   _SetHeaderProperty word 1 of the params, dotOrder, pOverlayName
   return the result
end dot_Order

getprop dot_ClusterRank [pOverlayName]
   return _GetHeaderProperty (word 1 of the params, pOverlayName)
end dot_ClusterRank

setprop dot_ClusterRank [pOverlayName] someBoolean
   _SetHeaderProperty word 1 of the params, someBoolean, pOverlayName
   return the result
end dot_ClusterRank


--> Dot | Property | Plurals
-
getprop dot_Orders
   return dot_OrderOptions()
end dot_Orders

getprop dot_Shapes
   return dot_AllShapes()
end dot_Shapes

getprop dot_ClusterRanks
   return dot_AllClusters()
end dot_ClusterRanks

getprop dot_Overlaps
   return dot_OverlapOptions()
end dot_Overlaps

getprop dot_Orders
   return dot_OrderOptions()
end dot_Orders

getprop dot_Clusters
   return dot_AllClusters()
end dot_Clusters

getprop dot_DefaultShapes
   return dot_AllShapes()
end dot_DefaultShapes

getprop dot_NodeColours
   return dot_NodeColourOptions()
end dot_NodeColours

getprop dot_NodeStyles
   return dot_NodeStyleOptions()
end dot_NodeStyles

getprop dot_ClusterTypes
   return dot_ClusterTypeOptions()
end dot_ClusterTypes


--> Dot | Model | Props | Functions
-
private function _GetHeaderProperty propName, pOverlayName
   if pOverlayName is empty then put the displayed_OverlayName of the target into pOverlayName
   put the overlay_Array [pOverlayName] of the target into overlayArray
   put overlayArray_GetHeaderProperty (overlayArray, propName) into propValue
   return propValue
end _GetHeaderProperty

private command _SetHeaderProperty propName, propValue, pOverlayName
   --  _SetDotValue "overlap", someOverlap, "none", pOverlayName
   
   if pOverlayName is empty then put the displayed_OverlayName of the target into pOverlayName
   put the overlay_Array [pOverlayName] of the target into overlayArray
   overlayArray_SetHeaderProperty overlayArray, propName, propValue
   
   ## Recreate files
   overlayArray_CreateFilesAndSetGeometry overlayArray
   
   set the overlay_Array [pOverlayName] of the target to overlayArray
   return the result
end _SetHeaderProperty

function dot_NodeStyleOptions
   return "filled,invisible,diagonals,rounded,dashed,dotted,solid,bold"
end dot_NodeStyleOptions

function dot_ClusterTypeOptions
   get the hKey_CaseConditions ["hkey_DotText,g"] of the dot_Model of the target
   return it & ",-,none"
end dot_ClusterTypeOptions

function dot_OverlapOptions
   return "true,-,false,scale,-,none"
end dot_OverlapOptions

function dot_OrderOptions
   return "out,in,-,none"
end dot_OrderOptions

function dot_AllClusters
   -- return "local,none"
   return "local,-,global,none"
end dot_AllClusters

function dot_NodeColourOptions
   put colour_BaseColourOutline() into colourOutline
   get outline_ConstructBranchSections(colourOutline, true)
   return "Ask,-," & it
end dot_NodeColourOptions

function dot_GetGraphMaximumDepths
   return "1,2,3,4,5,6,7,8,9,-,none"
end dot_GetGraphMaximumDepths


--> overlayArray | Node Style
-
/*
An array that speicifes the definition section of a dot file.
Allows groups of nodes to be share a common style.

Structure:
metadata
- default (ie overlay_Name)
-   dot_NodeStyleArray
-     styleName -> ie 2 or "yellow"
-       nodeIds -> n1....
-       node_StyleArray- > a node_StyleArray or a snode_StyleName ie b"lue box"

Where the syle name refers to an array stored in the display/node_StyleArray/name section of overlay_Array
*/

getprop dot_GroupStyleArray [pOverlayName]
   if pOverlayName is empty then put the displayed_OverlayName of the target into pOverlayName
   put the overlay_Array [pOverlayName] of the target into overlayArray
   put overlayArray_GetGroupStyleArray (overlayArray, pOverlayName) into dotGroupStyleArray
   return dotGroupStyleArray
end dot_GroupStyleArray

setprop dot_GroupStyleArray [pOverlayName] dotGroupStyleArray
   if pOverlayName is empty then put the displayed_OverlayName of the target into pOverlayName
   put the overlay_Array [pOverlayName] of the target into overlayArray
   overlayArray_SetGroupStyleArray overlayArray, dotGroupStyleArray, pOverlayName
   set the overlay_Array [pOverlayName] of the target to overlayArray
   return overlayArray
end dot_GroupStyleArray

function dot_ParamsToStyleArray styleParams
   replace ", " with comma in styleParams
   split styleParams with comma and "="
   return styleParams
end dot_ParamsToStyleArray


--> Dot | MetaData | Array
-
/*
The overlay_Array of an (image) view contains both the dot and the graph values in a flat property array.
To extract the overlay_PropertyArray, or the dot_HeaderArray
*/

getprop dot_DataArray [pOverlayName]
   put the overlay_Array [pOverlayName] of the target into overlayArray
   put overlayArray ["data"] into dotDataArray
   return dotDataArray
end dot_DataArray

setprop dot_DataArray [pOverlayName] dotDataArray
   put the overlay_Array [pOverlayName] of the target into overlayArray
   put dotDataArray into overlayArray ["data"]
   set the overlay_Array [pOverlayName] of the target to overlayArray
   return overlayArray
end dot_DataArray

getprop dot_MetadataArray [pOverlayName]
   put the overlay_Array [pOverlayName] of the target into overlayArray
   put overlayArray_GetMetadataArray (overlayArray) into metadataArray
   return metadataArray
end dot_MetadataArray

setprop dot_MetadataArray [pOverlayName] metadataArray
   put the overlay_Array [pOverlayName] of the target into overlayArray
   overlayArray_SetMetadataArray overlayArray, metadataArray
   set the overlay_Array [pOverlayName] of the target to overlayArray
   return overlayArray
end dot_MetadataArray

getprop dot_HeaderArray [pOverlayName]
   put the overlay_Array [pOverlayName] of the target into overlayArray
   put overlayArray_GetHeaderArray (overlayArray) into propertyArray
   return propertyArray
end dot_HeaderArray

setprop dot_HeaderArray [pOverlayName] propertyArray
   put the overlay_Array [pOverlayName] of the target into overlayArray
   overlayArray_SetHeaderArray overlayArray, propertyArray
   set the overlay_Array [pOverlayName] of the target to overlayArray
   return overlayArray
end dot_HeaderArray

getprop dot_HeaderValue [someKey]
   put the long id of the target into targetObject
   put dot_GetHeaderValue (targetObject, someKey) into headerValue
   return headerValue
end dot_HeaderValue

setprop dot_HeaderValue [someKey] headerValue
   put the long id of the target into targetObject
   dot_SetHeaderValue targetObject, someKey, headerValue
   return the result
end dot_HeaderValue

function dot_GetHeaderValue targetObject, someKey
   put the displayed_OverlayName of targetObject into pOverlayName
   put the overlay_Array [pOverlayName] of targetObject into overlayArray
   
   put overlayArray_GetHeaderArray (overlayArray) into headerArray
   put headerArray [someKey] into someValue
   return someValue
end dot_GetHeaderValue

command dot_SetHeaderValue targetObject, someKey, someValue
   put the displayed_OverlayName of targetObject into pOverlayName
   put the overlay_Array [pOverlayName] of targetObject into overlayArray
   
   put overlayArray_GetHeaderArray (overlayArray) into headerArray
   put someValue into headerArray [someKey]
   overlayArray_SetHeaderArray overlayArray, headerArray
   
   set the overlay_Array [pOverlayName] of targetObject to overlayArray
   return headerArray
end dot_SetHeaderValue

getprop dot_DefaultHeaderValue [someKey]
   put the long id of the target into targetObject
   put dot_GetDefaultHeaderValue (targetObject, someKey) into headerValue
   return headerValue
end dot_DefaultHeaderValue

setprop dot_DefaultHeaderValue [someKey] headerValue
   put the long id of the target into targetObject
   dot_SetDefaultHeaderValue targetObject, someKey, headerValue
   return the result
end dot_DefaultHeaderValue

function dot_GetDefaultHeaderValue targetObject, someKey
   -- put the long id of the target into targetObject
   put the overlay_DefaultArray of targetObject into overlayDefaultArray
   put overlayArray_GetHeaderArray (overlayDefaultArray) into headerArray
   put headerArray [someKey] into someValue
   return someValue
end dot_GetDefaultHeaderValue

command dot_SetDefaultHeaderValue targetObject, someKey, someValue
   -- put the long id of the target into targetObject
   put the overlay_DefaultArray of targetObject into overlayDefaultArray
   
   put overlayArray_GetHeaderArray (overlayDefaultArray) into headerArray
   put someValue into headerArray [someKey]
   overlayArray_SetHeaderArray overlayDefaultArray, headerArray
   
   set the overlay_DefaultArray of targetObject to overlayDefaultArray
   return headerArray
end dot_SetDefaultHeaderValue


--> Dot | Data | Array
-
getprop dot_GeometryArray [pOverlayName]
   put the dot_DataArray [pOverlayName] of the target into dataArray
   return dataArray ["geometry"]
end dot_GeometryArray

setprop dot_GeometryArray [pOverlayName] geometryArray
   put the dot_DataArray [pOverlayName] of the target into dataArray
   put geometryArray into dataArray ["geometry"]
   set the dot_DataArray [pOverlayName] of the target to dataArray
   return dataArray
end dot_GeometryArray

getprop dot_LinkArray [pOverlayName]
   put the dot_DataArray [pOverlayName] of the target into dataArray
   return dataArray ["linkArray"]
end dot_LinkArray

setprop dot_LinkArray [pOverlayName] linkArray
   put the dot_DataArray [pOverlayName] of the target into dataArray
   put linkArray into dataArray ["linkArray"]
   set the dot_DataArray [pOverlayName] of the target to dataArray
   return dataArray
end dot_LinkArray

getprop dot_IdLinkArray [pOverlayName]
   put the dot_DataArray [pOverlayName] of the target into dataArray
   return dataArray ["idLinkArray"]
end dot_IdLinkArray

setprop dot_IdLinkArray [pOverlayName] idLinkArray
   put the dot_DataArray [pOverlayName] of the target into dataArray
   put idLinkArray into dataArray ["idLinkArray"]
   set the dot_DataArray [pOverlayName] of the target to dataArray
   return dataArray
end dot_IdLinkArray

getprop dot_IdArray [pOverlayName]
   put the dot_DataArray [pOverlayName] of the target into dataArray
   return dataArray ["idArray"]
end dot_IdArray

setprop dot_IdArray [pOverlayName] idArray
   put the dot_DataArray [pOverlayName] of the target into dataArray
   put idArray into dataArray ["idArray"]
   put array_ConstructReverseDictionary (idArray) into dataArray ["reverseIdArray"]  -- lets also set the reverse lookup
   set the dot_DataArray [pOverlayName] of the target to dataArray
   return dataArray
end dot_IdArray

getprop dot_ReverseIdArray [pOverlayName]
   put the dot_DataArray [pOverlayName] of the target into dataArray
   return dataArray ["reverseIdArray"]
end dot_ReverseIdArray

setprop dot_ReverseIdArray [pOverlayName] reverseIdArray
   put the dot_DataArray [pOverlayName] of the target into dataArray
   put reverseIdArray into dataArray ["reverseIdArray"]
   set the dot_DataArray [pOverlayName] of the target to dataArray
   return dataArray
end dot_ReverseIdArray


--> Dot | Data | Array | dot_ClusterArray
-
getprop dot_ClusterArray [pOverlayName]
   put the overlay_Array [pOverlayName] of the target into overlayArray
   put overlayArray_GetClusterArray (overlayArray) into propertyArray
   return propertyArray
end dot_ClusterArray

setprop dot_ClusterArray [pOverlayName] propertyArray
   put the overlay_Array [pOverlayName] of the target into overlayArray
   overlayArray_SetClusterArray overlayArray, propertyArray
   set the overlay_Array [pOverlayName] of the target to overlayArray
   return overlayArray
end dot_ClusterArray


--> Dot | Model | Files
-
/*
Conventions for naming and organising files realted to scripts and their graphs.
*/

command dot_FilesFromHkey hKey, graphStyle, @dotFile, @imageFile, @cmapxFile, @xdotFile, pVersionName
   put hkey_DotFile (hKey, pVersionName, false) into dotFile
   
   put dotFile into dotFolder
   set the itemdelimiter to "/"
   delete item -1 of dotFolder
   put "/" after dotFolder
   overlay_Files dotFolder, dotFile, imageFile, cmapxFile, xdotFile, dotArrayFile, graphStyle
end dot_FilesFromHkey

function dot_LabelFileWithGraphStyle graphStyle, dotFile, pImageFormat
   -- adds graphStyle_ before the short file name
   if dotFile is empty then put dot_NewTemporaryFilePath() into dotFile
   if pImageFormat is empty then put "png" into pImageFormat
   file_Deconstruct dotFile, rootFolder, shortName, dotFileFormat
   if graphStyle is not empty then
      set the itemdelimiter to "_"
      if the number of items of shortName > 1 then
         put graphStyle into item 1 of shortName
      else
         put graphStyle & "_" before shortName
      end if
   end if
   put file_Construct (rootFolder, shortName, pImageFormat) into imageFile
   return imageFile
end dot_LabelFileWithGraphStyle

function dot_NameFromImageFile imageFile
   file_Deconstruct imageFile, someRoot, shortName, fileExtension
   set the itemdelimiter to "."
   put item 1 of shortName into graphName
   return graphName
end dot_NameFromImageFile

command dot_FilesFromScriptObject scriptObject, graphStyle, pGraphSize, @dotFile, @imageFile, @cmapxFile, @xdotFile
   put scriptFile_ConstructDot (scriptObject, graphStyle, pGraphSize) into dotFile
   
   put dotFile into dotFolder
   set the itemdelimiter to "/"
   delete item -1 of dotFolder
   put "/" after dotFolder
   overlay_Files dotFolder, dotFile, imageFile, cmapxFile, xdotFile, dotArrayFile, graphStyle
end dot_FilesFromScriptObject
