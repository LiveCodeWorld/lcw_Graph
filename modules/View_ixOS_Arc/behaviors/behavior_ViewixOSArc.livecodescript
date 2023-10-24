script "behavior_ViewixOSArc"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewixOSArc
type: behavior
version: 0.2


--> Working on
-
getprop arrow_LinkNames
   put the arrow_LinkNames of me into linkNames
   if linkNames is empty then
      put the long owner of me into cObject
      if word 1 of cObject is not among the items of "group,card" then
         put the card_Object of me into cObject
      end if
      /*
      put the top_ControlNames of cObject into linkNames
      put the short name of me into aName
      line_Delete aName, linkNames
      */
      put the top_ViewNames ["View|Node|Graphic"] of cObject into linkNames
   end if
   return linkNames
end arrow_LinkNames

setprop arrow_PointLink arrowArray
   _DeconstructArray arrowArray, fromObject, fItems, toObject, tItems
   put _GetArrowPoints (fromObject, fItems, toObject, tItems) into arrowPoints
   
   if arrowPoints is empty then return empty
   set the points of me to arrowPoints
   return arrowPoints
end arrow_PointLink

function loc_OnBorder cRect, pItems
   put item 1 of pItems into sBorder
   put item 2 of pItems into stepNum
   put item 3 of pItems into numOfSteps
   if stepNum is empty then
      put 1 into stepNum
      put 2 into numOfSteps
   end if
   
   put 2 into yFiddle
   switch char 1 of sBorder
      case "t"
         put item 2 of cRect into myTop
         subtract yFiddle from myTop
         put myTop into item 2 of bLoc
         put _BLocX (cRect, stepNum, numOfSteps) into item 1 of bLoc
         return bLoc
      case "l"
         put item 1 of cRect into item 1 of bLoc
         put _BLocY (cRect, stepNum, numOfSteps) into item 2 of bLoc
         return bLoc
      case "r"
         put item 3 of cRect into item 1 of bLoc
         put _BLocY (cRect, stepNum, numOfSteps) into item 2 of bLoc
         return bLoc
      case "b"
      default
         put item 4 of cRect into myBottom
         add yFiddle to myBottom
         put myBottom into item 2 of bLoc
         put _BLocX (cRect, stepNum, numOfSteps) into item 1 of bLoc
         return bLoc
   end switch
end loc_OnBorder

private function _GetArrowPoints fromObject, fItems, toObject, tItems
   if exists (fromObject) is false then return empty
   if exists (toObject) is false then return empty
   
   -- put the border_Loc [fItems] of fromObject into aStartPoint
   put the rect of fromObject into cRect
   put loc_OnBorder (cRect, fItems) into aStartPoint
   if aStartPoint is empty then return empty
   
   -- put the border_Loc [tItems] of toObject into aEndPoint
   put the rect of toObject into cRect
   put loc_OnBorder (cRect, tItems) into aEndPoint
   if aEndPoint is empty then return empty
   
   put _ArrowPointsFromEnds (aEndPoint, aStartPoint) into sPoints
   return sPoints
end _GetArrowPoints

private function _IsVertical
   get the from_Side of me
   return char 1 of it is among the items of  "b,t"
end _IsVertical

private function _ArrowPointsFromEnds aEndPoint, aStartPoint
   if _IsVertical() is true then
      put _VerticalArrowPoints (aEndPoint, aStartPoint) into sPoints
   else
      put _HorizontalArrowPoints (aEndPoint, aStartPoint) into sPoints
   end if
   return sPoints
end _ArrowPointsFromEnds

private function _HorizontalArrowPoints aEndPoint, aStartPoint
   put (item 1 of aEndPoint - item 1 of aStartPoint)/2 into aHalfWidth
   --
   put aStartPoint into leftPoint
   add aHalfWidth to item 1 of leftPoint
   --
   put aEndPoint into rightPoint
   subtract aHalfWidth from item 1 of rightPoint
   --
   put aStartPoint into sPoints
   put CR & leftPoint after sPoints
   put CR & rightPoint after sPoints
   put CR & aEndPoint after sPoints
   --
   return sPoints
end _HorizontalArrowPoints

private function _VerticalArrowPoints aEndPoint, aStartPoint
   put (item 2 of aEndPoint - item 2 of aStartPoint)/2 into aHalfHeight
   --
   put aStartPoint into upPoint
   add aHalfHeight to item 2 of upPoint
   --
   put aEndPoint into downPoint
   subtract aHalfHeight from item 2 of downPoint
   --
   put aStartPoint into sPoints
   put CR & upPoint after sPoints
   put CR & downPoint after sPoints
   put CR & aEndPoint after sPoints
   --
   return sPoints
end _VerticalArrowPoints

private command _DeconstructArray arrowArray, @fromObject, @fItems, @toObject, @tItems
   put arrowArray ["from_Object"] into fromObject
   put arrowArray ["from_Side"] into item 1 of fItems
   put arrowArray ["from_StepNum"] into item 2 of fItems
   put arrowArray ["from_SliceNum"] into item 3 of fItems
   _NormaliseItems fItems
   --
   put arrowArray ["to_Object"] into toObject
   put arrowArray ["to_Side"]into item 1 of tItems
   put arrowArray ["to_StepNum"] into item 2 of tItems
   put arrowArray ["to_SliceNum"] into item 3 of tItems
   _NormaliseItems tItems
end _DeconstructArray


--> Props | Compound
-
getprop arrow_Data
   -- would prefer to use a straigh array of control
   -- but this enabled manual editing in IDE
   
   set the customPropertySet of me to "arrow_Array"
   put the customproperties of me into arrowData
   set the customPropertySet of me to empty
   --
   put arrowData ["from_Object"] into fromObject
   if exists (fromObject) then
      put the short id of fromObject into arrowData ["from_ID"]
      put the tile_Number of fromObject into arrowData ["from_Number"]
      --
      put the short name of fromObject into arrowData ["from_Name"]
      put the label of fromObject into arrowData ["from_Label"]
   end if
   put arrowData ["to_Object"] into toObject
   if exists (toObject) then
      put the short id of toObject into arrowData ["to_ID"]
      put the tile_Number of toObject into arrowData ["to_Number"]
      --
      put the short name of toObject into arrowData ["to_Name"]
      put the label of toObject into arrowData ["to_Label"]
   end if
   --
   return arrowData
end arrow_Data

getprop from_Items
   put the from_Side of me into fItems
   put the from_StepNum of me into item 2 of fItems
   put the from_SliceNum of me into item 3 of fItems
   return fItems
end from_Items

setprop from_Items [pFromName] fItems  
   _NormaliseItems fItems
   if the result is false then return empty
   
   set the from_Side of me to item 1 of fItems
   set the from_StepNum of me to item 2 of fItems
   set the from_SliceNum of me to item 3 of fItems
   --
   if pFromName is not empty then
      set the from_Name of me to pFromName
   end if
   return fItems
end from_Items

getprop to_Items
   put the to_Side of me into tItems
   put the to_StepNum of me into item 2 of tItems
   put the to_SliceNum of me into item 3 of tItems
   return tItems
end to_Items

setprop to_Items [pToName] tItems
   _NormaliseItems tItems
   if the result is false then return empty
   
   set the to_Side of me to item 1 of tItems
   set the to_StepNum of me to item 2 of tItems
   set the to_SliceNum of me to item 3 of tItems
   --
   if pToName is not empty then
      set the to_Name of me to pToName
   end if
   return tItems
end to_Items


--> Events
-
on resizeControl
   LayoutControl
end resizeControl

command LayoutControl pRect
   if pRect is empty then put the rect of me into pRect
   --
   put the arrow_Data of me into arrowData
   set the arrow_PointLink of me to arrowData
end LayoutControl

on mouseDown pButtonNumber
   switch pButtonNumber
      case 3
         put menu_GetGlobalButton() into mButton
         mArray_PopUp "Global | IxOS | Arc | Menu", mButton
         break
      default
         pass mouseDown
   end switch
end mouseDown

on mouseUp
   arrow_AnimateBall true
   pass mouseUp
end mouseUp

on arrow_AnimateBall pReverse
   put the points of me into pathPoints
   if pReverse is not true then
      put index_Reverse (pathPoints) into pathPoints
   end if
   put the card_Object of me into cardObject
   --
   set the ball_Path ["3"] of cardObject to pathPoints
   put the result into newBall
   --
   try
      ball_PathAnimate newBall
   end try
   return newBall
end arrow_AnimateBall


--> Objects
-
private function _FromView fromName
   put the from_Object of me into fromObject
   if exists (fromObject) then return fromObject
   
   # Legacy Code
   if exists (group fromName) then
      return the long id of group fromName
   else
      return empty
   end if
end _FromView

private function _ToView toName
   put the to_Object of me into toObject
   if exists (toObject) then return toObject
   
   # Legacy Code
   if exists (group toName) then
      return the long id of group toName
   else
      return empty
   end if
end _ToView

getprop from_Object
   return the arrow_Array ["from_Object"] of me
end from_Object

setprop from_Object fromObject
   if exists (fromObject) is false then return empty
   
   put the rugged_ID of fromObject into rObject
   set the arrow_Array ["from_Object"] of me to rObject
   --
   put the short name of fromObject into fromName
   set the from_Name of me to fromName
end from_Object

getprop to_Object
   return the arrow_Array ["to_Object"] of me
end to_Object

setprop to_Object toObject
   if exists (toObject) is false then return empty
   
   put the rugged_ID of toObject into rObject
   set the arrow_Array ["to_Object"] of me to rObject
   --
   put the short name of toObject into toName
   set the to_Name of me to toName
end to_Object

getprop from_Name
   return the arrow_Array ["from_Name"] of me
end from_Name

setprop from_Name fromName
   set the arrow_Array ["from_Name"] of me to fromName
end from_Name

getprop to_Name
   return the arrow_Array ["to_Name"] of me
end to_Name

setprop to_Name toName
   set the arrow_Array ["to_Name"] of me to toName
end to_Name

function index_Reverse sIndex
   repeat for each line sLine in sIndex
      put sLine & CR before rIndex
   end repeat
   delete char - 1 of rIndex
   return rIndex
end index_Reverse


--> Points
-
getprop arrow_NameLink
   put the from_Name of me into fromName
   put the from_Items of me into fItems
   put the to_Name of me into toName
   put the to_Items of me into tItems
   --
   put _ConstructItems (fromName, fItems, toName, tItems) into nameLink
   return nameLink
end arrow_NameLink


--> Geometry
-
getprop arrow_PointsWidth
   put the width of me into aWidth
   put the lineSize of me into aLineSize
   put aWidth + aLineSize into cWidth
   return cWidth
end arrow_PointsWidth


--> Props | From
-
getprop from_Side
   put the arrow_Array ["from_Side"] of me into sSide
   if stepNum is empty then
      return "right"
   else
      return sSide
   end if
end from_Side

setprop from_Side fSide
   _NormaliseItems fSide
   if the result is false then return false
   
   put item 1 of fSide into fSide
   set the arrow_Array ["from_Side"] of me to fSide
   return true
end from_Side

getprop from_StepNum
   put the arrow_Array ["from_StepNum"] of me into stepNum
   if stepNum is empty then
      return 1
   else
      return stepNum
   end if
end from_StepNum

setprop from_StepNum stepNum
   set the arrow_Array ["from_StepNum"] of me to stepNum
end from_StepNum

getprop from_SliceNum
   put the arrow_Array ["from_SliceNum"] of me into sliceNum
   if sliceNum is empty then
      return 2
   else
      return sliceNum
   end if
end from_SliceNum

setprop from_SliceNum sliceNum
   set the arrow_Array ["from_SliceNum"] of me to sliceNum
end from_SliceNum


--> Props | To
-
getprop to_Side
   put the arrow_Array ["to_Side"] of me into sSide
   if stepNum is empty then
      return "left"
   else
      return sSide
   end if
end to_Side

setprop to_Side toSide
   _NormaliseItems toSide
   if the result is false then return empty
   put item 1 of toSide into toSide
   
   set the arrow_Array ["to_Side"] of me to toSide
end to_Side

getprop to_StepNum
   put the arrow_Array ["to_StepNum"] of me into stepNum
   if stepNum is empty then
      return 1
   else
      return sliceNum
   end if
end to_StepNum

setprop to_StepNum stepNum
   set the arrow_Array ["to_StepNum"] of me to stepNum
end to_StepNum

getprop to_SliceNum
   put the arrow_Array ["to_SliceNum"] of me into sliceNum
   if sliceNum is empty then
      return 2
   else
      return sliceNum
   end if
end to_SliceNum

setprop to_SliceNum sliceNum
   set the arrow_Array ["to_SliceNum"] of me to sliceNum
end to_SliceNum


--> Private
-
private function _ConstructItems fromName, fItems, toName, tItems
   _NormaliseItems fItems
   if the result is false then return empty
   _NormaliseItems tItems
   if the result is false then return empty
   
   set the linedelimiter to " - "
   put fromName,fItems into line 1 of nameLink
   put toName,tItems into line 2 of nameLink
   return nameLink
end _ConstructItems

private command _DeconstructItems pNameLink, @fromName, @fItems, @toName, @tItems   
   set the linedelimiter to "-"
   put word 1 to -1 of line 1 of pNameLink into fromItems
   put word 1 to -1 of line 2 of pNameLink into toItems
   --
   put word 1 to -1 of item 1 of fromItems into fromName
   put word 1 to -1 of item 2 of fromItems into fSide
   put word 1 to -1 of item 3 of fromItems into fStepNum
   put word 1 to -1 of item 4 of fromItems into fSliceNum
   --
   put fSide into item 1 of fItems
   put fStepNum into item 2 of fItems
   put fSliceNum into item 3 of fItems
   _NormaliseItems fItems
   
   put word 1 to -1 of item 1 of toItems into toName
   put word 1 to -1 of item 2 of toItems into tSide
   put word 1 to -1 of item 3 of toItems into tStepNum
   put word 1 to -1 of item 4 of toItems into tSliceNum
   --
   put tSide into item 1 of tItems
   put tStepNum into item 2 of tItems
   put tSliceNum into item 3 of tItems
   _NormaliseItems tItems
end _DeconstructItems

private function _BLocX tRect, stepNum, numOfSteps
   put item 1 of tRect into tLeft
   put item 3 of tRect - tLeft into tWidth
   put tLeft + stepNum * tWidth/numOfSteps into bLocX
   return bLocX
end _BLocX

private function _BLocY myRect, stepNum, numOfSteps
   put item 2 of myRect into myTop
   put item 4 of myRect - myTop into myHeight
   put myTop + stepNum * myHeight/numOfSteps into bLocY
   return bLocY
end _BLocY

private command _NormaliseItems @sItems
   get char 1 of sItems
   if it is not among the chars of "lrtb" then
      put empty into sItems
      return false
   end if
   
   switch char 1 of sItems
      case "l"
         put "left" into item 1 of sItems
         break
      case "r"
         put "right" into item 1 of sItems
         break
      case "t"
         put "top" into item 1 of sItems
         break
      case "b"
         put "bottom" into item 1 of sItems
         break
   end switch
   
   if item 2 of sItems is empty then
      put 1 into item 2 of sItems
      put 2 into item 3 of sItems
   end if
   return true
end _NormaliseItems


--> Objects
-
getprop arrow_View
   return the long id of me
end arrow_View

getprop view_Object
   return the long id of me
end view_Object
