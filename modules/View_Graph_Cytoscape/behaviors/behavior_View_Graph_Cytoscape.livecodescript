script "behavior_View_Graph_Cytoscape"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_View_Graph_Cytoscape
type: behavior
version: 0.1


--> Working on
-
on mouse_DoubleUp dView, sLine
   if the shiftKey is "Down" then
      put the selected_File of me into sFile
      launch_TextEditor sFile
   else
      put the selected_Url of me into assetURL
      set the url of _BrowserWidget() to assetURL
   end if
end mouse_DoubleUp

getprop selected_Url
   put _TreeView() into treeView
   --
   put the selected_Line of treeView into shortFile
   put the displayed_Folder of treeView into assetFolder
   text_AddTrailing assetFolder, slash
   
   set the itemdelimiter to slash
   put item -1 of assetFolder into subFolder
   put item -3 of assetFolder into wikiDomain
   
   put fedwiki_ConstructAssetUrl (shortFile, wikiDomain, subFolder) into assetURL
   return assetURL
end selected_Url

getprop selected_File
   put _TreeView() into treeView
   --
   put the selected_Line of treeView into shortFile
   put the displayed_Folder of treeView into assetFolder
   text_AddTrailing assetFolder, slash
   put assetFolder & shortFile into sFile
   return sFile
end selected_File

getprop browser_Widget
   return _BrowserWidget()
end browser_Widget

private function _TreeView
   return the long id of group 1 of me
end _TreeView

private function _BrowserWidget
   return the long id of widget 1 of me
end _BrowserWidget


--> Events
-
on resizeControl
   put the rect of me into viewRect
   LayoutControl viewRect
end resizeControl

command LayoutControl pRect
   lock screen
   if pRect is empty then put the rect of me into pRect
   
   -- do your geometry here
   unlock screen
end LayoutControl


--> Objects
-
getprop view_Object
   return the long id of me
end view_Object
