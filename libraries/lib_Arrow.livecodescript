script "lib_Arrow"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Arrow
type: library
version: 0.1

/*Some help*/


--> Working on
-
getprop border_Loc [pItems]
   put the rect of me into cRect
   put loc_OnBorder (cRect, pItems) into borderLoc
   return borderLoc
end border_Loc

getprop bottomRight_Rect [cWidth]
   if cWidth is empty then put 8 into cWidth
   put the rect of the target into brRect
   put item 3 of brRect - cWidth into item 1 of brRect
   put item 4 of brRect - cWidth into item 2 of brRect
   return brRect
end bottomRight_Rect

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
      case "b"
         put item 4 of cRect into myBottom
         add yFiddle to myBottom
         put myBottom into item 2 of bLoc
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
      default
         return empty
   end switch
end loc_OnBorder

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


--> Layout | Arrows
-
on LayoutArrows
   put the long id of the target into tObject
   --
   lock screen
   put the to_Arrows of tObject into toArrows
   repeat for each line aObject in toArrows
      if exists (aObject) is false then
         set the remove_ToArrow of tObject to aObject
         next repeat
      end if
      dispatch "LayoutControl" to aObject
   end repeat
   
   put the from_Arrows of tObject into fromArrows
   repeat for each line aObject in fromArrows
      if exists (aObject) is false then
         set the remove_FromArrow of tObject to aObject
         next repeat
      end if
      dispatch "LayoutControl" to aObject
   end repeat
   unlock screen
end LayoutArrows

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


--> Arrow
-
getprop arrow_LinkNames
   put the long id of the target into aView
   --
   put the arrow_LinkNames of aView into linkNames
   if linkNames is empty then
      put the long owner of aView into cObject
      if word 1 of cObject is not among the items of "group,card" then
         put the card_Object of aView into cObject
      end if
      
      put the top_ControlNames of cObject into linkNames
      put the short name of aView into aName
      line_Delete aName, linkNames
   end if
   return linkNames
end arrow_LinkNames

private function _NamedControl aView, fName
   put the named_View [fName] of aView into fObject
   if exists (fObject) is true then return fObject
   
   put the long owner of aView into cObject
   if word 1 of cObject is among the items of "group,card" then
      return cObject
   end if
   
   put the card_Object of aView into cObject
   if exists (control fName of cObject) then
      return the long id of control fName of cObject
   end if
end _NamedControl
