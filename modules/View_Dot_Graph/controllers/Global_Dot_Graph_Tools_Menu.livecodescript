script "Global | Dot | Graph | Tools | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Dot | Graph | Tools | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the graph_View of tObject into graphView
   return graphView
end menu_Target

private function _ChooseDot dotName
   switch whichDot
      case "minimal"
         put dot_GetMinimal() into dotText
         break
      default
         put dot_MenuNameParamArray() into dotNameArray
         put dotNameArray [dotName] into dotURL
         put url dotURL into dotText
   end switch
   return dotText
end _ChooseDot

private function _FetchText dotURL, exportFormat
   put "dot" into dotCommand
   -- put dot_CommandFromGraphStyle (graphStyle) into dotCommand
   --
   put url dotURL into dotText
   --
   file_CreateText dotText
   put the result into dotFile
   -- 
   gv_DoShell dotFile, dotCommand, exportFormat
   put the result into dotText
   --
   return dotText
end _FetchText

getprop fetchDot_Params
   return dot_UrlNameMenu()
end fetchDot_Params

getprop fetchDotText_Params
   return dot_UrlNameMenu()
end fetchDotText_Params

getprop fetchDotArray_Params
   return dot_UrlNameMenu()
end fetchDotArray_Params

getprop fetchCmapx_Params
   return dot_UrlNameMenu()
end fetchCmapx_Params

getprop fetchPlain_Params
   return dot_UrlNameMenu()
end fetchPlain_Params

getprop testEdges_Params
   return dot_UrlNameMenu()
end testEdges_Params


--> Global | Dot | Graph | Tools | Menu
-
on menu_TestNodeRects graphView
   put the node_Objects of graphView into nodeObjects
   --
   lock screen
   repeat for each line nodeObject in nodeObjects
      put the node_Rect of nodeObject into nodeRect
      set the rect of nodeObject to nodeRect
   end repeat
   unlock screen
end menu_TestNodeRects

on menu_DisplayDotArray graphView
   put the dot_Array of graphView into dotArray
   --
   display_DotArray dotArray
end menu_DisplayDotArray

on menu_DisplayDotText graphView
   put the dot_Text of graphView into dotText
   --
   display_Text dotText, "Dot"
end menu_DisplayDotText

on _
end _

on menu_FetchDot indexView, whichDot
   put _ChooseDot (whichDot) into dotText
   display_Dot dotText
   put the result into svgFile
   --
   put url ("file:" & svgFile)
end menu_FetchDot

on menu_FetchDotText indexView, whichDot
   put _ChooseDot (whichDot) into dotText
   display_Text dotText
end menu_FetchDotText 

on menu_FetchDotArray indexView, whichDot
   put _ChooseDot (whichDot) into dotText
   put dot_CreateArray (dotText) into dotArray
   --
   display_Data dotArray, whichDot, "Dot"
   put the result into graphView
end menu_FetchDotArray

on menu_FetchCmapx indexView, whichDot
   put _ChooseDot (whichDot) into dotText
   --
   put graphViz_CreateCmapx (dotText)
end menu_FetchCmapx

on _
end _

on menu_TestEdges indexView, whichDot
   put _ChooseDot (whichDot) into dotText
   put dot_CreateArray (dotText) into dotArray
   --
   put the long id of group 1 of cd 1 of stack "Graphviz Presentation" into graphView
   dotArray_CreateEdges dotArray, graphView
end menu_TestEdges

on menu_TestRect graphView
   put the view_RectOnCard of graphView into viewRect
   put the rect of graphView into someRect
   rect_SetScaleVectors someRect, viewRect, scaleX, scaleY
   put min (scaleX, scaleY) into sFactor
   put the loc of graphView into scaleCentre
   --
   -- set the rect of graphView to viewRect
   rect_ScaleGroup graphView, sFactor, scaleCentre
   -- put viewRect
end menu_TestRect

on menu_DisplayGraphText graphView, exportFormat
   put "https://graphviz.org/Gallery/directed/go-package.gv.txt" into dotURL
   --
   put _FetchText (dotURL, exportFormat)
end menu_DisplayGraphText

on menu_ConstructLinkArray graphView
   put the link_Array of graphView into linkArray
   --
   display_Data linkArray
end menu_ConstructLinkArray
