script "Global | Dot | Node | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Dot | Node | Menu
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
   return tObject
end menu_Target

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


--> Global | Dot | Node | Menu
-
on menu_Create nodeObject
   put the long id of the owner of nodeObject into dotGroup
   --
   dotArray_CreateGraphic oArray, dotGroup
end menu_Create

private command ___
end ___

on menu_NodeRect nodeObject
   put the rect of nodeObject into oRect
   put the node_Rect of nodeObject into nodeRect
   set the rect of nodeObject to nodeRect
   --
   put oRect &CR& nodeRect
end menu_NodeRect

on menu_NodeShape nodeObject, nShape
   set the node_Shape of nodeObject to nShape
end menu_NodeShape

on menu_NodeArray nodeObject
   put the short name of nodeObject into nodeName
   put the node_Array of nodeObject into pArray
   --
   display_Data pArray, nodeName, "node_Array"
end menu_NodeArray

private command ____
end ____

on menu_ParentArray nodeObject
   put the short name of nodeObject into nodeName
   put the parent_Array of nodeObject into pArray
   --
   display_Data pArray, "parent_Array", nodeName
end menu_ParentArray

on menu_NodeBehavior nodeObject
   put the behavior of nodeObject
end menu_NodeBehavior

private command _
end _

on menu_ColourFamily nodeObject
   lock screen
   menu_AllWhite nodeObject
   put the result into allNodeNames
   --
   put the parent_Names of nodeObject into pNames
   set the node_Colour [pNames] of nodeObject to "red"
   put pNames & CR after fNames
   --
   put the graph_View of nodeObject into gView
   repeat for each line pName in pNames
      put the long id of control pName of gView into pObject
      put the child_Names of pObject into pChildNames
      set the node_Colour [pChildNames] of pObject to "orange"
      --
      put pChildNames & CR after fNames
   end repeat
   --
   put the child_Names of nodeObject into cNames
   set the node_Colour [cNames] of nodeObject to "light blue"
   set the node_Colour of nodeObject to "yellow"
   put cNames & CR after fNames
   sort numeric lines of fNames by char 2 to -1 of each
   put word 1 to -1 of allNodeNames into allNodeNames
   --
   repeat for each line sName in allNodeNames
      if sName is not among the lines of fNames then
         set the fade_Level of control sName of gView to 70
      end if
   end repeat
   --
   unlock screen
end menu_ColourFamily

on menu_ColourDecendents nodeObject
   lock screen
   menu_AllWhite nodeObject
   --
   set the node_Colour of nodeObject to "yellow"
   put the parent_Names of nodeObject into pNames
   set the node_Colour [pNames] of nodeObject to "red"
   
   set the descendent_Colour of nodeObject to "yellow"
   put the result into missingNames
   --
   if missingNames is not empty then
      set the faded_Nodes of nodeObject to missingNames
   end if
   unlock screen
   return missingNames
end menu_ColourDecendents

on menu_ColourParents nodeObject
   put the parent_Names of nodeObject into pNames
   set the node_Colour [pNames] of nodeObject to "red"
end menu_ColourParents

on menu_ColourChildren nodeObject
   lock screen
   menu_AllWhite nodeObject
   --
   put the child_Names of nodeObject into cNames
   set the node_Colour of nodeObject to "yellow"
   set the node_Colour [cNames] of nodeObject to "light blue"
   --
   put the child_Edges of nodeObject into edgeNames
   put colour_Darken ("light blue", 30) into darkerColour
   set the edge_Colour [edgeNames] of nodeObject to darkerColour
   unlock screen
end menu_ColourChildren

on menu_ColourOutEdges nodeObject
   put the edge_Names of nodeObject into edgeNames
   set the edge_Colour [edgeNames] of nodeObject to "magenta"
end menu_ColourOutEdges

private command __
end __

on menu_FadeMe nodeObject
   put the short name of nodeObject into nodeName
   --
   set the faded_Nodes of nodeObject to nodeName
end menu_FadeMe

on menu_AllWhite nodeObject
   lock screen
   set the node_Colour ["all"] of nodeObject to "white"
   put the result into allNodeNames
   set the edge_Colour ["all"] of nodeObject to ""
   unlock screen
   return allNodeNames
end menu_AllWhite
