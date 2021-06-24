script "behavior_ViewFlatworldBackground"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: behavior_ViewFlatworldBackground
type: behavior
version: 0.1


--> Working on
-


--> Events
-
-- on mouseUp
-- flatworld_MouseUpOnCard
end mouseUp

-- on mouseMove x, y
-- flatworld_MouseMoveOnCard x, y
end mouseMove

-- on mouseDown which
flatworld_MouseDownOnCard which
end mouseDown

-- on mouseDoubleUp
mouseDoubleUpOnCard
end mouseDoubleUp


--> Events
-
on resizeControl
   LayoutControl
end resizeControl

on mouseUp pMouseBtnNum
   select empty
   -- pass mouseUp
end mouseUp


--> Geometry
-
setprop view_Rect someRect
   LayoutControl someRect
end view_Rect

command LayoutControl someRect
   if someRect is empty then put the rect of me into someRect
   --
   put the image_Object of me into backgroundImage
   put the long id of btn "_TL" of me into tl_Corner 
   put the long id of btn "_BR" of me into br_Corner 
   
   put item 3 of someRect - item 1 of someRect into scrollWidth
   put item 4 of someRect - item 2 of someRect into scrollHeight
   put rect_GetCentre(someRect) into scrollLoc
   
   put 4 * scrollWidth into newWidth
   put 4 * scrollHeight into newHeight
   put rect_LocWidthHeight(scrollLoc, newWidth, newHeight) into newRect
   
   set the topleft of tl_Corner to item 1 to 2 of newRect
   set the bottomright of br_Corner to item 3 to 4 of newRect
   set the rect of backgroundImage to someRect
   -- put the menu_Button of me into flatMenuButton
   -- set the topleft of flatMenuButton to (item 1 to 2 of someRect)
end LayoutControl


--> Image
-
getprop image_File
   return the filename of the image_Object of me
end image_File

setprop image_File someFile
   set the filename of the image_Object of me to someFile
end image_File


--> Objects
-
getprop view_Object
   return the long id of me
end view_Object

getprop image_Object
   return the long id of image "_Background Image" of me
end image_Object

-- getprop menu_Button
return the long id of btn "_Flat World Menu" of me
end menu_Button
