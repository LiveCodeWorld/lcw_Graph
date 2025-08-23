script "Global | Dot | Node | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Dot | Node | Dev | Menu
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
getprop menu_Target [nodeObject]
   return nodeObject
end menu_Target


--> Global | Dot | Node | Dev | Menu
-
on menu_CreateNode nodeObject
   put the long id of the owner of nodeObject into dotGroup
   --
   dotArray_CreateGraphic oArray, dotGroup
end menu_CreateNode

on menu_DeleteNode nodeObject
   object_Delete nodeObject
end menu_DeleteNode

on menu_NodeBehavior nodeObject
   put the behavior of nodeObject into bObject
   edit the script of bObject
end menu_NodeBehavior

on menu_ReplaceWithPlaceholder nodeObject
   put the short name of nodeObject into oName
   set the control_Type [oName] of nodeObject to "placeHolder"
   put the result into newView
end menu_ReplaceWithPlaceholder

private on _
end _

on menu_NodeArray nodeObject
   put the short name of nodeObject into nodeName
   put the dot_ObjectArray of nodeObject into pArray
   --
   display_Data pArray, nodeName, "dot_ObjectArray"
end menu_NodeArray

on menu_ParentArray nodeObject
   put the short name of nodeObject into nodeName
   put the parent_Array of nodeObject into pArray
   --
   display_Data pArray, "parent_Array", nodeName
end menu_ParentArray

on menu_DataModel nodeObject
   put the short name of nodeObject into nodeName
   put the data_Model of nodeObject into dModel
   --
   display_Data dModel, "data_Model", nodeName
end menu_DataModel

private on __
end __

on menu_NodeProperties nodeObject
   display_ObjectProperties nodeObject
end menu_NodeProperties

on menu_ToArrows nodeObject
   put the to_Arrows of nodeObject & CR&CR & the from_Arrows of nodeObject
end menu_ToArrows
