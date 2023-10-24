script "behavior_ViewTrelloRow"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewTrelloRow
type: behavior
version: 0.1

--> Working on
-
getprop view_Name
   return "View|Trello|Row"
end view_Name

getprop module_Name
   return "View_Trello_Row"
end module_Name


--> Events
-
on mouseDoubleUp pMouseBtnNum
    local theKey
    
    -- Example of how to edit the contents of a field.
    -- By passing the index of the record associated with copy of this template being displayed and
    -- a key (array key) the data grid will automatically save the changes the user
    -- makes and refresh the UI by calling FillInData and resizeControl.
    if pMouseBtnNum is 1 then
        if the dgProps["allow editing"] of the dgControl of me then
            switch the short name of the target
                case "Label"
                    put "Label 1" into theKey
                    EditFieldText the long ID of the target, the dgIndex of me, theKey
                    break                 
            end switch
        end if
    end if
    
    pass mouseDoubleUp
end mouseDoubleUp


--> Layout
-
on LayoutControl pControlRect, pWorkingRect
   if pWorkingRect is empty then
      put pControlRect into pWorkingRect
   end if
   put _ImageObject() into imageObject
   --
   put 38 into titleHeight
   put 8 into sMargin
   put rect_Subtract (sMargin, pWorkingRect) into innerRect
   --
   put innerRect into fieldRect
   put item 2 of innerRect + titleHeight into fieldBottom
   put fieldBottom into item 4 of fieldRect
   --
   -- put 227 into imageHeight
   put image_Height (innerRect, imageObject) into imageHeight
   --
   put fieldBottom + sMargin into imageTop
   put innerRect into imageRect
   put imageTop + imageHeight into imageBottom
   put imageTop into item 2 of imageRect
   put imageBottom into item 4 of imageRect
   --
   put 30 into audioHeight
   put innerRect into audioRect
   put imageBottom + sMargin into audioTop
   put audioTop + audioHeight into audioBottom
   put audioTop into item 2 of audioRect
   put audioBottom into item 4 of audioRect
   
   put pControlRect into graphicRect
   put audioBottom + sMargin into item 4 of graphicRect
   
   lock screen
   set the rect of _TitleField() to fieldRect
   set the rect of imageObject to imageRect
   set the rect of _PlayerObject() to audioRect
   set the rect of _BackgroundGraphic() to graphicRect
   unlock screen
end LayoutControl

private function image_Height innerRect, imageObject
   put the formattedwidth of imageObject into fWidth
   if fWidth is 0 then put the width of imageObject into fWidth
   put the formattedheight of imageObject into fHeight
   if fHeight is 0 then put the height of imageObject into fHeight
   --
   put item 3 of innerRect - item 1 of innerRect into sWidth
   put fHeight * sWidth/fWidth into newHeight
   return newHeight
end image_Height


--> Data
-
on FillInData cardArray
   put cardArray ["name"] into rocketCardName
   replace ".jpg" with empty in rocketCardName
   --
   put cardArray ["id"] into cardID
   put trello_GetCard (cardID) into cardData
   put cardData ["attachments"][1]["url"] into bigURL
   --
   set the text of _TitleField() to rocketCardName
   set the filename of _ImageObject() to bigURL
end FillInData

on ResetData
   -- Sent when data is being emptied because the control is no longer being used to display data
   set the text of _TitleField() to empty
   set the filename of _ImageObject() to empty
end ResetData

on PreFillInData
   -- Sent right before new data is going to replace existing data in the control
end PreFillInData

setprop dgHilite pBoolean
   -- This custom property is set when the highlight of your custom template has
   -- changed. By default the "Background" graphic will be highlighted for you. 
   -- You only add script here if you want to further customize the highlight.
   
   -- Example:
   if pBoolean then
      set the foregroundColor of me to the dgProp["hilited text color"] of the dgControl of me
   else
      set the foregroundColor of me to empty
   end if
end dgHilite


--> Objects
-
private function _TitleField
   return the long id of fld 1 of me
end _TitleField

private function _BackgroundGraphic
   return the long id of graphic "Background" of me
end _BackgroundGraphic

private function _PlayerObject
   return the long id of player 1 of me
end _PlayerObject

private function _ImageObject
   return the long id of image 1 of me
end _ImageObject
   
getprop dgDataControl
   -- Required by library so that it can locate your control.
   return the long ID of me
end dgDataControl

getprop view_Object
   return the long id of me
end view_Object
