script "Global | LinkArray | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | LinkArray | Line | Menu
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
   return the display_View of tObject
end menu_Target


--> Global | LinkArray | Line | Menu
-
on menu_DisplayParents dView
   get the selected_Path of dView
   put the displayed_Array of dView into hKeyArray
   put item -1 of it into hKey
   --
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   
   put hkeyArray_ParentKeyArray (hKeyArray) into parentKeyArray
end menu_DisplayParents

on menu_DisplaySubGraph dView
   get the selected_Path of dView
   put the displayed_Array of dView into hKeyArray
   put item -1 of it into hKey
   --
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   
   put hkeyArray_ExtractSubArray (hKey, hKeyArray) into subArray
   display_Data subArray, hKey, "subArray"
   --   
   displayGraph_HkeyArray subArray, hObject, "hierarchical"
end menu_DisplaySubGraph

on menu_DeleteSubGraph dView
   get the selected_Path of dView
   put the displayed_Array of dView into hKeyArray
   put item -1 of it into hKey
   --
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   
   put hkeyArray_DeleteSubArray (hKey, hkeyArray, hKey) into sHkeyArray
   
   -- displayGraph_HkeyArray subArray, hObject, "hierarchical"
   -- display_SimpleGraph sHkeyArray
   display_CreateHandlerSvgFolder hKey, sHkeyArray
end menu_DeleteSubGraph
