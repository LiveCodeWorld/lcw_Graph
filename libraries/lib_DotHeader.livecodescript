script "lib_DotHeader"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DotHeader
type: library
version: 0.1

/*Some help*/


--> Working on
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


--> Dot | Header | Array
-
command dotHeader_ConstructArray @propertyArray, overlap, concentrate, splines, cluster, direction, dotOrder, defaultShape, defaultUrl
   put overlap into propertyArray ["overlap"]
   put concentrate into propertyArray ["concentrate"]
   put splines into propertyArray ["splines"]
   put cluster into propertyArray ["cluster"]
   put direction into propertyArray ["direction"]
   put dotOrder into propertyArray ["dotOrder"]
   put defaultShape into propertyArray ["defaultShape"]
   put defaultUrl into propertyArray ["defaultUrl"]
end dotHeader_ConstructArray

command dotHeader__DeconstructArray pDotPropertyArray, @overlap, @concentrate, @splines, @cluster, @direction, @dotOrder, @defaultShape, @defaultUrl
   -- only used in lib_DotHeader
   put pDotPropertyArray ["graphRect"] into graphRect
   put pDotPropertyArray ["overlap"] into overlap
   put pDotPropertyArray ["concentrate"] into concentrate
   put pDotPropertyArray ["splines"] into splines
   put pDotPropertyArray ["cluster"] into cluster
   put pDotPropertyArray ["direction"] into direction
   put pDotPropertyArray ["dotOrder"] into dotOrder
   put pDotPropertyArray ["defaultShape"] into defaultShape
   put pDotPropertyArray ["defaultUrl"] into defaultUrl
end dotHeader__DeconstructArray


--> Dot | Header | Construct
-
function dot_ConstructHeaderArray overlap, splines, defaultShape, defaultUrl
   local dotHeaderArray, cluster, direction, dotOrder
   put true into concentrate
   put false into overlap
   put true into splines
   put "rectangle" into defaultShape
   
   dotHeader_ConstructArray dotHeaderArray, overlap, concentrate, splines, cluster, direction, dotOrder, defaultShape, defaultUrl
   return dotHeaderArray
end dot_ConstructHeaderArray

function dot_ConstructHeaderBase graphSize, dotPropertyArray, graphStyle, pUseInches  
   dotHeader__DeconstructArray dotPropertyArray, overlap, concentrate, splines, cluster, direction, dotOrder, defaultShape, defaultUrl
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
      switch someValue
         case empty
            next repeat
         case true
         case false
            put someKey & "=" & someValue & CR after graphHeaderBase
            break
         default
            put someKey & "=" & kwote(someValue) & CR after graphHeaderBase
      end switch
   end repeat
   
   -- dot_AddDefaultNode
   delete char -1 of graphHeaderBase
   return graphHeaderBase
end dot_ConstructHeaderBase


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
   put dot_LayoutEngine (pGraphStyle) into dotCommand
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
command dotHeader_ConstructArray @propertyArray, overlap, concentrate, splines, cluster, direction, dotOrder, defaultShape, defaultUrl
   put overlap into propertyArray ["overlap"]
   put concentrate into propertyArray ["concentrate"]
   put splines into propertyArray ["splines"]
   put cluster into propertyArray ["cluster"]
   put direction into propertyArray ["direction"]
   put dotOrder into propertyArray ["dotOrder"]
   put defaultShape into propertyArray ["defaultShape"]
   put defaultUrl into propertyArray ["defaultUrl"]
end dotHeader_ConstructArray

private command _SetGraphSectionOffsets @dotText, @startChar, @endChar
   # Trims top and tail of dotText
   put word 1 to -1 of dotText into dotText
   put 0 into startChar
   put 0 into endChar
   
   set the wholematches to true
   put wordOffset("graph", dotText) into wordNum
   if wordNum = 0 then
      put wordOffset("digraph", dotText) into wordNum
   end if
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
