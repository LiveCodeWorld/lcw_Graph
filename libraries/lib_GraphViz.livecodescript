script "lib_GraphViz"
--> MetaData
-
license: GPLv3
name: lib_GraphViz
type: library
version: 1.0
copyright: David Bovill


/* libOPN_GraphViz
A library for interfacing with the GraphViz command line utitlites.

What is the coordinate transformation between the graph bb and a .png image?

1. The bb is expanded by 4 graph-units in all directions (pad) to allow for finite line widths.
2. then it is zoomed and/or rotated according to -Gviewport, -Gsize, -Glandscape, -Gorientation options. 
At the default scaling of 1:1, one graph unit = 1 point (1/72 inch).
3. then it is paginated, if requested by -Gpage and if the output format supports it. Not the -Tpng renderer, yet.
4. then a margin is added, -Gmargin, in absolute units (inches). The top/bottom margin can be set independently of the left/right margin.
5. then it is converted to device units, according to -Gdpi, or a dpi value that is given by the output device, or a default that is provided by each render. There are separate dpi values for x and y to allow for non-square pixels. Some renderers invert the Y axis and need an offset to place the origin in the top left corner. The default dpi for -Tpng is 96dpi (approximating the resolution of most computer monitors) so this is where the scaling by 96/72 (4/3) comes from. 

At the renderer api, plugins have a choice of coordinate representation:

* coordinates in graph-units, and composite transformation data consisting of: scaling, rotation, and translation. (used by svg, cairo, ps, renderers)
* coordinates pre-transformed into device units. 

At present, most device-independent units are either inches or points, which we take as 72 points per inch. 
*/

--> Working on
-

--> Graph | Model
-
/*
This model contains the data needed to determine how a graph is drawn from a given dot file.
*/

getprop graph_Model -- old
   -- add this handler locally to override default bahaviour
   -- and create local models for each graph
   
   return the long id of me
end graph_Model


--> GraphViz | Latest
-
function gv_DecomposeDotFile dotFile
   _SetDefaultDotFoler dotFile, shortFile, dotFolder, oFolder
   --
   set the defaultfolder to dotFolder
   put merge ("ccomps -x [[shortFile]]") into someShell
   put shell (someShell) into sResult
   --
   set the defaultfolder to oFolder
   return sResult
end gv_DecomposeDotFile

function gv_RecomposeDotFile dotFile, pOutputType
   if pOutputType is empty then
      put "json" into pOutputType
   end if
   --
   _SetDefaultDotFoler dotFile, shortFile, dotFolder, oFolder
   --
   set the defaultfolder to dotFolder
   put merge ("ccomps -x [[shortFile]] | dot | gvpack | neato -s -n2 -T[[pOutputType]]") into someShell
   put shell (someShell) into sResult
   --
   set the defaultfolder to oFolder
   --
   return sResult
end gv_RecomposeDotFile

private command _SetDefaultDotFoler dotFile, @shortFile, @dotFolder, @oFolder
   put the defaultfolder into oFolder
   set the itemdelimiter to slash
   put item -1 of dotFile into shortFile
   put dotFile into dotFolder
   put empty into item -1 of dotFolder
   return oFolder
end _SetDefaultDotFoler


--> GraphViz
-
function graphviz_ColourOutline
   /*
   Can be used to create a (sub)menu.
   
   Displays all X11 colours,
   or or at least the colours that rev and Graphviz understands
   */
   
   put colour_BaseColourOutline() into graphvizColours
   put "Light Green,Dark Magenta" into dodgyColours
   replace comma with CR in dodgyColours
   line_Delete dodgyColours, graphvizColours
   return graphvizColours
end graphviz_ColourOutline


--> Dot
-
function dot_ConvertToXml dotFile, pOutputFile
   put "gv2gxl" into someShell
   shell_BashParamEscape dotFile
   put space && dotFile after someShell
   if pOutputFile is not empty then
      put "-o" & pOutputFile after someShell -- single space I think
   end if
   put git_ExecuteShellCommand (someShell) into shellResult
   return shellResult
end dot_ConvertToXml

on graph_DeconstructPropertyArray dotPropertyArray, @nodeIDs, @flattenNum
   put dotPropertyArray ["nodeIDs"] into nodeIDs
   put dotPropertyArray ["flattenNum"] into flattenNum
end graph_DeconstructPropertyArray

on graph_ConstructPropertyArray @dotPropertyArray, nodeIDs, flattenNum
   if flattenNum is empty then put the overlay_FlattenNum of the graph_Model of the target into flattenNum
   
   put nodeIDs into dotPropertyArray ["nodeIDs"]
   put flattenNum into dotPropertyArray ["flattenNum"]
end graph_ConstructPropertyArray


--> Dot | Props
-
function dot_OutputFormats
   -- was "dot_GetOutputFormats"
   return "jpg,png,gif,-,canon,cmap,cmapx,dia,dot,epdf,fig,hpgl,imap,ismap,mif,mp,pcl,pdf,pic,plain,plain-ext,ps,ps2,svg,svgz,vtx,xdot"
end dot_OutputFormats

function dot_OutputMainFormats
   return "jpg,png,gif,-,pdf,ps,ps2,svg,-,cmapx,dot,plain,plain-ext,xdot"
end dot_OutputMainFormats

function dot_ImageFormats
   -- the ones Rev can render
   return "jpg,png,gif"
end dot_ImageFormats

function dot_OutputImageFormats
   return "jpg,png,gif,pdf,ps,ps2,svg,svgz"
end dot_OutputImageFormats

function dot_OutputTextFormats
   return "cmap,cmapx,dot,imap,ismap,plain,plain-ext,xdot,-,json,json0,dot_json,xdot_json"
end dot_OutputTextFormats

function dot_OutputStrangeFormats
   return "canon,dia,epdf,fig,hpgl,pdf,pic,ps,ps2,vtx"
end dot_OutputStrangeFormats


--> Dot
-
function dot_TestDataFolder shortFile, pDontCreate
   return library_PluginFolder ("opn_TestData/dot/", pDontCreate) & shortFile
end dot_TestDataFolder

function dot_GetTestData shortFile  
   put dot_TestDataFolder (shortFile) into someFile
   put url ("file:" & someFile) into dotText
   return dotText
end dot_GetTestData

command dot_SetTestData shortFile, dotText
   put dot_TestDataFolder () into dotFolder
   folder_CreateNested dotFolder
   put dotFolder & shortFile into someFile
   put dotText into url ("file:" & someFile)
end dot_SetTestData

command dot_DeconstructTextResult dotTextResult, @dotText, @dotError
   repeat with firstLineNum = 1 to the number of lines of dotTextResult
      if word 1 of line firstLineNum of dotTextResult = "digraph" then
         exit repeat
      end if
   end repeat
   put line firstLineNum to -1 of dotTextResult into dotText
   put line 1 to (firstLineNum - 1) of dotTextResult into dotError
end dot_DeconstructTextResult

function dot_GetLinkSection linkArray
   local nodeLinks
   repeat for each key fromLink in linkArray
      put linkArray [fromLink] into toLinks
      dot_NormalizeNode fromLink
      repeat for each line toLink in toLinks
         dot_NormalizeNode toLink
         put fromLink && "->" && toLink & ";" & CR after nodeLinks
      end repeat
   end repeat
   return nodeLinks
end dot_GetLinkSection

on dot_NormalizeNode @someNode
   replace quote with empty in someNode
   if the number of words of someNode > 1 then
      put kwote(someNode) into someNode
   end if
end dot_NormalizeNode


--> Dot | Files
-
command dot_SaveAndDisplayImage someImage, imageView, imageFile
   if imageView is empty then put default_FirstStackControl ("View|Image|OPN Image") into imageView
   if imageFile is empty then put dot_LabelFileWithGraphStyle (graphStyle, dotFile) into imageFile
   
   file_CreateImage someImage, imageFile
   set the image_File of imageView to imageFile
   object_GoTo imageView
end dot_SaveAndDisplayImage


--> Dot | Render
-
function dot_CheckResult gvResult, outputFormat, someShell
   if outputFormat is among the items of "png,jpeg,jpg,gif" then
      set the itemdelimiter to ":"
      switch item 1 of gvResult
         case "Error"
            lcw_Notify gvResult
            break
         case "Warning"
            lcw_Notify (line 1 of gvResult), true
            repeat while item 1 of line 1 of gvResult is "Warning"
               delete line 1 of gvResult
            end repeat
            return gvResult
         case "Assertion failed"
            lcw_Notify (line 1 of gvResult), true
            put gvResult
            return gvResult
         default
            return gvResult
      end switch
   else
      return gvResult
   end if
end dot_CheckResult


--> Dot | Node Defs
-
function dot_NodeDefFromDataArray dgArray
   repeat for each key indexNum in dgArray
      put dgArray [indexNum] into defLineArray
      put defLineArray ["id"] into nodeID
      put dot_NodeDefLineFromArray (nodeID, defLineArray) & CR after nodeDefs
   end repeat
   delete char -1 of nodeDefs
   return nodeDefs
end dot_NodeDefFromDataArray

function dot_NodeDefFromArray nodeDefArray
   repeat for each key nodeID in nodeDefArray
      put nodeDefArray [nodeID] into defLineArray
      put dot_NodeDefLineFromArray (nodeID, defLineArray) & CR after nodeDefs
   end repeat
   delete char -1 of nodeDefs
   return nodeDefs
end dot_NodeDefFromArray

function dot_NodeDefLineFromArray nodeID, defLineArray
   put nodeID && "[" into defLine
   delete local defLineArray ["id"] -- in case it is a data array with an "id" value"
   repeat for each key defProperty in defLineArray
      put defLineArray [defProperty] into defValue
      if defValue is a number then 
         put defProperty & "=" & defValue after defLine
      else
         put defProperty & "=" & kwote(defValue) after defLine
      end if
      put ", " after defLine
   end repeat
   put "];" into char -2 to -1 defLine
   return defLine
end dot_NodeDefLineFromArray


--> Dot | Formats
-
function dot_MakeSpringText dotFile
   -- neato /Users/david/.Trash/dot.dot -Tepdf
   shell_BashParamEscape dotFile
   put merge  ("neato [[dotFile]]") into someShell
   
   put graphViz_GetShellPath() into gvPath
   put gvPath & someShell into someShell
   return shell(someShell)
end dot_MakeSpringText


--> Dot | Draw
-
function dot_MakeSpringImage dotFile
   -- neato /Users/david/.Trash/dot.dot -Tepdf
   shell_BashParamEscape dotFile
   put merge("neato -Tpng [[dotFile]]") into someShell
   
   put graphViz_GetShellPath() into gvPath
   put gvPath & someShell into someShell
   return shell(someShell)
end dot_MakeSpringImage

function dot_MakeCircular dotFile
   /*
   circodraws graphs using a circular layout (see Six and Tollis, GD ’99 and ALENEX ’99, and Kaufmann 
   and Wiese, GD ’02.) The tool identifies biconnected components and draws the nodes of the component on 
   acircle. The block-cutpoint tree is then laid out using a recursive radial algorithm. Edge crossings within a 
   circle are minimized by placing as manyedges on the circle’sperimeter as possible. In particular, if the 
   component is outerplanar,the component will have a planar layout. 
   If a node belongs to multiple non-trivial biconnected components, the layout puts the node in one of them. 
   By default, this is the first non-trivial component found in the search from the root component. 
   
   circo ["Gname=value] ["Nname=value]["Ename=value]["Tlang]["llibfile]["ooutfile]["vV][files] 
   */
   
   shell_BashParamEscape dotFile
   put merge("circo -Tpng [[dotFile]]") into someShell
   
   put graphViz_GetShellPath() into gvPath
   put gvPath & someShell into someShell
   return shell(someShell)
end dot_MakeCircular

function dot_MakeRadial dotFile
   /*
   draws graphs using a radial layout. 
   Basically, one node is chosen as the center and put at the origin. 
   The remaining nodes are placed on a sequence of concentric circles centered about the origin, 
   each a fixed radial distance from the previous circle.
   */
   
   -- twopi /Users/david/.Trash/dot.dot -Tepdf
   shell_BashParamEscape dotFile
   put merge("twopi [[dotFile]] -Tepdf") into someShell
   
   put graphViz_GetShellPath() into gvPath
   put gvPath & someShell into someShell
   return shell(someShell)
end dot_MakeRadial

function dot_MakeRadialImage dotFile
   -- twopi /Users/david/.Trash/dot.dot -Tepdf
   shell_BashParamEscape dotFile
   put merge("twopi [[dotFile]] -Tpng") into someShell
   
   put graphViz_GetShellPath() into gvPath
   put gvPath & someShell into someShell
   put shell(someShell) into gvResult
   return dot_CheckResult(gvResult)
end dot_MakeRadialImage


--> Dot | Shell
-
command dot_DoImageMapShell dotCommand, dotFile, imageFile, pCmapFile, pXdotFile, pImageFormat
   -- dot foo.gv -Tpng -o foo.png -Tcmapx -o foo.cmapx
   dot_GraphStyleToLayoutEngine dotCommand -- converts a graphStyle to a dotCommand
   if pImageFormat is empty then put "png" into pImageFormat
   shell_BashParamEscape dotFile
   shell_BashParamEscape imageFile
   shell_BashParamEscape pCmapFile
   shell_BashParamEscape pXdotFile
   
   -- put gvPath & dotCommand into someShell
   put dotCommand into someShell
   -- put space & quote & dotFile & quote after someShell
   put space & dotFile after someShell
   
   put space & "-T" & pImageFormat after someShell
   -- put space & "-o" && quote & imageFile & quote after someShell
   put space & "-o" && imageFile after someShell
   
   if pCmapFile is not empty then
      put space & "-Tcmapx" after someShell
      -- put space & "-o" && quote & pCmapFile & quote after someShell
      put space & "-o" && pCmapFile after someShell
   end if
   
   if pXdotFile is not empty then
      put space & "-Txdot" after someShell
      -- put space & "-o" && quote & pXdotFile & quote after someShell
      put space & "-o" && pXdotFile after someShell
   end if
   
   put shell (someShell) into gvResult
   put dot_CheckResult (gvResult, "png", someShell) into shellResult
   return shellResult
end dot_DoImageMapShell

function graphViz_GetShellPath
   put pref_GetValue ("dotPath") into dotPath
   return dotPath
   
   return "/opt/local/bin/"
   return "/Applications/Graphviz.app" & "/Contents/MacOS/" into graphVizShellPath
end graphViz_GetShellPath

on graphViz_SetShellPath dotPath
   pref_SetValue "dotPath", dotPath
end graphViz_SetShellPath


--> Dot | Shell | Text
-
function graphViz_CreateCmapx dotText
   -- dot foo.dot -Nhref=\\N -Tcmpax -o foo.map -Tpng -o foo.png
   file_CreateText dotText
   put the result into someFile
   
   put graphViz_GetShellPath() into gvPath
   put gvPath & "dot -Nhref=\\N -Tcmapx" && quote & someFile & quote into someShell
   get shell(someShell)
   return it
end graphViz_CreateCmapx


--> Dot | Shell | Other
-
function dot_StripLeastConected dotFile, minConnected
   if minConnected is empty then put 1 into minConnected
   shell_BashParamEscape dotFile
   
   put merge("gvpr -i 'N[$.degree > [[minConnected]]]'") && dotFile into someShell
   
   put graphViz_GetShellPath() into gvPath
   put gvPath & someShell into someShell
   return shell(someShell)
end dot_StripLeastConected

function dot_ExtractConnected dotFile
   shell_BashParamEscape dotFile
   put merge("sccmap -d [[dotFile]]") into someShell
   
   put graphViz_GetShellPath() into gvPath
   put gvPath & someShell into someShell
   return shell(someShell)
end dot_ExtractConnected

function dot_Biconected dotFile
   /*
   decomposes graphs into their biconnected components, printing the components to standard output. 
   */
   
   shell_BashParamEscape dotFile
   put merge("bcomps [[dotFile]]") into someShell
   
   put graphViz_GetShellPath() into gvPath
   put gvPath & someShell into someShell
   return shell(someShell)
end dot_Biconected

function dot_Tred dotFile
   /*
   Computes the transitive reduction of directed graphs, and prints the resulting graphs to standard output. 
   This removes edges implied by transitivity. Nodes and subgraphs are not otherwise affected. 
   The “meaning” and validity of the reduced graphs is application dependent. 
   tred is particularly useful as a preprocessor to dot to reduce clutter in dense layouts. 
   */
   shell_BashParamEscape dotFile
   put merge("tred [[dotFile]]") into someShell
   
   put graphViz_GetShellPath() into gvPath
   put gvPath & someShell into someShell
   return shell(someShell)
end dot_Tred

function dot_UnFlatten dotFile, someNum
   -- unflatten[?f][?llen][?clen][?ooutfile][files ] 
   
   put url ("file:" & dotFile) into dotText
   shell_BashParamEscape dotFile
   if someNum is empty then put 12 into someNum
   put merge("unflatten -f -l [[someNum]] -c [[someNum]] [[dotFile]]") into someShell
   
   put graphViz_GetShellPath() into gvPath
   put gvPath & someShell into someShell
   
   put shell(someShell) into gvResult
   return gvResult
   put dot_CheckResult(gvResult, "png", someShell) into shellResult
   return shellResult
end dot_UnFlatten

function dot_MakeAcyclic dotFile
   /*
   acyclicis a filter that takes a directed graph as input and outputs a copyofthe graph with sufficient edges 
   reversed to makethe graph acyclic. The reversed edge inherits all of the attributes of the original edge. The 
   optional file argument specifies where the the input graph is stored; by default, the program reads from 
   stdin. 
   */
   -- acyclic[?nv? ][?ooutfile][ file]
   shell_BashParamEscape dotFile
   put merge("acyclic [[dotFile]]") into someShell
   
   put graphViz_GetShellPath() into gvPath
   put gvPath & someShell into someShell
   return shell(someShell)
end dot_MakeAcyclic

function dot_AcyclicInfo dotFile, acyclicFile
   shell_BashParamEscape dotFile
   shell_BashParamEscape acyclicFile
   put merge("acyclic -v -o [[acyclicFile]] [[dotFile]]") into someShell
   
   put graphViz_GetShellPath() into gvPath
   put gvPath & someShell into someShell
   return shell(someShell)
end dot_AcyclicInfo


--> Dot | Colours
-
function dot_RGBToHex rgbColour
   -- was "graphViz_RGBToHex"
   if rgbColour is empty or rgbColour is "none" then
      return empty
   else if rgbColour is among the lines of the colornames then
      return rgbColour
   else
      put quote & colour_RgbToHex (rgbColour) & quote into webColour
      return webColour
   end if
end dot_RGBToHex


--> Dot | Utilities
-
on dot_EscapeQuotes @someLabel
   replace quote with ("\" & quote) in someLabel
end dot_EscapeQuotes

function dot_QuoteNode someNodeID
   -- comma's and other chars can also result in badly named nodes.
   if the number of words of someNodeID > 1 or char 1 of someNodeID is a number then
      return kwote(someNodeID)
   else
      return someNodeID
   end if
end dot_QuoteNode

