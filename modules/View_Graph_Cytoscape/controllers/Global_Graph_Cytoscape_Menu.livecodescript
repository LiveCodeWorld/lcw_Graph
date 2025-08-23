script "Global | Graph | Cytoscape | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Graph | Cytoscape | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into LocalArray ["dView"]
   put the displayed_Object of tObject into sObject
   return sObject
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Graph | Cytoscape | Menu
-
on menu_GraphCytoscape dView
   put the browser_Widget of dView into browserWidget
   set the cyto_Javascript of browserWidget to asfd
end menu_GraphCytoscape

private on _
end _

on menu_SetNodes dView
   put the browser_Widget of dView into browserWidget
   --
   put the cyto_NodeArray of dView into nodeArray
   set the cyto_NodeArray of browserWidget to nodeArray
end menu_SetNodes

on menu_ClearNodes dView
   put the browser_Widget of dView into browserWidget
   --
   set the cyto_NodeArray of browserWidget to empty
end menu_ClearNodes

private on __
end __

on menu_SetAssetFolder dView
   put wikiFolder_ConstructAssets ("graph.fedwiki.club", "vibe-scape") into assetFolder
   answer folder "Choose an asset folder..." with assetFolder
   if it is empty then exit to top
   put it into assetFolder
   text_AddTrailing assetFolder, slash
   
   put files (assetFolder) into assetFiles
   set the displayed_Index of dView to assetFiles
   set the displayed_Folder of dView to assetFolder
end menu_SetAssetFolder

on submenu_Dev
   return menu_DevTitle ("Global | Graph | Cytoscape | Menu")
end submenu_Dev
