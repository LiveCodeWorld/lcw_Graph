script "lib_DotHeader"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_DotHeader
type: library
version: 0.1

/*Some help*/


--> Working on
-
function hkeyArray_ConstructDot hkeyArray, graphName, graphStyle, graphSize
   local graphDirection, graphOrder, defaultShape
   
   set the cursor to watch
   
   if the filter_System of me is true then hKeyArray_FilterSystemMessages hkeyArray
   if the fllter_CustomMissing of me  is true then hKeyArray_FilterCustomMissing hkeyArray
   if graphSize is empty then
      put the dot_GraphSize of me into graphSize
      put dot_RectFromSize(graphSize) into graphRect
   end if
   
   put the overlay_Overlap of me into overlap
   put the concentrate_Graph of me into concentrate
   put true into splines
   if graphstyle = "clusters" then
      put true into clusterGraph
   else
      put false into clusterGraph
   end if
   
   _ConstructDotHeaderArray dotPropertyArray, overlap, concentrate, true
   -- 
   put dot_ConstructHeader (graphRect, dotPropertyArray) into graphHeader
   put dot_NestedSubgraphsFromhkeyArray (hkeyArray, clusterGraph, graphName, graphHeader) into dotText
   
   return dotText
end hkeyArray_ConstructDot


--> Target | Props
-
getprop dot_BboxSize
   put the rect of the target into someRect
   put dot_BboxSize (someRect) into targetSize
   return targetSize
end dot_BboxSize

getprop dot_InchSize [expandIfNeeded]
   put the rect of the target into someRect
   put dot_GraphInchSize (someRect, expandIfNeeded) into targetSize
   return targetSize
end dot_InchSize

getprop dot_TargetSizeLine
   put the rect of the target into graphRect
   put dot_ConvertGraphRect (graphRect, false, false) into targetSize
   return targetSize
end dot_TargetSizeLine


--> Dot | Header
-
function dot_GetGraphHeader dotText
   _SetGraphSectionOffsets dotText, startChar, endChar
   put char startChar to endChar of dotText into graphHeader
   return graphHeader
end dot_GetGraphHeader

command dot_SetHeader @dotText, dotHeader
   if the number of lines of dotHeader > 1 then
      line_Indent dotHeader
   end if
   
   _SetGraphSectionOffsets dotText, startChar, endChar
   if the result is true then
      if char startChar-1 of dotText = tab then
         put dotHeader into char (startChar - 1) to endChar of dotText
      else
         put dotHeader into char startChar to endChar of dotText
      end if
   else
      put offset ("{", dotText) into bCharNum
      put CR & dotHeader after char bCharNum dotText
   end if
end dot_SetHeader


--> Dot | Header | Construct
-
function dot_ConstructHeaderArray overlap, splines, defaultShape, defaultUrl
   local dotHeaderArray, cluster, direction, dotOrder
   put true into concentrate
   put false into overlap
   put true into splines
   put "rectangle" into defaultShape
   
   _ConstructDotHeaderArray dotHeaderArray, overlap, concentrate, splines, cluster, direction, dotOrder, defaultShape, defaultUrl
   return dotHeaderArray
end dot_ConstructHeaderArray

function dot_ConstructHeader graphSize, pDotPropertyArray, graphStyle, pUseInches
   -- old?
   put dot_ConstructHeaderBase (graphSize, pDotPropertyArray, graphStyle, pUseInches) into graphHeaderBase
   
   put "graph [" & CR after graphHeader
   line_Indent graphHeaderBase
   put graphHeaderBase & CR after graphHeader
   put "];" & CR after graphHeader
   
   -- default node section
   _DeconstructDotHeaderArray pDotPropertyArray, overlap, concentrate, splines, cluster, direction, dotOrder, defaultShape, defaultUrl
   if defaultUrl is not empty then put "node [URL=" & kwote(defaultUrl) & "];" & CR after defaultNodeSection
   if defaultShape is not empty then put "node [shape=" & defaultShape & "];" & CR after defaultNodeSection
   if defaultNodeSection is not empty then put CR & defaultNodeSection & CR after graphHeader
   
   delete last char of graphHeader
   return graphHeader
end dot_ConstructHeader

function dot_ConstructHeaderBase graphSize, dotPropertyArray, graphStyle, pUseInches  
   _DeconstructDotHeaderArray dotPropertyArray, overlap, concentrate, splines, cluster, direction, dotOrder, defaultShape, defaultUrl
   delete variable dotPropertyArray ["defaultShape"] -- this graph property does not exist and we set the node section of the graph
   --
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
   delete variable dotPropertyArray ["size"]
   
   --
   if graphStyle is not "hierarchical"  then
      if overlap is not empty then put "overlap=" & overlap & endChar after graphHeaderBase
      if dotOrder is not empty then put  "ordering=" & dotOrder & endChar after graphHeaderBase
      if concentrate is not empty then
         put "concentrate=" & concentrate & endChar after graphHeaderBase
      end if
   end if
   delete variable dotPropertyArray ["overlap"]
   delete variable dotPropertyArray ["dotOrder"]
   delete variable dotPropertyArray ["concentrate"]
   -- delete variable dotPropertyArray ["graphStyle"]
   --
   if cluster is "none" and graphStyle = "hierarchical" then put "clusterrank=" & cluster & endChar after graphHeaderBase
   delete variable dotPropertyArray ["cluster"]
   --
   if splines is not empty then put "splines=" & splines & CR after graphHeaderBase
   delete variable dotPropertyArray ["splines"]
   --
   if direction is not empty then put "rankdir=" & direction & CR after graphHeaderBase
   delete variable dotPropertyArray ["direction"]
   --
   repeat for each key someKey in dotPropertyArray
      put dotPropertyArray [someKey] into someValue
      if someValue is not empty then
         put someKey & "=" & kwote(someValue) & CR after graphHeaderBase
      end if
   end repeat
   
   -- dot_AddDefaultNode
   delete char -1 of graphHeaderBase
   return graphHeaderBase
end dot_ConstructHeaderBase


--> Dot | Header | Size
-
command dot_ResizeImage someView, dotGraphSize
   -- put "0,0,3000,3000" into headerArray ["bb"]
   -- put the dot_BboxSize of someView into headerArray ["bb"]
   -- delete local headerArray ["size"]
   -- put the dot_BboxSize [false] of someView into headerArray ["bb"]
   
   switch dotGraphSize
      case "none"
      case "full"
         put empty into newHeader
         break
      default
         put the dot_InchSize [false] of someView into inchItems
   end switch
   
   put the dot_Text of someView into dotText
   dot_SetGraphSize dotText, dotGraphSize
   set the dot_Text of someView to dotText
   
   return oldHeaderArray
end dot_ResizeImage

command dot_StripGraphSize @dotText
   put dot_GetGraphHeader (dotText) into dotHeader
   put _ExtractHeaderArray (dotHeader) into headerArray
   delete local headerArray ["bb"]
   delete local headerArray ["size"]
   put dot_HeaderFromArrays (headerArray) into newHeader
   dot_SetHeader dotText, newHeader
   return dotText
end dot_StripGraphSize

command dot_ExtractGraphSize dotText, @graphWidth, @graphHeight
   -- was "xdot_ExtractGraphSize"
   repeat 5
      put dot_GetGraphHeader (dotText) into dotHeader
      if dotHeader is empty then exit repeat
      get _ExtractHeaderArray (dotHeader)
      if keys(headerArray) is empty then
         put it into headerArray
      else
         union it with headerArray
         put it into headerArray
      end if
      dot_SetHeader dotText
   end repeat
   _ExtractHeaderArrayDimensions headerArray, graphWidth, graphHeight 
end dot_ExtractGraphSize

function dot_GetGraphSize dotText
   put dot_GetGraphHeader (dotText) into dotHeader
   put _ExtractHeaderArray (oldHeader) into headerArray
   --
   put headerArray ["bb"] into bbSize
   if bbSize is not empty then return bbSize
   --
   put headerArray ["size"] into graphSize
   return graphSize
end dot_GetGraphSize

command dot_SetGraphSize @dotText, inchItems
   local newHeader
   
   put dot_GetGraphHeader (dotText) into oldHeader
   if oldHeader is empty then
      put empty into oldHeaderArray
      if inchItems is not empty then put "size =" && kwote(inchItems) into graphSize
      _ConstructDotHeaderArray dotPropertyArray
      put dot_ConstructHeader (graphSize, dotPropertyArray) into newHeader
   else
      put _ExtractHeaderArray (oldHeader) into headerArray
      delete local headerArray ["bb"]
      delete local headerArray ["size"]
      if inchItems is not empty then put inchItems into headerArray ["size"]
      put dot_HeaderFromArrays (headerArray) into newHeader
   end if
   
   dot_SetHeader dotText, newHeader
   return newHeader
end dot_SetGraphSize

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
      case "image"
         put view_GetTemplateObject ("View|Image|OPN Image") into imageView
         put the rect of imageView into graphRect
         put dot_BboxSize (graphRect) into someRect
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

function dot_ConvertGraphRect someRect, expandIfNeeded, useBbox
   if useBbox is false then
      put dot_GraphInchSize (someRect, expandIfNeeded) into someRect
   else
      put dot_BboxSize (someRect) into someRect
   end if
   return someRect
end dot_ConvertGraphRect

function dot_BboxSize someRect
   put item 3 of someRect - item 1 of someRect into someWidth
   put item 4 of someRect - item 2 of someRect into someHeight
   put 0,0,someWidth,someHeight into someRect
   return someRect
end dot_BboxSize

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

command dot_ConvertToInches @pixelSize, pScreenRez
   if pScreenRez is empty then put 96 into pScreenRez
   set the numberformat to "0.0000"
   repeat with itemNum = 1 to the number of items of pixelSize
      put item itemNum of pixelSize into someNumber
      put someNumber / pScreenRez  into item itemNum of pixelSize
   end repeat
end dot_ConvertToInches

command dot_ConvertToPngPixels @xdotValue
   -- PNG is 96 dpi and xdot is at 72 dpi
   put round(xdotValue * 96 / 72) into xdotValue 
end dot_ConvertToPngPixels

function dot_ConvertDrawRect drawPoints, gHeight, @pointNum, @revRect
   -- was "graphViz_ConvertDrawRect"
   local revPoints
   if word 1 of drawPoints is "P" then
      put word 2 of drawPoints into pointNum
      put word 3 to -1 of drawPoints into drawPoints
      repeat pointNum
         put word 1 of drawPoints into nodeX
         put word 2 of drawPoints into nodeY
         
         put gHeight - nodeY into reflectedY
         
         dot_ConvertToPngPixels nodeX
         add 7 to nodeX
         dot_ConvertToPngPixels reflectedY
         add 7 to reflectedY
         put nodeX,reflectedY into reflectedLoc
         
         put reflectedLoc & CR after revPoints
         delete word 1 to 2 of drawPoints
      end repeat
   end if
   -- delete last char of revPoints
   put line 1 of revPoints after revPoints
   
   if pointNum = 4 then
      put line 2 of revPoints & "," & line 4 of revPoints into revRect
   else
      put empty into revRect
   end if
   return revPoints
end dot_ConvertDrawRect

function dot_ReflectPoint someLoc, gHeight
   -- was "graphViz_ReflectPoint"
   put item 1 of someLoc into nodeX
   put item 2 of someLoc into nodeY
   
   put gHeight - nodeY into reflectedY
   put nodeX,reflectedY into reflectedLoc
   return reflectedLoc
end dot_ReflectPoint


--> Dot | Header | Add
-
function dot_GetLayout dotText
   put "layout\s=\s'?(.+)'?" into regExp -- lazy
   replace "'" with quote in regExp
   if matchText (dotText, regExp, dotLayout) is true then
      return dotLayout
   else
      return empty
   end if
end dot_GetLayout

command dot_AddLayout @dotText, pGraphStyle
   put dot_CommandFromGraphStyle (pGraphStyle) into dotCommand
   --
   -- put "layout\s=\s'(.+)'" into regExp -- lazy
   put "layout\s=\s'?(.+)'?" into regExp -- lazy
   replace "'" with quote in regExp
   if matchChunk (dotText, regExp, sNum, eNum) is true then
      put dotCommand into char sNum to eNum of dotText
   else
      put offset ("{", dotText) into bracketNum
      put " layout =" && kwote (dotCommand) after char bracketNum of dotText
   end if
end dot_AddLayout

command dot_AddGraphMargin @dotText, xMargin, yMargin, useInches
   /*
   For graphs, this sets x and y margins of canvas, in inches. if the margin is a single double, both margins are set equal to the given value.
   */
   
   if yMargin is empty then put xMargin into yMargin
   put xMargin,yMargin into graphMargin
   if useInches is not true then dot_ConvertToInches graphMargin, (8*12)
   
   dot_AddGraphHeaderLine dotText, "margin", graphMargin, true
end dot_AddGraphMargin

command dot_AddGraphPadding @dotText, somePadding, useInches
   /*
   The pad attribute specifies how much, in inches, to extend the drawing area around the minimal area needed to draw the graph. 
   if the pad is a single double, both the x and y pad values are set equal to the given value.
   This area is part of the drawing and will be filled with the background color, if appropriate.
   
   Normally, a small pad is used for aesthetic reasons, especially when a background color is used,
   to avoid having nodes and edges abutting the boundary of the drawn region. 
   */
   
   if useInches is not true then dot_ConvertToInches somePadding, (8*12)
   dot_AddGraphHeaderLine dotText, "pad", somePadding, true
end dot_AddGraphPadding

on dot_AddGraphHeaderLine @dotText, headerKey, headerValue, kwoted
   /*
   Should not rely on lines and use text offset instead
   */
   
   put lineoffset("digraph ", dotText) into dotStartLineNum
   if dotStartLineNum = 0 then
      lcw_Notify "Need to add digraph header (and footer)?", true
      breakpoint
      return false
   end if
   
   put "graph [" into graphHeaderStart
   put "];" into graphHeaderEnd
   
   -- set the wholematches to true	# misses tab
   put lineoffset (graphHeaderStart, dotText, dotStartLineNum) into extraStartLineNum
   if extraStartLineNum = 0 then
      -- lets assume there is no header and add one
      put CR & tab & graphHeaderStart & CR & tab & graphHeaderEnd & CR after line dotStartLineNum of dotText
      put 1 + dotStartLineNum into startLineNum
      put 2 + dotStartLineNum into endLineNum
   else
      put dotStartLineNum + extraStartLineNum into startLineNum
      put lineoffset(graphHeaderEnd,dotText, startLineNum) into extraNum
      if startLineNum = 0 then
         lcw_Notify "Graph header is broken or non-standard!", true
         breakpoint
         return empty
      else
         put startLineNum + extraStartLineNum into endLineNum
      end if
   end if
   
   if kwoted is true then
      put tab & tab & headerKey & "=" & kwote(headerValue) & CR before line endLineNum of dotText
   else
      put tab & tab & headerKey & "=" & headerValue & CR before line endLineNum of dotText
   end if
end dot_AddGraphHeaderLine


--> Dot | Header | Props
-
command dot_StripGraphSize @dotText
   put dot_GetGraphHeader (dotText) into dotHeader
   put _ExtractHeaderArray (dotHeader) into headerArray
   delete local headerArray ["bb"]
   delete local headerArray ["size"]
   put dot_HeaderFromArrays (headerArray) into newHeader
   dot_SetHeader dotText, newHeader
   return dotText
end dot_StripGraphSize

command dot_ExtractGraphSize dotText, @graphWidth, @graphHeight
   -- was "xdot_ExtractGraphSize"
   repeat 5
      put dot_GetGraphHeader (dotText) into dotHeader
      if dotHeader is empty then exit repeat
      get _ExtractHeaderArray (dotHeader)
      if keys(headerArray) is empty then
         put it into headerArray
      else
         union it with headerArray
         put it into headerArray
      end if
      dot_SetHeader dotText
   end repeat
   _ExtractHeaderArrayDimensions headerArray, graphWidth, graphHeight 
end dot_ExtractGraphSize

command dot_AddGraphMargin @dotText, xMargin, yMargin, useInches
   /*
   For graphs, this sets x and y margins of canvas, in inches. if the margin is a single double, both margins are set equal to the given value.
   */
   
   if yMargin is empty then put xMargin into yMargin
   put xMargin,yMargin into graphMargin
   if useInches is not true then dot_ConvertToInches graphMargin, (8*12)
   
   dot_AddGraphHeaderLine dotText, "margin", graphMargin, true
end dot_AddGraphMargin

on dot_AddGraphPadding @dotText, somePadding, useInches
   /*
   The pad attribute specifies how much, in inches, to extend the drawing area around the minimal area needed to draw the graph. 
   if the pad is a single double, both the x and y pad values are set equal to the given value.
   This area is part of the drawing and will be filled with the background color, if appropriate.
   
   Normally, a small pad is used for aesthetic reasons, especially when a background color is used,
   to avoid having nodes and edges abutting the boundary of the drawn region. 
   */
   
   if useInches is not true then dot_ConvertToInches somePadding, (8*12)
   dot_AddGraphHeaderLine dotText, "pad", somePadding, true
end dot_AddGraphPadding

on dot_AddGraphHeaderLine @dotText, headerKey, headerValue, kwoted
   /*
   Should not rely on lines and use text offset instead
   */
   
   put lineoffset("digraph ", dotText) into dotStartLineNum
   if dotStartLineNum = 0 then
      lcw_Notify "Need to add digraph header (and footer)?", true
      breakpoint
      return false
   end if
   
   put "graph [" into graphHeaderStart
   put "];" into graphHeaderEnd
   
   -- set the wholematches to true	# misses tab
   put lineoffset (graphHeaderStart, dotText, dotStartLineNum) into extraStartLineNum
   if extraStartLineNum = 0 then
      -- lets assume there is no header and add one
      put CR & tab & graphHeaderStart & CR & tab & graphHeaderEnd & CR after line dotStartLineNum of dotText
      put 1 + dotStartLineNum into startLineNum
      put 2 + dotStartLineNum into endLineNum
   else
      put dotStartLineNum + extraStartLineNum into startLineNum
      put lineoffset(graphHeaderEnd,dotText, startLineNum) into extraNum
      if startLineNum = 0 then
         lcw_Notify "Graph header is broken or non-standard!", true
         breakpoint
         return empty
      else
         put startLineNum + extraStartLineNum into endLineNum
      end if
   end if
   
   if kwoted is true then
      put tab & tab & headerKey & "=" & kwote(headerValue) & CR before line endLineNum of dotText
   else
      put tab & tab & headerKey & "=" & headerValue & CR before line endLineNum of dotText
   end if
end dot_AddGraphHeaderLine


--> Dot | Header | Size
-
command dot_ResizeImage someView, dotGraphSize
   put the dot_Text of someView into dotText
   
   switch dotGraphSize
      -- put "0,0,3000,3000" into headerArray ["bb"]
      -- put the dot_BboxSize of someView into headerArray ["bb"]
      -- delete local headerArray ["size"]
      -- put the dot_BboxSize [false] of someView into headerArray ["bb"]
      case "none"
         put empty into newHeader
         break
      case "full"
         put empty into newHeader
         break
      default
         put the dot_InchSize [false] of someView into inchItems
         
   end switch
   
   put dot_GetGraphHeader (dotText) into oldHeader
   if oldHeader is empty then
      put empty into oldHeaderArray
      if inchItems is not empty then put "size =" && kwote(inchItems) into graphSize
      _ConstructDotHeaderArray dotPropertyArray
      put dot_ConstructHeader (graphSize, dotPropertyArray) into newHeader
   else
      put _ExtractHeaderArray (oldHeader) into headerArray
      -- put headerArray into oldHeaderArray
      delete local headerArray ["bb"]
      delete local headerArray ["size"]
      if inchItems is not empty then put inchItems into headerArray ["size"]
      put dot_HeaderFromArrays (headerArray) into newHeader
   end if
   
   dot_SetHeader dotText, newHeader
   set the dot_Text of someView to dotText
   return oldHeaderArray
end dot_ResizeImage


--> Dot | Geometry | Size
-
function dot_BboxSize someRect
   put item 3 of someRect - item 1 of someRect into someWidth
   put item 4 of someRect - item 2 of someRect into someHeight
   put 0,0,someWidth,someHeight into someRect
   return someRect
end dot_BboxSize

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
      case "image"
         put view_GetTemplateObject ("View|Image|OPN Image") into imageView
         put the rect of imageView into graphRect
         put dot_BboxSize (graphRect) into someRect
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


--> Dot | Header | Array
-
function dot_HeaderFromArrays dotHeaderArray, defaultNodePropertyArray, defaultEdgePropertyArray
   -- dot properties are used in the "graph" section of the dot header
   put keys(dotHeaderArray) into dotHeaderKeys
   if dotHeaderKeys is not empty then
      put "graph [" & CR after dotHeader
      set the itemdelimiter to "_"
      repeat for each line someKey in dotHeaderKeys
         -- let's assume they are named properly (otherwise need a switch statement)
         put dotHeaderArray [someKey] into someValue
         put tolower(item -1 of someKey) into dotParam
         put tab & dotParam & "=" & kwote(someValue) & CR after dotHeader -- could use comma's
      end repeat
      put "];" & CR after dotHeader
      put CR after dotHeader
   end if
   
   -- properties for a default node
   put keys(defaultNodePropertyArray) into nodeKeys
   if nodeKeys is not empty then
      put "node [" & CR after dotHeader
      repeat for each line someKey in nodeKeys
         put defaultNodePropertyArray [someKey] into someValue
         put someKey & "=" & kwote(someValue) & ";" & CR after dotHeader
      end repeat
      put "];" & CR after dotHeader
      put CR after dotHeader
   end if
   
   -- properties for a default edge
   put keys(defaultEdgePropertyArray) into edgeKeys
   if edgeKeys is not empty then
      put "edge [" & CR after dotHeader
      repeat for each line someKey in edgeKeys
         put defaultEdgePropertyArray [someKey] into someValue
         put someKey & "=" & kwote(someValue) & ";" & CR after dotHeader
      end repeat
      put "];" & CR after dotHeader
      put CR after dotHeader
   end if
   
   return word 1 to -1 of dotHeader
end dot_HeaderFromArrays


--> Private
-
command _ConstructDotHeaderArray @propertyArray, overlap, concentrate, splines, cluster, direction, dotOrder, defaultShape, defaultUrl
   put overlap into propertyArray ["overlap"]
   put concentrate into propertyArray ["concentrate"]
   put splines into propertyArray ["splines"]
   put cluster into propertyArray ["cluster"]
   put direction into propertyArray ["direction"]
   put dotOrder into propertyArray ["dotOrder"]
   put defaultShape into propertyArray ["defaultShape"]
   put defaultUrl into propertyArray ["defaultUrl"]
end _ConstructDotHeaderArray

private command _DeconstructDotHeaderArray pDotPropertyArray, @overlap, @concentrate, @splines, @cluster, @direction, @dotOrder, @defaultShape, @defaultUrl
   put pDotPropertyArray ["graphRect"] into graphRect
   put pDotPropertyArray ["overlap"] into overlap
   put pDotPropertyArray ["concentrate"] into concentrate
   put pDotPropertyArray ["splines"] into splines
   put pDotPropertyArray ["cluster"] into cluster
   put pDotPropertyArray ["direction"] into direction
   put pDotPropertyArray ["dotOrder"] into dotOrder
   put pDotPropertyArray ["defaultShape"] into defaultShape
   put pDotPropertyArray ["defaultUrl"] into defaultUrl
end _DeconstructDotHeaderArray

private command _SetGraphSectionOffsets @dotText, @startChar, @endChar
   # Trims top and tail of dotText
   put word 1 to -1 of dotText into dotText
   put 0 into startChar
   put 0 into endChar
   
   set the wholematches to true
   put wordOffset("graph", dotText) into wordNum
   if wordNum = 0 then return false
   
   put the number of chars of (word 1 to wordNum of dotText) - 4 into startChar
   put offset ("];", dotText, startChar) into skipNum  -- could use a regular expression here
   if wordNum = 0 then
      put 0 into startChar
      return false
   end if
   put startChar + skipNum + 1 into endChar
   return true
end _SetGraphSectionOffsets

private function _ExtractHeaderArray dotHeader
   -- was "dot_HeaderToArray"
   put text_GetBetween ("[", "]", dotHeader) into innerBit
   repeat for each line someLine in innerBit
      put word 1 to -1 of someLine into someLine
      if someLine is empty then next repeat
      repeat 50
         set the itemdelimiter to "="
         put word 1 to -1 of item 1 of someLine into someKey
         delete item 1 of someLine
         
         put word 1 of someLine into someValue
         if char -1 of someValue is comma then delete char -1 of someValue
         replace quote with empty in someValue
         delete word 1 of someLine
         
         put someValue into headerArray [someKey]
         
         if word 1 of someLine is comma then delete word 1 of someLine
         put word 1 to -1 of someLine into someLine
         if someLine is empty then exit repeat
      end repeat
   end repeat
   return headerArray
end _ExtractHeaderArray

