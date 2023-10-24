script "Global | Dot | Graph | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Dot | Graph | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
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

getprop anotherSvg_Params
   return LocalArray ["nameMenu"] -- dot_UrlNameMenu()
end anotherSvg_Params


--> Global | Dot | Graph | Dev | Menu
-
on menu_CreateSvg graphView, dotName
   put dot_MenuNameText (dotName) into dotText
   --
   put the dot_File of graphView into dotFile
   --
   put the dot_Command of graphView into dotCommand
   dot_CreateSvg dotFile, dotCommand
   put the result into svgFile
   --
   put the browser_View of graphView into browserView
   set the svg_File [true] of browserView to svgFile
   set the browser_Visible of graphView to true
end menu_CreateSvg

on menu_AnotherSvg graphView, dotName   
   put the dot_File of graphView into dotFile
   put dot_MenuNameText (dotName) into dotText
   --
   display_Dot dotText
   put the result into svgFile
   --
   display_Text dotText
   finder_Reveal svgFile
end menu_AnotherSvg

on menu_FreakyPipe
   put "sfdp -Goverlap=prism gd_1994_2007_8comp.gv | gvmap  -e | neato -Ecolor="#55555522" -n2 -Tpng > gd_1994_2007_8comp.png"
end menu_FreakyPipe
