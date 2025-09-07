script "Global | Graph | Lines | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Graph | Lines | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop displayGraphText_Params
   return dot_OutputTextFormats()
end displayGraphText_Params

function _FetchText dotURL, exportFormat
   put "dot" into dotCommand
   -- put dot_LayoutEngine (graphStyle) into dotCommand
   --
   put url dotURL into dotText
   --
   file_CreateText dotText
   put the result into dotFile
   -- 
   put dot_DoShell (dotFile, dotCommand, exportFormat) into dotText
   --
   return dotText
end _FetchText

command dotArray_CreateObjects dotArray, cardNum, stackName
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
            _CreateGraphic oArray, cardNum, stackName
      end switch
      --
   end repeat
end dotArray_CreateObjects

command _CreateGraphic oArray, cardNum, stackName
   put oArray ["name"] into oName
   put oArray ["label"] into oLabel
   put oArray ["shape"] into oShape
   put oArray ["style"] is "filled" into isOpaque
   --
   create graphic oName in card cardNum of stack stackName
   put it into gObject
   --
   set the label of gObject to oLabel
   set the opaque of gObject to isOpaque
   --
   switch
      case nodeArray is an array
         return empty
      case oShape = "box"
         -- set the style of gObject to "rectangle"
         -- set the rect of gObject to oRect
         put _GetDrawPoints (oArray) into gPoints
         set the style of gObject to "polygon"
         set the points of gObject to gPoints
         break
      case oShape = "ellipse"
      case oShape = "circle"
         set the style of gObject to "oval"
         --
         put _GetDrawRect (oArray) into oRect
         set the rect of gObject to oRect
         break
      case oShape = "triangle"
         -- set the style of gObject to "regular"
         -- set the polysides of gObject to 3
         set the style of gObject to "polygon"
         put _GetDrawPoints (oArray) into gPoints
         set the points of gObject to gPoints
         break
      case oShape = "diamond"
         -- set the style of gObject to "regular"
         -- set the polysides of gObject to 4
         --
         set the style of gObject to "polygon"
         put _GetDrawPoints (oArray) into gPoints
         set the points of gObject to gPoints
         break
      case oShape = "pentagon"
         set the style of gObject to "regular"
         set the polysides of gObject to 5
         break
      default
         set the style of gObject to "oval"
   end switch
   --
   return gObject
end _CreateGraphic

function _GetDrawPoints oArray
   get oArray ["_draw_"]
   put it [3]["points"] into pArray
   repeat with itemNum = 1 to item 2 of the extents of pArray
      put pArray [itemNum][1] into item 1 of pLoc
      put pArray [itemNum][2] into item 2 of pLoc
      put pLoc & CR after gPoints
   end repeat
   -- delete char -1 of gPoints
   put line 1 of gPoints after gPoints
   return gPoints
end _GetDrawPoints

function _GetDrawRect oArray
   get oArray ["_draw_"]
   put it [3]["rect"] into rArray
   put rArray [1] into item 1 of oRect
   put rArray [2] into item 3 of oRect
   put rArray [3] into item 4 of oRect
   put rArray [1] into item 2 of oRect
   return oRect
end _GetDrawRect


--> Global | Graph | Lines | Menu
-
on menu_ParseExample
   put "https://graphviz.org/Gallery/gradient/colors.gv.txt" into dotURL
   --
   put dot_FetchArray (dotURL) into dotArray
   --
   put dotArray ["bb"] into bb
   put item 3 of bb into sWidth
   put item 4 of bb into sHeight
   put line 2 of the screenrects into sRect
   --
   put "Graphviz Presentation" into stackName
   put 1 into cardNum
   --
   -- create invisible stack stackName
   -- set the rect of stack stackName to sRect
   put the rect of card 1 of stack stackName into cRect
   put rect_FromWidthAndHeight (cRect, sWidth, sHeight) into bbRect
   --
   put the long id of card cardNum of stack stackName into cObject
   if exists (graphic "bb" of cObject) is false then
      set the opaque of templateGraphic to true
      set the backgroundcolor of templateGraphic to "red"
      --
      create graphic "bb" in card cardNum of stack stackName
      put it into cGraphic
      set the rect of cGraphic to bbRect
   end if
   --
   dotArray_CreateObjects dotArray, cardNum, stackName
   --
   choose browse tool
   show stack stackName
   -- put bbRect
end menu_ParseExample

private on _
end _

on menu_GoPackageExample indexView
   put url "https://graphviz.org/Gallery/directed/go-package.gv.txt" into dotText
   --
   display_Dot dotText
end menu_GoPackageExample

on menu_CreateDotText
   put url "https://graphviz.org/Gallery/directed/go-package.gv.txt" into dotText
   --
   put graphViz_CreateCmapx (dotText)
end menu_CreateDotText

on menu_GoPackageArray indexView
   put url "https://graphviz.org/Gallery/directed/go-package.gv.txt" into dotText
   file_CreateText dotText
   put the result into dotFile
   -- 
   put dot_DoShell (dotFile, "dot", "json") into dotJSON
   put json_ToArray(dotJSON) into dotArray
   --
   display_Data dotArray, "go-package.gv.txt", "Dot"
   put the result into displayView
end menu_GoPackageArray

private on __
end __

on menu_Shapes
   put "https://graphviz.org/Gallery/gradient/colors.gv.txt" into dotURL
   --
   display_DotUrl dotURL
   --
   put _FetchText (dotURL, "plain")
end menu_Shapes

on menu_DisplayGraphText displayView, exportFormat
   put "https://graphviz.org/Gallery/directed/go-package.gv.txt" into dotURL
   --
   put _FetchText (dotURL, exportFormat)
end menu_DisplayGraphText
