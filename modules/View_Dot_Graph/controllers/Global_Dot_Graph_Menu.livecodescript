script "Global | Dot | Graph | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Dot | Graph | Menu
type: controller
version: 0.1

/*
This menu is for use with the "View|Dot|Graph" module.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put tObject into LocalArray [tObject]
   
   put dot_MenuNameParamArray() into dotNameArray
   put keys (dotNameArray) into nameMenu
   replace CR with comma in nameMenu
   --
   put dotNameArray into LocalArray ["dotNameArray"]
   put nameMenu & ",-,minimal" into LocalArray ["nameMenu"]
   --
   put the graph_View of tObject into graphView
   return graphView
end menu_Target

getprop disabled_RevealDotFolder [graphView]
   put the dot_Folder of graphView into dotFolder
   return dotFolder is empty
end disabled_RevealDotFolder

getprop displayDotUrl_Param [graphView]
   return the dot_Name of graphView
end displayDotUrl_Param

getprop displayDotUrl_Params
   return LocalArray ["nameMenu"] -- dot_UrlNameMenu()
end displayDotUrl_Params

getprop setDotUrl_Param [graphView]
   return the dot_Name of graphView
end setDotUrl_Param

getprop setDotUrl_Params
   return LocalArray ["nameMenu"] -- dot_UrlNameMenu()
end setDotUrl_Params

getprop nodeShape_Param [nodeObject]
   put the node_Shape of nodeObject into nShape
   if nShape is empty then
      put "ellipse" into nShape
   end if
   return nShape
end nodeShape_Param

getprop nodeShape_Params
   return dot_NodeShapes()
end nodeShape_Params

getprop graphStyle_Param [graphView]
   return the graph_Style of graphView
end graphStyle_Param

getprop graphStyle_Params
   return dot_ListGraphStyles()
end graphStyle_Params

getprop checked_ShowBrowser [graphView]
   put the browser_Visible of graphView into sBoolean
   return sBoolean
end checked_ShowBrowser

getprop checked_ScreenDimensions [graphView]
   put the stack_IsProportional of graphView into sBoolean
   return sBoolean
end checked_ScreenDimensions


--> Global | Dot | Graph | Menu
-
on menu_SetDotUrl graphView, dotName
   put dot_MenuNameText (dotName) into dotText
   set the dot_Text of graphView to dotText
   set the dot_Name of graphView to dotName
   --
   put dot_MenuNameParam (dotName) into dotURL
   if dotURL is not "scaffold" then
      -- https://graphviz.org/Gallery/directed/go-package.svg
      set the itemdelimiter to "."
      put "svg" into item -2 to -1 of dotURL
      --
      set the browser_URL of graphView to dotURL
      set the browser_Visible of graphView to true
   end if
end menu_SetDotUrl

on menu_DisplayDotUrl graphView, dotName
   put dot_MenuNameText (dotName) into dotText
   display_DotText dotText, dotName
end menu_DisplayDotUrl

on menu_GraphStyle graphView, graphStyle
   set the graph_Style of graphView to graphStyle
end menu_GraphStyle

private on _
end _

on menu_ScreenDimensions graphView
   put the screen_ProportionalStackRect of graphView into nRect
   set the stack_Rect of graphView to nRect
end menu_ScreenDimensions

on submenu_Geometry
   return "Global | Dot | Graph | Geometry | Menu"
end submenu_Geometry

on submenu_Props
   return "Global | Dot | Graph | Style | Menu"
end submenu_Props

on ____
end ____

on menu_RevealDotFile graphView
   put the dot_File of graphView into dotFile
   finder_Reveal dotFile
end menu_RevealDotFile

on menu_SetDotFolder graphView
   put the dot_Folder of graphView into dotFolder
   answer folder "Select a folder to store the dot files in..." with dotFolder
   put it into dotFolder
   if dotFolder is empty then exit to top
   
   set the dot_Folder of graphView to dotFolder
end menu_SetDotFolder

on menu_RevealDotFolder graphView
   put the dot_Folder of graphView into dotFolder
   finder_Reveal dotFolder
end menu_RevealDotFolder

private on __
end __

on menu_ClearGraphics graphView
   set the dot_Array of graphView to empty
end menu_ClearGraphics

on menu_ClearNodes graphView
   set the dot_Array of graphView to empty
end menu_ClearNodes

private on ___
end ___

on menu_ShowBrowser graphView
   put the browser_Visible of graphView into sBoolean
   set the browser_Visible of graphView to (sBoolean is false)
end menu_ShowBrowser

on menu_DeleteBrowser graphView
   put the browser_View of graphView into browserView
   delete browserView
end menu_DeleteBrowser

getprop checked_DeleteBrowser [graphView]
   put the browser_View of graphView into browserView
   return exists (browserView)
end checked_DeleteBrowser

on submenu_Tools
   return "Global | Dot | Graph | Tools | Menu"
end submenu_Tools

private on ____
end ____

on menu_GraphvizGallery graphView
   launch url "https://graphviz.org/gallery/"
end menu_GraphvizGallery

on submenu_Dev
   return menu_DevTitle ("Global | Dot | Graph | Menu")
end submenu_Dev
