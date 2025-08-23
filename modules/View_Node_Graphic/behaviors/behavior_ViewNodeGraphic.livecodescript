script "behavior_ViewNodeGraphic"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewNodeGraphic
type: behavior
version: 0.1

--> Variables
-
local LocalArray


--> Working on
-
private command _HiliteNode sNode
   if exists (sNode) then
      put sNode into LocalArray ["litNode"]
      set the backgroundcolor of sNode to "red"
   else
      put LocalArray ["litNode"] into litNode
      if exists (litNode) then
         set the backgroundcolor of litNode to empty
      end if
      put empty into LocalArray ["litNode"]
   end if
end _HiliteNode

private command _CreateGraphic pName
   if pName is empty then
      put "_Temporary Arrow" into pName
   end if
   set the style of templategraphic to "line"
   set the endArrow of templategraphic to true
   put the loc of me & CR & the mouseLoc into sPoints
   set the points of templategraphic to sPoints
   --
   put the arrow_LineSize of me into aLineSize
   if aLineSize is empty then put 4 into aLineSize
   set the linesize of templategraphic to aLineSize
   --
   put the layer of me into sLayer
   --
   lock screen
   create graphic pName in the owner of me
   put it into tArrow
   --
   set the relayerGroupedControls to true
   set the layer of tArrow to sLayer
   --
   put tArrow into LocalArray ["tArrow"]
   unlock screen
   return tArrow
end _CreateGraphic

private command _CloneNode
   put LocalArray ["tArrow"] into tArrow
   if exists (tArrow) is false then return empty
   
   if the optionKey is "Down" then
      put empty into LocalArray ["tArrow"]
      --
      put LocalArray ["litNode"] into litNode
      if exists (litNode) then
         put litNode into clonedNode
      else
         clone invisible me -- as "New Node"
         put it into clonedNode
         set the to_Arrows of clonedNode to empty
         set the from_Arrows of clonedNode to empty
      end if
      --
      put line -1 of the points of tArrow into endLoc
      set the location of clonedNode to endLoc
      --
      put view_GetTemplateBehavior ("View|ixOS|Arc") into bObject
      set the behavior of tArrow to bObject
      --
      set the from_Object of tArrow to the long id of me
      set the to_Object of tArrow to clonedNode
      --
      set the add_ToArrow of me to tArrow
      set the add_FromArrow of clonedNode to tArrow
      --
      lock screen
      set the visible of clonedNode to true
      dispatch "LayoutControl" to tArrow
      LayoutArrows
      unlock screen
   else
      put empty into LocalArray ["tArrow"]
      delete tArrow
   end if
end _CloneNode


--> Props
-
getprop bottomRight_Rect [cWidth]
   if cWidth is empty then put 8 into cWidth
   put the rect of the target into brRect
   put item 3 of brRect - cWidth into item 1 of brRect
   put item 4 of brRect - cWidth into item 2 of brRect
   return brRect
end bottomRight_Rect


--> Layout | Arrows
-
on LayoutArrows
   lock screen
   put the to_Arrows of me into toArrows
   repeat for each line aView in toArrows
      if exists (aView) is false then
         set the remove_ToArrow of me to aView
         next repeat
      end if
      --
      _LayoutToArrow aView
   end repeat
   
   put the from_Arrows of me into fromArrows
   repeat for each line aView in fromArrows
      if exists (aView) is false then
         set the remove_FromArrow of me to aView
         next repeat
      end if
      --
      _LayoutFromArrow aView
   end repeat
   unlock screen
end LayoutArrows

private command _LayoutToArrow aView
   put the graph_View of aView into gView
   switch the view_Name of gView
      case "View|Dot|Graph"
         _SetGraphvizToArrow aView
         break
      case "View|Graph"
         _AutoSetArrow aView
         dispatch "LayoutControl" to aView
         break
      default
         --
   end switch
end _LayoutToArrow

private command _LayoutFromArrow aView
   put the graph_View of aView into gView
   switch the view_Name of gView
      case "View|Dot|Graph"
         _SetGraphvizFromArrow aView
         break
      case "View|Graph"
         _AutoSetArrow aView
         dispatch "LayoutControl" to aView
         break
      default
         --
   end switch
end _LayoutFromArrow

private command _SetGraphvizFromArrow aView
   put the to_Object of aView into toObject
   if exists (toObject) is false then return false
   
   put the points of aView into aPoints
   put the loc of toObject into tLoc
   put tLoc into line -1 of aPoints
   set the points of aView to aPoints
end _SetGraphvizFromArrow

private command _SetGraphvizToArrow aView
   put the from_Object of aView into fromObject
   if exists (fromObject) is false then return false
   put the to_Object of aView into toObject
   if exists (toObject) is false then return false
   
   put the label of fromObject into fName
   put the label of toObject into toName
   put the loc of toObject into tLoc
   put the loc of fromObject into fLoc
   --
   put the points of aView into aPoints
   put fLoc into line 1 of aPoints
   -- put tLoc into line -1 of aPoints
   set the points of aView to aPoints
end _SetGraphvizToArrow

private command _AutoSetArrow aView
   put the from_Object of aView into fromObject
   put the to_Object of aView into toObject
   --
   if exists (fromObject) is false then return false
   if exists (toObject) is false then return false
   --
   put the loc of fromObject into fLoc
   put the loc of toObject into tLoc
   --
   put item 1 of fLoc into fromX
   put item 1 of tLoc into toX
   --
   -- put item 2 of tLoc into toY
   put the top of toObject into toTop
   put the bottom of toObject into toBottom
   --
   put the top of fromObject into fTop
   put the bottom of fromObject into fBottom
   
   switch
      case toBottom < fTop
         set the from_Side of aView to "top"
         set the to_Side of aView to "bottom"
         break
      case toTop > fBottom
         set the from_Side of aView to "bottom"
         set the to_Side of aView to "top"
         break
      case toX > fromX
         set the from_Side of aView to "right"
         set the to_Side of aView to "left"
         break
      default
         set the from_Side of aView to "left"
         set the to_Side of aView to "right"
   end switch
   return true
end _AutoSetArrow

private command _SetVertical aView
   if _IsBelow (aView) is true then
      set the from_Side of aView to "bottom"
      set the to_Side of aView to "top"
   else
      set the from_Side of aView to "top"
      set the to_Side of aView to "bottom"
   end if
end _SetVertical

private function _IsVertical aView
   get the from_Side of aView
   return char 1 of it is among the items of  "b,t"
end _IsVertical

private command _SetHorizontal aView
   if _IsRight (aView) is true then
      set the from_Side of aView to "right"
      set the to_Side of aView to "left"
   else
      set the from_Side of aView to "left"
      set the to_Side of aView to "right"
   end if
end _SetHorizontal

private function _IsBelow aView
   _SetNodeLocs aView, fLoc, tLoc
   put item 2 of tLoc > item 2 of fLoc into isBelow
   return isBelow
end _IsBelow

private function _IsRight aView
   _SetNodeLocs aView, fLoc, tLoc
   put item 1 of tLoc > item 1 of fLoc into isRight
   return isRight
end _IsRight

private command _SetNodeLocs aView, @fLoc, @tLoc
   put the from_Object of aView into fromObject
   put the to_Object of aView into toObject
   --
   put the loc of fromObject into fLoc
   put the loc of toObject into tLoc
end _SetNodeLocs    


--> From
-
getprop from_Nodes
   put the from_Arrows of me into fArrows
   repeat for each line aView in fArrows
      put the from_Object of aView into fromObject
      if exists (fromObject) then
         put fromObject & CR after fromObjects
      end if
   end repeat
   delete char -1 of fromObjects
   return fromObjects
end from_Nodes

setprop add_FromArrow fArrow
   put the long id of the target into tObject
   --
   put the from_Arrows of tObject into fArrows
   put revRuggedId (fArrow) into fArrow
   --
   line_Add fArrow, fArrows
   --
   set the from_Arrows of tObject to fArrows
   return fArrows
end add_FromArrow

setprop remove_FromArrow fArrow
   put the long id of the target into tObject
   --
   put the from_Arrows of tObject into fArrows
   put revRuggedId (fArrow) into fArrow
   --
   line_Delete fArrow, fArrows
   --
   set the from_Arrows of tObject to fArrows
   return fArrows
end remove_FromArrow


--> To
-
getprop to_Nodes
   put the to_Arrows of me into tArrows
   repeat for each line aView in tArrows
      put the to_Object of aView into toObject
      if exists (toObject) then
         put toObject & CR after toObjects
      end if
   end repeat
   delete char -1 of toObjects
   return toObjects
end to_Nodes

setprop add_ToArrow tArrow
   put the long id of the target into tObject
   --
   put the to_Arrows of tObject into tArrows
   put revRuggedId (tArrow) into tArrow
   --
   line_Add tArrow, tArrows
   --
   set the to_Arrows of tObject to tArrows
   return tArrows
end add_ToArrow

setprop remove_ToArrow tArrow
   put the long id of the target into tObject
   --
   put the to_Arrows of tObject into tArrows
   put revRuggedId (tArrow) into tArrow
   --
   line_Delete tArrow, tArrows
   --
   set the to_Arrows of tObject to tArrows
   return tArrows
end remove_ToArrow

private command _TrackMouse
   put LocalArray ["tArrow"] into tArrow
   put the points of tArrow into sPoints
   put the mouseloc into mLoc
   put mLoc into line -1 of sPoints
   set the points of tArrow to sPoints
   --
   put _ArrowHeadWithin (mLoc) into sNode
   _HiliteNode sNode
end _TrackMouse

private function _ArrowHeadWithin mLoc
   put LocalArray ["tArrow"] into tArrow
   put the short id of tArrow into aID
   put the short id of me into myID
   put the controlids of the owner of me into cIDs
   repeat for each line cID in cIDs
      if cID = aID then next repeat
      if cID = myID then next repeat
      --
      put the long id of control id cID of the owner of me into sNode
      if the arrow_View of sNode is not empty then next repeat
      --
      if within (sNode, mLoc) is true then
         return sNode
      end if
   end repeat
   return empty
end _ArrowHeadWithin


--> Events | Mouse | Move
-
on mouseDown pButton
   switch
      case the optionkey is "down"
         -- create graphic
         _CreateGraphic
         break
      case pButton = 3
         menu_PopUp "Global | Node | Graphic | Menu"
         break
      default
         put the bottomRight_Rect of the target into bottomRightRect
         put bottomRightRect is a rectangle into isRect
         put the mouseLoc into mLoc
         if isRect and mLoc is within the bottomRight_Rect of me then
            put true into LocalArray ["Resize"]
            put the bottom of me - item 2 of mLoc into LocalArray ["bShift"]
            put the right of me - item 1 of mLoc into LocalArray ["rShift"]
         else
            grab me
         end if
   end switch
end mouseDown

on mouseMove pNewMouseH, pNewMouseV
   put LocalArray ["tArrow"] into tArrow
   switch
      case exists (tArrow)
         _TrackMouse
         break
      case the mouse is "Down"
         if LocalArray ["Resize"] is true then
            put the rect of me into newRect
            put pNewMouseH + LocalArray ["rShift"] into item 3 of newRect
            put pNewMouseV + LocalArray ["bShift"] into item 4 of newRect
            set the rect of me to newRect
         end if
         --
         LayoutArrows
         break
   end switch
end mouseMove

--on mouseStillDown pButtonNumber
if exists (tArrow) is false then pass mouseStillDown
_TrackMouse
end mouseStillDown

on mouseRelease
   _Leave
   pass mouseRelease
end mouseRelease

on mouseUp
   _Leave
   pass mouseUp
end mouseUp

on mouseLeave
   _Leave
   pass mouseLeave
end mouseLeave

private command _Leave
   put false into LocalArray ["Resize"]
   --
   _CloneNode
   --
   set the lockCursor to false
   set the cursor to arrow
end _Leave

on mouseWithin
   put the bottomRight_Rect of the target into bottomRightRect
   if bottomRightRect is not a rectangle then pass mouseWithin
   
   set the lockCursor to true
   if the mouseLoc is within bottomRightRect then
      set the cursor to cross
   else
      set the cursor to hand
   end if
end mouseWithin


--> Objects
-
getprop graph_Node
   return the long id of me
end graph_Node

getprop view_Object
   return the long id of me
end view_Object
