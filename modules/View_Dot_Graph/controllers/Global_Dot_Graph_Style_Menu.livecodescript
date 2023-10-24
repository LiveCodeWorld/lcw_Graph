script "Global | Dot | Graph | Style | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Dot | Graph | Style | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tOject]
   return the graph_View of tOject
end menu_Target

getprop checked_BrowserVisible [graphView]
   put the browser_Visible of graphView into oBoolean
   return oBoolean
end checked_BrowserVisible

getprop checked_AutoScale [graphView]
   put the auto_Scale of graphView into oBoolean
   return oBoolean
end checked_AutoScale

getprop checked_ShowNodes [graphView]
   put the show_Nodes of graphView into oBoolean
   return oBoolean
end checked_ShowNodes

getprop checked_ShowNames [graphView]
   put the show_Names of graphView into oBoolean
   return oBoolean
end checked_ShowNames

getprop checked_ShowNodeLabels [graphView]
   put the show_NodeLabels of graphView into oBoolean
   return oBoolean
end checked_ShowNodeLabels

getprop checked_ShowEdges [graphView]
   put the show_Edges of graphView into oBoolean
   return oBoolean
end checked_ShowEdges

getprop checked_TransparentBackground [graphView]
   put the opaque of graphView into oBoolean
   return oBoolean is false
end checked_TransparentBackground

getprop edgeWidth_Param [graphView]
   put the edge_Width of graphView into edgeWidth
   return edgeWidth
end edgeWidth_Param


--> Global | Dot | Graph | Style | Menu
-
on menu_EdgeWidth graphView, edgeWidth
   set the edge_Width of graphView to edgeWidth
end menu_EdgeWidth

private command _
end _

on menu_TransparentBackground graphView
   put the opaque of graphView into sBoolean
   set the opaque of graphView to (sBoolean is false)
end menu_TransparentBackground

on menu_BrowserVisible graphView, sBoolean
   put the browser_Visible of graphView into oBoolean
   set the browser_Visible of graphView to (oBoolean is false)
end menu_BrowserVisible

private command __
end __

on menu_ShowNodes graphView
   put the show_Nodes of graphView into oBoolean
   set the show_Nodes of graphView to (oBoolean is false)
end menu_ShowNodes

on menu_ShowNames graphView
   put the show_Names of graphView into oBoolean
   set the show_Names of graphView to (oBoolean is false)
end menu_ShowNames 

on menu_ShowNodeLabels graphView
   put the show_NodeLabels of graphView into oBoolean
   set the show_NodeLabels of graphView to (oBoolean is false)
end menu_ShowNodeLabels

on menu_ShowEdges graphView
   put the show_Edges of graphView into oBoolean
   set the show_Edges of graphView to (oBoolean is false)
end menu_ShowEdges
