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
command dotArray_CreateObjects dotArray, dotGroup
   set the showName of templateGraphic to true
   --
   put dotArray ["objects"] into objectsArray
   repeat with itemNum = 1 to item 2 of the extents of objectsArray
      put objectsArray [itemNum] into oArray
      put oArray ["name"] into oName
      --
      put oArray ["nodes"] into nodeArray
      switch
         case nodeArray is an array
            break
         default
            dotArray_CreateGraphic oArray, dotGroup
      end switch
      --
   end repeat
end dotArray_CreateObjects

command dotArray_CreateEdges dotArray, dotGroup
   set the showName of templateGraphic to true
   --
   put dotArray ["edges"] into edgesArray
   repeat with itemNum = 1 to item 2 of the extents of edgesArray
      put edgesArray [itemNum] into edgeArray
      _CreateEdge edgeArray, dotGroup
   end repeat
end dotArray_CreateEdges

command _CreateEdge edgeArray, dotGroup
   put edgeArray ["_draw_"][2]["points"] into pArray
   repeat with itemNum = 1 to item 2 of the extents of pArray
      put pArray [itemNum][1] into sPoint
      put pArray [itemNum][2] into item 2 of sPoint
      put sPoint & CR after edgePoints
   end repeat
   delete char -1 of edgePoints
   --
   put "Edge" && edgeArray ["_gvid"] into edgeName
   --
   reset templateGraphic
   set the style of the templateGraphic to curve
   set the points of the templateGraphic to edgePoints
   set the lineSize of the templateGraphic to 4
   set the endArrow of the templateGraphic to true
   set the showName of the templateGraphic to false
   --
   create graphic edgeName in dotGroup -- card cardNum of stack stackName
   put it into edgeObject
   --
   reset templateGraphic
   return edgeObject
end _CreateEdge


--> Dot | Array | Fetch
-
function dot_FetchArray dotURL
   put url dotURL into dotText
   --
   put dot_CreateArray (dotText) into dotArray
   --
   return dotArray
end dot_FetchArray

-- function dot_FetchArray dotURL
put url dotURL into dotText
--
file_CreateText dotText
put the result into dotFile
-- 
put dot_DoShell (dotFile, "dot", "json") into dotJSON
put json_ToArray(dotJSON) into dotArray
--
return dotArray
end dot_FetchArray


--> Dot | Construct
-
function dot_FromLinkArray linkArray, pGraphStyle, pBgColour, pConcentrate, pDefaultShape, pDefSection, pGraphName
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
   _ConstructDotHeaderArray dotPropertyArray, overlap, pConcentrate, splines, cluster, pDirection, dotOrder, pDefaultShape, defaultUrl
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
end dot_FromLinkArray

function dot_ConstructSingleNodeGraph nodeDotParams, graphName, someNodeID, graphSize
   -- not used?
   local dotNodeDefs, dotNodeLinks
   
   if someNodeID is empty then put the text of the nodeID_Field of me into someNodeID
   _ConstructDotHeaderArray dotPropertyArray
   put dot_ConstructHeader (graphSize) into graphHeader
   
   put dot_QuoteNode (someNodeID) into someNodeID
   put someNodeID && "[" &  nodeDotParams & "];" into nodeSection
   
   put graphHeader into dotText
   line_Insert nodeSection, dotText
   
   put "digraph" && graphName && "{" & return & outline_IncreaseIndent(dotText, 1) & CR & "}" into dotGraph
   return dotGraph
end dot_ConstructSingleNodeGraph

command dot_AddDefaultNode @graphHeaderBase, defaultShape
   if defaultShape is not empty then
      put "shape=" & defaultShape after nodeParams
   end if
   --
   put space & "style=" & kwote ("filled") after nodeParams
   put space & "fillcolor=" & kwote ("white")  after nodeParams
   --
   put "node [" & word 1 to -1 of nodeParams & "];" into defaultNodeBit
   --
   put CR&CR & defaultNodeBit after graphHeaderBase
end dot_AddDefaultNode

command dot_CreateGraph dotText, pTextFile, pGraphStyle
   if pGraphStyle is empty then
      put dot_GetLayout (dotText) into dotCommand
      if dotCommand is empty then
         put "dot" into dotCommand
      end if
   else
      put dot_CommandFromGraphStyle (pGraphStyle) into dotCommand
   end if
   --
   file_CreateText dotText, pTextFile
   put the result into dotFile
   --
   dot_CreateSvg dotFile, dotCommand
   put the result into svgFile
   --
   return svgFile
end dot_CreateGraph

command dot_CreateSvg dotFile, dotCommand, pSvgFile
   if pSvgFile is empty then
      set the itemdelimiter to "."
      if item -1 of dotFile = "dot" then
         put dotFile into pSvgFile
         put "svg" into item -1 of pSvgFile
      else
         put dotFile & ".svg" into pSvgFile
      end if
   end if
   --
   dot_RenderImage dotFile, pSvgFile, dotCommand, "svg"
   return pSvgFile
end dot_CreateSvg

function dot_Render dotText, pDotCommand, pTextFile, pOutputFormat
   -- pDotCommand is an english equivalent of graphStyle
   if pDotCommand is empty then put "dot" into pDotCommand
   if pImageFormat is empty then put "svg" into pImageFormat
   
   dot_SaveTemporaryFile dotText, pTextFile
   put the result into pTextFile
   --
   put dot_DoShell (pTextFile, pDotCommand, pImageFormat) into shellResult
   --
   if shellResult is false or shellResult is empty then
      exit to top
   else
      return shellResult
   end if
end dot_Render

command dot_RenderImage dotFile, svgFile, pDotCommand, pImageFormat
   if pDotCommand is empty then put "dot" into pDotCommand
   if pImageFormat is empty then put "svg" into pImageFormat
   --
   put pDotCommand into someShell
   put space & kwote (dotFile) after someShell
   put space & "-T" & pImageFormat after someShell
   put space & "-o" && kwote (svgFile) after someShell
   --
   put shell (someShell) into gvResult
   return gvResult
end dot_RenderImage

function dot_CommandFromGraphStyle pGraphStyle
   -- defaults to "dot"
   dot_NormalizeDotCommand pGraphStyle
   return pGraphStyle
end dot_CommandFromGraphStyle

command dot_NormalizeDotCommand @graphStyle
   switch
      case graphStyle is among the items of "spring,neato"
         /*
         draws undirected graphs using ``spring'' models
         (see Kamada and Kawai, Information Processing Letters 31:1, April 1989).
         */
         put "neato" into graphStyle
         break
      case graphStyle is among the items of "circular,circo"
         /*
         draws graphs using a circular layout (see Six and Tollis, GD '99 and ALENEX '99, and Kaufmann and Wiese, GD '02.)  
         The tool identifies biconnected components and draws the nodes of the component on a circle. 
         The block-cutpoint tree is then laid out using a recursive radial algorithm. 
         Edge crossings within a circle are minimized by placing as many edges on the circle's perimeter as possible.  
         In particular, if the component is outerplanar, the component will have a planar layout.
         
         If a node belongs to multiple non-trivial biconnected components, the layout puts the node in one of them.
         By default, this is the first non-trivial component found in the search from the root component.
         */
         put "circo" into graphStyle
         break
      case graphStyle is among the items of "radial,twopi"
         /*
         draws graphs using a radial layout (see G. Wills, Symposium on Graph Drawing GD'97, September, 1997).  
         Basically, one node is chosen as the center and put at the origin.  
         The remaining nodes are placed on a sequence of concentric circles centered about the origin, 
         each a fixed radial distance from the  previous  circle.   
         All  nodes distance 1 from the center are placed on the first circle;
         all nodes distance 1 from a node on the first circle are placed on the second circle; and so forth.
         */
         put "twopi" into graphStyle
         break
      case graphStyle is among the items of "undirected spring,fdp"
         /*
         filter for drawing undirected graphs
         draws undirected graphs using a "spring'' model. 
         It relies on a force-directed approach in the spirit of Fruchterman and Reingold 
         (cf. Software-Practice & Experience 21(11), 1991, pp. 1129-1164).
         */
         put "fdp" into graphStyle
         break
      case graphStyle is among the items of "fast spring,fast undirected spring,sfdp"
         -- sfdp - filter for drawing large undirected graphs
         /*
         also draws undirected graphs using the "spring'' model described above, 
         but it uses a multi-scale approach to produce layouts of large graphs in a reasonably short time.
         */
         -- changed to "fdp" as the graphs are ugly otherwise -- hack
         put "fdp" into graphStyle
         break
      default
         /*
         draws  directed  graphs.
         It works well on DAGs and other graphs that can be drawn as hierarchies.  
         */
         put "dot" into graphStyle
   end switch
end dot_NormalizeDotCommand


--> Private
-
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

private command array_AddToIndex newLines, someKey, @someArray
   -- if the number of lines of keys(someArray) > 5 and someKey contains "form_IsRed" then breakpoint
   put someArray [someKey] into someIndex
   line_AddToIndex newLines, someIndex
   put word 1 to -1 of someIndex into someArray [someKey]
   return the number of lines of someIndex
end array_AddToIndex

private command line_AddToIndex newLines, @someIndex
   repeat for each line someLine in newLines
      line_Add someLine, someIndex
   end repeat
   if line 1 of someIndex is empty then delete line 1 of someIndex
end line_AddToIndex

private command line_Add someLines, @someIndex
   repeat for each line someLine in someLines
      if someLine is empty then next repeat
      set the wholematches to true
      put lineoffset(someLine, someIndex) into lineNum
      if lineNum is 0 then
         put the number of lines of someIndex into maxLine
         put maxLine + 1 into lineNum
         put someLine into line lineNum of someIndex
      else
         put lineNum & comma after lineNums
      end if
   end repeat
   delete char -1 of lineNums
   return lineNums
end line_Add

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


