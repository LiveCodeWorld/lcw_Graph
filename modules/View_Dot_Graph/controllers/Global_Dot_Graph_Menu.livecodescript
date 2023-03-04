script "Global | Dot | Graph | Menu"
--> MetaData
-
copyright: David Menu
license: GPLv3
name: Global | Dot | Graph | Menu
type: controller
version: 0.1

/*
This menu is for use with the "View|Dot|Graph" module.
*/

-- put LocalArray ["dotNameArray"] into dotNameArray

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put dot_ConstructDotNameArray() into dotNameArray
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
   
getprop createFromDot_Param [graphView]
   return the dot_Name of graphView
end createFromDot_Param

getprop createFromDot_Params
   return LocalArray ["nameMenu"] -- dot_UrlNameMenu()
end createFromDot_Params

getprop anotherSvg_Params
   return LocalArray ["nameMenu"] -- dot_UrlNameMenu()
end anotherSvg_Params

command display_DotGraph dotURL, pStackStyle, pLocOrRect
   stack_CloneInvisible "View|Dot|Graph", "Display Dot Graph"
   put the result into cloneStackName
   put the long id of widget 1 of cd 1 of stack cloneStackName into graphView
   --
   put the view_RectOnCard of graphView into gRect
   set the dot_URL [gRect] of graphView to dotURL
   put the result into dotArray
   --
   set the dot_Name of graphView to dotName
   --
   stack_ShowAndGo graphView, cloneStackName, gName, pStackStyle, pLocOrRect
   return graphView
end display_DotGraph


--> Global | Dot | Graph | Menu
-
on menu_CreateFromDot graphView, dotName
   switch dotName
      case "minimal"
         put dot_GetMinimal() into dotText
         break
      default
         put LocalArray ["dotNameArray"][dotName] into dotURL
         put url dotURL into dotText
   end switch
   
   put the view_RectOnCard of graphView into gRect
   set the dot_URL [gRect] of graphView to dotURL
   put the result into dotArray
   set the dot_Name of graphView to dotName
end menu_CreateFromDot

-- on menu_DisplaySvg graphView
   put the dot_URL of graphView into dotURL
end menu_DisplaySvg
   
private command _
end _

on menu_SetDotFolder graphView
   answer folder "Select a folder to store the dot files in..."
   put it into dotFolder
   if dotFolder is empty then exit to top
   
   set the dot_Folder of graphView to dotFolder
end menu_SetDotFolder

on menu_RevealDotFolder graphView
   put the dot_Folder of graphView into dotFolder
   finder_Reveal dotFolder
end menu_RevealDotFolder

private command __
end __

on menu_ClearGraphics graphView
   set the dot_Array of graphView to empty
end menu_ClearGraphics

on menu_AnotherSvg graphView, dotName
   -- sfdp -Goverlap=prism gd_1994_2007_8comp.gv | gvmap  -e | neato -Ecolor="#55555522" -n2 -Tpng > gd_1994_2007_8comp.png
   
   put LocalArray ["dotNameArray"][dotName] into dotURL
   put url dotURL into dotText
   --
   display_Dot dotText
   put the result into svgFile
   --
   display_Text dotText
   finder_Reveal svgFile
end menu_AnotherSvg

on menu_GraphvizGallery graphView
   launch url "https://graphviz.org/gallery/"
   
   /*
   switch dotName
      case "minimal"
         put dot_GetMinimal() into dotText
         display_Text dotText, "Dot", "Minimal"
         break
      default
         put LocalArray ["dotNameArray"] into dotNameArray
         put dotNameArray [dotName] into dotURL
         launch url dotURL
   end switch
   */
end menu_GraphvizGallery

on submenu_Style
   return "Global | Dot | Graph | Style | Menu"
end submenu_Style

on submenu_Tools
   return "Global | Dot | Graph | Tools | Menu"
end submenu_Tools
