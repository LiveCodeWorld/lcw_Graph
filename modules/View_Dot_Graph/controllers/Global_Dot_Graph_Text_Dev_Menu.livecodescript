script "Global | Dot | Graph | Text | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Dot | Graph | Text | Dev | Menu
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
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target


--> Global | Dot | Graph | Text | Dev | Menu
-
on menu_FetchDotFromImage displayView
   put the graph_View of displayView into graphView
   put the dot_Text of graphView into dotText
   --
   set the displayed_Text of displayView to dotText
end menu_FetchDotFromImage

on menu_DisplayGraphView graphView
   object_GoTo graphView
end menu_DisplayGraphView

on menu_DiplayBehavior
   put LocalArray ["displayView"] into displayView
   put the behavior of displayView into bObject
   edit the behavior of bObject
end menu_DiplayBehavior

private on __
end __

on menu_ParseMoti displayView
   put the displayed_Text of displayView into csvText
   delete line 1 of csvText
   repeat for each line sLine in csvText
      put item 1 of sLine into fromName
      if fromName is empty then next repeat
      --
      if char 1 of item 2 of sLine = quote then
         get token 4 of sLine
         delete item 1 of sLine
         --
         delete word 1 of sLine
         delete item 1 of sLine
         replace quote with empty in sLine
         --
         _AddToLinkArray linkArray, fromName, sLine
      else
         put item 3 of sLine into toName
         _AddToLinkArray linkArray, fromName, toName
      end if
   end repeat
   --
   display_LinkArray linkArray, "David Interview", "Link Array"
   display_LinkArrayGraph linkArray
end menu_ParseMoti

private command _AddToLinkArray @linkArray, fromName, sLine
   _Clean fromName
   _Clean sLine
   if sLine is empty then
      put empty into linkArray [fromName]
   else
      repeat for each item toName in sLine
         _Clean toName
         put empty into linkArray [fromName][toName]
      end repeat
   end if
end _AddToLinkArray

private command _Clean @sName
   replace quote with empty in sName
   put word 1 to -1 of sName into sName
end _Clean

