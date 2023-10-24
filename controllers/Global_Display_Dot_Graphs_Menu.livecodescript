script "Global | Display | Dot | Graphs | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Display | Dot | Graphs | Menu
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
   put the display_View of tObject into dView
   --
   put the displayed_Text of dView into dotGraphs
   put dot_ConstructNamedGraphArray (dotGraphs) into LocalArray ["namedGraphArray"]
   --
   return dView
end menu_Target

getprop displayGraph_Params
   put LocalArray ["namedGraphArray"] into namedGraphArray
   put keys (namedGraphArray) into gNames
   sort gNames
   return gNames
end displayGraph_Params


--> Global | Display | Dot | Graphs | Menu
-
on menu_DisplayGraph dView, gName
   put LocalArray ["namedGraphArray"] into namedGraphArray
   put namedGraphArray [gName] into dotText
   --
   put the linked_SvgView of dView into svgView
   put the linked_GraphView of svgView into graphView
   --
   put the dot_File of dView into dotFile
   put the graph_Style of dView into graphStyle
   
   switch
      case the shiftKey is "Down"
      case exists (svgView) is false
         display_Dot dotText, graphStyle, gName --, dotFile
         break
      default
         put gName & ".gv" into shortFile
         put folder_Above (dotFile) into dotFolder
         put dotFolder & shortFile into subgraphFile
         --
         put dotArray_Get (subgraphFile, graphStyle) into dotArray
         set the dot_Array of graphView to dotArray
   end switch
end menu_DisplayGraph

private on _
end _

on menu_SplitAndExport dView
   put the displayed_Text of dView into dotGraphs
   put the dot_File of dView into dotFile
   put folder_Above (dotFile) into dotFolder
   --
   dot_SplitAndSaveGraphs dotGraphs, dotFolder
   put the result into namedGraphArray
end menu_SplitAndExport

on submenu_Dev
   return menu_DevTitle ("Global | Display | Dot | Graphs | Menu")
end submenu_Dev
