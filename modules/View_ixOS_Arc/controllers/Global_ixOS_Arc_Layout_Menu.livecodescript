script "Global | ixOS | Arc | Layout | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | ixOS | Arc | Layout | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray


--> Working on
-
private function _NamedControl aView, fName
   put the named_View [fName] of aView into fObject
   if exists (fObject) is true then return fObject
   
   put the card_Object of aView into cObject
   if exists (control fName of cObject) then
      return the long id of control fName of cObject
   end if
end _NamedControl


--> Menu | Props
-
getprop menu_Target [tObject]
   put the arrow_View of tObject into aView
   if exists (aView) is false then return empty
   
   put the arrow_LinkNames of aView into LocalArray ["arrowLinkNames"]
   return aView
end menu_Target

getprop menu_CheckTarget [aView]
   return exists (aView)
end menu_CheckTarget

getprop setFrom_Param [aView]
   put the from_Name of aView into fName
   return fName
end setFrom_Param

getprop setFrom_Params [aView]
   return LocalArray ["arrowLinkNames"]
end setFrom_Params

getprop setTo_Param [aView]
   put the to_Name of aView into tName
   return tName
end setTo_Param

getprop setTo_Params [aView]
   return LocalArray ["arrowLinkNames"]
end setTo_Params

getprop fromSide_Param [aView]
   return the from_Side of aView
end fromSide_Param

getprop fromSide_Params
   return "top,bottom,left,right"
end fromSide_Params

getprop toSide_Param [aView]
   return the to_Side of aView
end toSide_Param

getprop toSide_Params
   return "left,right,-,top,bottom"
end toSide_Params


--> Global | ixOS | Arc | Layout | Menu
-
on menu_SetFrom aView, fName
   put _NamedControl (aView, fName) into fObject
   set the from_Object of aView to fObject
   --
   put revRuggedId(aView) into aView
   set the add_ToArrow of fObject to aView
   --
   dispatch "LayoutControl" to aView
end menu_SetFrom

on menu_SetTo aView, tName
   put _NamedControl (aView, tName) into tObject
   set the to_Object of aView to tObject
   --
   set the add_FromArrow of tObject to aView
   --
   dispatch "LayoutControl" to aView
end menu_SetTo

private on _
end _

private command _SetNodeLocs aView, @fLoc, @tLoc
   put the from_Object of aView into fromObject
   put the to_Object of aView into toObject
   put the loc of fromObject into fLoc
   put the loc of toObject into tLoc
end _SetNodeLocs

on menu_AutoVertical aView
   _SetNodeLocs aView, fLoc, tLoc
   --
   put item 1 of tLoc > item 1 of fLoc into isRight
   put item 2 of tLoc > item 2 of fLoc into isBelow
   --
   if isBelow then
      set the from_Side of aView to "bottom"
      set the to_Side of aView to "top"
   else
      set the from_Side of aView to "top"
      set the to_Side of aView to "bottom"
   end if
   dispatch "LayoutControl" to aView
end menu_AutoVertical

on menu_AutoHorizontal aView
   _SetNodeLocs aView, fLoc, tLoc
   --
   put item 1 of tLoc > item 1 of fLoc into isRight
   put item 2 of tLoc > item 2 of fLoc into isBelow
   --
   if isRight then
      set the from_Side of aView to "right"
      set the to_Side of aView to "left"
   else
      set the from_Side of aView to "left"
      set the to_Side of aView to "right"
   end if
   dispatch "LayoutControl" to aView
end menu_AutoHorizontal

on menu_FromSide aView, fSide
   set the from_Side of aView to fSide
   --
   dispatch "LayoutControl" to aView
end menu_FromSide

on menu_ToSide aView, tSide
   set the to_Side of aView to tSide
   --
   dispatch "LayoutControl" to aView
end menu_ToSide

private on __
end __

on menu_SetFromItems aView
   put the from_Items of aView into fItems
   get lcw_Ask ("Set from_Items of arrow...", fItems, "from_Items")
   set the to_Items of aView to it
   --
   dispatch "LayoutControl" to aView
end menu_SetFromItems

on menu_SetToItems aView
   put the to_Items of aView into toItems
   get lcw_Ask ("Set to_Items of arrow...", toItems, "to_Items")
   set the to_Items of aView to it
   --
   dispatch "LayoutControl" to aView
end menu_SetToItems

private on ___
end ___

on menu_Layout aView
   dispatch "LayoutControl" to aView
end menu_Layout

