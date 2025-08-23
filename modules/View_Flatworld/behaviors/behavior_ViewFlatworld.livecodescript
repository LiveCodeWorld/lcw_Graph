script "behavior_ViewFlatworld"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewFlatworld
type: behavior
version: 0.1

--> Variables
-
-- startx and starty already declared 
-- but maybe should be different name?
-
local xStartLoc, yStartLoc


--> Working on
-

--> Geometry
-
on resizeControl
   LayoutControl
end resizeControl

setprop view_Rect someRect
   LayoutControl
end view_Rect

command LayoutControl pRect
   if pRect is empty then put the rect of me into pRect
   
   put the flatworld_Background of me into fwBackground
   set the rect of fwBackground to pRect
   set the rect of me to pRect
end LayoutControl

getprop arrow_Loc
   put the view_Object of the target into someNode
   return groupArrowCentre(someNode)
end arrow_Loc


--> Flatworld | Events
-
command flatworld_ClearMoved
   # clear buffer
   put false into Control_Link
   put empty into CreatedArrow
   put empty into MovedObject
   
   put empty into StartX
   put empty into StartY
   put empty into StartXOffset
   put empty into StartYOffset
   put empty into StartArrowLoc
end flatworld_ClearMoved

command flatworld_InitGeometry startLoc
   put empty into CreatedArrow
   
   put item 1 of startLoc into StartX
   put startX - item 1 of the loc of movedObject into StartXOffset
   put item 2 of startLoc into StartY
   put startY - item 2 of the loc of movedObject into StartYOffset
   -- put the rect of graphic "Simpl Graphic" of movedObject into StartMoveRect
end flatworld_InitGeometry

command flatWorld_MouseRelease fromGroup, someLoc
   -- put within_Node into toGroup -- unfortunately not mouseEnter sent
   put flatworld_MouseWithinNode(fromGroup) into toGroup
   
   if exists(toGroup) is false then
      -- create a node
      put fromGroup into inGroup
      delete word 1 to 4 of inGroup
      flatworld_CreateNode "New", inGroup, someLoc
      put the result into toGroup
   end if
   
   if exists(CreatedArrow) is true then
      -- position link
      put centre_Arrows(fromGroup, toGroup) into linePoints
      set the points of CreatedArrow to linePoints
      set_LinkArray fromGroup, toGroup, "centre", CreatedArrow
      put empty into CreatedArrow
   end if
end flatWorld_MouseRelease

command flatworld_MouseMoveScroll someLoc
   -- was used by "mouseMove"
   if rect_WithinBorder(someLoc) then
      autoBorderScroll x, y
   else
      cancelBorderScroll
   end if
end flatworld_MouseMoveScroll

command flatworld_MouseDownOnCard
   -- not sent if selection tool selected
   select empty
   if the controlkey is "Down" then
      menu_PopUp "Global | Flatworld | Menu"
   else
      put item 1 of the mouseloc into xStartLoc
      put item 2 of the mouseloc into yStartLoc
      
      put the vscroll of me into startY
      put the hscroll of me into startX
   end if
end flatworld_MouseDownOnCard

command flatworld_MouseMoveOnCard x, y
   if the mouse is "Down" then
      -- <scott> Mousemove sent before mouseDown? </scott>
      if xStartLoc is empty then
         -- so have to skip first time
      else if xStartLoc is not empty then
         put x - xStartLoc into xVector
         put y - yStartLoc into yVector
         put startY - yVector into newY
         put startX - xVector into newX
         
         lock screen
         put the long id of me into flatworldView
         set the vscroll of flatworldView to newY
         set the hscroll of flatworldView to newX
         -- 
         unlock screen
      end if
   end if
end flatworld_MouseMoveOnCard

command flatworld_MouseUpOnCard
   put empty into startX
   put empty into startY
   put empty into xStartLoc
   put empty into yStartLoc
   
   -- put the long id of me into flatworldView
   -- flatworld_ResetBackground flatworldView
end flatworld_MouseUpOnCard

function flatworld_MouseWithinNode fromGroup
   -- was "mouseWithinNode"
   put the long id of fromGroup into fromGroupOwner
   delete word 1 to 4 of fromGroupOwner
   
   put the flatWorld_Nodes [true] of fromGroupOwner into nestedNodes
   
   repeat with lineNum = 1 to the number of lines of nestedNodes
      put line lineNum of nestedNodes into someNode
      if someNode is fromGroup then next repeat
      if within(someNode, the mouseLoc) is true then
         if the zoomed of someNode is true then
            next repeat
         else
            return someNode
         end if
      end if
   end repeat
   return empty
end flatworld_MouseWithinNode


--> Events
-
on deletegroup
   put the long id of the target into someNode
   
   lock screen
   deleteGroupLinks someNode
   
   put the selected_Nodes of me into someNodes
   object_WithinStackReference someNode
   put line_DeleteFromIndex(someNode, someNodes) into someNodes
   set the selected_Nodes of me to someNodes
   unlock screen
   
   pass deletegroup
end deletegroup

-- on selectedObjectChanged
-- usually targetobject = selectedobject
-- unless there are scripts that change what is selected in the target
-- ie a lower "selectedObjectChanged" handler
-- or
-- if clicking on the card and deselecting,
-- in which case "selectedObject" = empty and targetObject = previously selectedObject

-- put the long id of the target into oldSelected
put the selectedobject into newlySelected
if newlySelected is empty then pass selectedObjectChanged

-- put the name of newlySelected
flatworld_ClearMoved

if newlySelected = the long id of me then
   select empty
else if newlySelected contains the flatworld_Background of me then
   -- probably selected image
   -- use to deselect
   select empty
else
   put the flatworld_TopNode of newlySelected into topNode
   if exists(topNode) then
      -- problem is that once the group is selected the original target cant be used to drag things around
      -- other groups a title for instance can be used.
      set lockmessages to true	# so as not to retrigger this message
      select topNode
      focus on this card
   else
      -- put topNode
      -- select empty
   end if
end if
pass selectedObjectChanged
end selectedObjectChanged

on moveControl
   put the flatworld_TopNode of the target into topNode
   if exists(topNode) then
      get the node_ResetPoints of topNode
   end if
   pass moveControl
end moveControl

on resizeControl
   put the flatworld_TopNode of the target into topNode
   if exists(topNode) then
      set the view_Rect of topNode to the rect of topNode
   else
      put topNode
   end if
   pass resizeControl
end resizeControl


--> Events | Node | Move
-
local MovedObject, CreatedArrow, Control_Link
local StartX, StartY, StartXOffset, StartYOffset, StartArrowLoc

on mouseDown which
   put the clickloc into startLoc
   
   -- put the view_Object of the target into MovedObject
   put the flatworld_TopNode of the target into MovedObject
   
   /*
   put the long id of the target into clickedObject
   put clickedObject into MovedObject
   delete word 1 to 4 of MovedObject
   */
   
   put the zoomed of MovedObject is not true into isNotZoomed
   if isNotZoomed then -- locks zoomed object
      put MovedObject into fromGroup
      
      if the select_Groups of the target is true then
         toggle_SelectGroup fromGroup
      else
         flatworld_InitGeometry startLoc
         if the controlkey is "Down" and CreatedArrow is empty then
            put true into Control_Link
            put the loc of fromGroup into StartArrowLoc
            
            createNewArrow true, fromGroup
            put the result into CreatedArrow
            choose browse tool
         else
            --flatworld_ClearMoved
            --put "Not"
         end if
      end if
   end if
   pass mouseDown
end mouseDown

on mouseMove x, y
   if MovedObject is empty then pass mouseMove
   if the mouse is not "down" then pass mouseMove
   
   if the zoomed of MovedObject is not true then
      put x,y into someLoc
      -- flatworld_MouseMoveScroll someLoc
      if the controlkey is "Down" and StartArrowLoc is not empty and exists(CreatedArrow) then
         -- just draw arrow
         put StartArrowLoc into line 1 of linePoints
         put the mouseloc into line 2 of linePoints
         set the points of CreatedArrow to linePoints
         -- put linePoints
      else if MovedObject is not empty and the presentation_Lock of this stack is not true then
         -- move MovedObject + redraw arrows
         put x - StartXOffset into xoffset
         put y - StartYOffset into yoffset
         try
            put xOffset,yOffset into newLoc
            node_Move MovedObject, newLoc
         catch errorNum
            -- not sure why - but sometimes MovedObject = cardObject
            flatworld_ClearMoved
            exit to top
         end try
      end if
   end if
   pass mouseMove
end mouseMove

on mouseRelease
   if Control_Link is true then
      put the mouseloc into someLoc
      flatWorld_MouseRelease MovedObject, someLoc
   end if
   flatworld_ClearMoved
   pass mouseRelease
end mouseRelease

on mouseUp
   put the view_Object of the target into mouseUpGroup
   -- put the long id of the target into mouseUpGroup
   if word 1 of mouseUpGroup is "card" then
      flatworld_MouseUpOnCard
   else
      -- delete word 1 to 4 of mouseUpGroup
      if mouseUpGroup is MovedObject and CreatedArrow is not empty then
         deleteArrow
      else if word 1 of mouseUpGroup is "group" then
         -- normal mouseUp
         node_DisplayContents mouseUpGroup
      end if
   end if
   flatworld_ClearMoved
   pass mouseUp
end mouseUp

on mouseEnter
   flatworld_ClearMoved
   -- if the controlkey is "Up"  then node_Enter
   pass mouseEnter
end mouseEnter

on mouseLeave
   -- if the controlkey is "Up" then node_Leave
   pass mouseLeave
end mouseLeave


--> Events | Node | Display
-
on node_Enter
   set the lockcursor to true
   set the cursor to cross
   
   put the view_Object of the target into someNode
   put the roll_Over of someNode into whichType
   switch whichType
      case ""
         -- do nothing
         break
      case "show"
         rollover_ShowHidden someNode
         break
      case "hide"
         frontLinks_Show someNode, false
         break
      case "ball"
         ball_Animate someNode, 5
         break
      default
         put word 1 of whichType into linkType
         emphasizeNode someNode, linkType
   end switch
end node_Enter

on node_Leave
   set the lockcursor to false
   set the cursor to hand
   
   put the view_Object of the target into someNode
   put the roll_Over of someNode into whichType
   switch whichType
      case "zombie"
         break
      default
         link_ResetStyle someNode
   end switch
end node_Leave

on link_ResetStyle someNode
   if someNode is empty then put the view_Object of the target into someNode
   
   put flatWorld_GetArrowLinks(someNode, linkArray) into arrowLinks
   lock screen
   emphasizeLinks arrowLinks, 1, someNode
end link_ResetStyle


--> Dot
-
getprop dot_Text
   put the flatworld_Background of the target into imageView
   return the uOPN ["dot_Text"] of imageView
end dot_Text

setprop dot_Text [graphStyle] dotText
   put the flatworld_Background of the target into imageView
   set the uOPN ["dot_Text"] of imageView to dotText
   
   put empty into rootFolder
   graph_SaveAndDisplayDot dotText, graphStyle, 12, rootFolder, imageView
end dot_Text


--> Flatworld | Nodes
-
getprop flatworld_TopNode
   /*
   The top node of the target. 
   That is the top node of any nested hierarchy.
   Not the first node in the flatworld_View,
   indeed "the flatworld_TopNode of the flatworld_View" is empty
   */
   
   put empty into topNode
   put empty into relativeTarget
   
   put the long id of the target into targetView
   put the long id of me into flatWorldView
   put the flatworld_Background of me into flatworldBackground
   
   if targetView contains flatworldBackground then
      if word 1 of targetView = "graphic" then
         return "arrow"
      else
         return "flatworldBackground"
      end if
   else
      put the number of words of targetView - the number of words of flatWorldView into wordStart
      
      put targetView into relativeTarget
      delete word wordStart to -1 of relativeTarget
      put word -3 to -1 of relativeTarget into topNode
      return topNode
   end if
end flatworld_TopNode

getprop flatworld_NodeIDs [visibleOnly]
   put the object_TopGroupIDs [visibleOnly] of me into nodeIDs
   put the flatworld_Background of flatworldView into flatworldBackground
   put the short id of flatworldBackground into backgroundID
   line_Delete backgroundID, nodeIDs
   return nodeIDs
end flatworld_NodeIDs

getprop flatWorld_Nodes [visibleOnly]
   /*
   This should return all nodes - including nested nodes.
   
   At the moment it assumes nodes are top groups.
   So no nested nodes. This allows views to contain groups and not be considered nested nodes.
   Need to enhance with special nested node.
   */
   return the flatWorld_TopNodes [visibleOnly] of me
   
   
   put the long id of me into flatworldView
   
   -- put visibleOnly is true into visibleOnly
   -- put object_ControlsInside(flatworldView, true, visibleOnly) into someNodes
   -- filter someNodes without "graphic *"
   -- put object_GroupsInside(flatworldView, true, visibleOnly) into someNodes
   
   put the flatworld_Background of flatworldView into flatworldBackground
   object_SetShortStackName flatworldBackground, mainStackStart, mainStackEnd
   line_Delete flatworldBackground, someNodes
   return someNodes
end flatworld_Nodes

getprop flatWorld_TopNodes [visibleOnly]
   put the long id of me into flatworldView
   put the object_TopGroups [visibleOnly] of flatworldView into someNodes
   put the flatworld_Background of flatworldView into flatworldBackground
   object_SetShortStackName flatworldBackground, mainStackStart, mainStackEnd
   line_Delete flatworldBackground, someNodes
   return someNodes
end flatworld_TopNodes

getprop flatWorld_Objects
   put the long id of me into flatworldView
   put the flatWorld_TopNodes of flatworldView into allObjects
   put the flatWorld_Arrows of flatworldView into arrowObjects
   line_Insert arrowObjects, allObjects
   return allObjects
end flatWorld_Objects

getprop screen_Nodes
   put the flatworld_View of the target into flatworldView
   if exists(flatworldView) is false then return empty
   
   put the card_Object of flatworldView into cardObject
   put the rect of cardObject into someRect
   return nodesWithinRect(someRect, nodeRectArray, flatworldView)
end screen_Nodes


--> Flatworld | Node | Creation
-
setprop flatworld_InsertView [nodeName] viewName
   put the flatworldLibrary_View of me into inGroup
   flatworld_CreateNode nodeName, inGroup, empty, viewName
   return the result
end flatworld_InsertView

setprop flatworld_NewNode [locOrRect] nodeName
   put the flatworldLibrary_View of me into inGroup
   flatworld_CreateNode nodeName, inGroup, locOrRect
   return the result
end flatworld_NewNode

setprop flatworld_DeletedNodes someNodes
   repeat for each line someNode in someNodes
      deleteNode someNode
   end repeat
end flatworld_DeletedNodes

on flatworld_CreateNode nodeName, inGroup, locOrRect, viewName
   -- was "node_SimpleCreate" or "createBasicNode"
   -- but inserted "viewName" param before "locOrRect"
   if inGroup is empty then put the flatworldLibrary_View of me into inGroup
   if viewName is empty then put "View|Graph|Flatworld|Node|Simple" into viewName
   
   lock screen
   --
   set the view_Insert of inGroup to viewName
   put the result into createdNode
   if exists (createdNode) is false then exit to top
   
   set the name of createdNode to nodeName
   set the node_Label of createdNode to nodeName
   
   custom_DeleteSet "opn_LinkArray", createdNode
   
   if locOrRect is a rect then
      set the view_Rect of createdNode to locOrRect
   else if locOrRect is a point then
      set the loc of createdNode to locOrRect
   else
      put the loc of inGroup into someLoc
      set the loc of createdNode to someLoc
   end if
   
   unlock screen
   return createdNode
end flatworld_CreateNode

on deleteNode someNode
   if someNode is empty then put the view_Object of the target into someNode
   put the flatworld_View of someNode into flatworldView
   
   lock screen
   deleteGroupLinks someNode
   delete someNode
   unlock screen
   
   object_WithinStackReference someNode
   put the selected_Nodes of flatworldView into someNodes
   put line_DeleteFromIndex(someNode, someNodes) into someNodes
   set the selected_Nodes of flatworldView to someNodes
end deleteNode

on flatWorld_DeleteLink someGroup, toGroup
   -- horrible hack!
   object_WithinStackReference toGroup
   
   lock screen
   put flatWorld_GetArrowLinks(someGroup, linkArray) into arrowObjects
   repeat for each line arrowObject in arrowObjects
      get linkArray[arrowObject]
      put line 1 of it into linkedObject
      
      if linkedObject is toGroup then
         delete_LinkReference arrowObject, someGroup
         delete_LinkReference arrowObject, toGroup
         delete arrowObject
      end if
   end repeat
   unlock screen
end flatWorld_DeleteLink

on deleteGroupLinks someGroup
   if exists(someGroup) then
      put flatWorld_GetArrowLinks(someGroup, linkArray) into someLinks
      repeat for each line linkObject in someLinks
         if exists(linkObject) then
            delete linkObject
         end if
         get linkArray[linkObject]
         put line 1 of it into backLinkObject
         delete_LinkReference linkObject, backLinkObject
      end repeat
   end if
end deleteGroupLinks


--> Flatworld | Arrows
-
getprop flatWorld_Arrows
   put the flatworld_Background of me into flatworldBackground
   
   put object_ControlsInside(flatworldBackground, true, false) into arrowObjects
   filter arrowObjects with "graphic *"
   return arrowObjects
end flatWorld_Arrows

on createNewArrow arrowVisible, someNode
   put the flatworld_View of someNode into scrollGroup
   
   put the flatworld_Background of someNode into flatworldBackground
   -- put someNode into flatworldBackground
   -- delete word 1 to 4 of flatworldBackground
   put the short id of flatworldBackground into groupOwnerID
   
   set the style of the templategraphic to "line"
   set the endarrow of templategraphic to true
   set the linesize of templategraphic to 1
   
   if arrowVisible is true then
      create graphic "Line" in group id groupOwnerID
   else
      create invisible graphic "Line" in group id groupOwnerID
   end if
   put it into newArrow
   
   -- put the relayergroupedcontrols into oRelayer
   -- set the relayergroupedcontrols to true
   -- put arrow_CreateLayer(groupOwnerID, scrollGroup) into arrowLayer
   -- set the layer of newArrow to arrowLayer
   -- set the relayergroupedcontrols to oRelayer
   
   put the opn_ScriptStore["arrow"] of someNode into lineScript
   if lineScript is empty then put the opn_ScriptStore["arrow"] of scrollGroup into lineScript
   set the script of newArrow to lineScript
   
   return newArrow
end createNewArrow

function arrow_CreateLayer groupOwnerID, scrollGroup
   -- this is where arrows are created
   if groupOwnerID = the short id of scrollGroup then
      return the layer of scrollGroup + 1
   else
      get the layer of graphic "Simpl Graphic" of group id groupOwnerID
      return it + 1
   end if
end arrow_CreateLayer

on arrow_Delete arrowObject
   put the link_Object of arrowObject into linkObject
   put the backLink_Object of arrowObject into backLinkObject
   
   lock screen
   delete_LinkReference arrowObject, linkObject
   delete_LinkReference arrowObject, backLinkObject
   delete arrowObject
   unlock screen
end arrow_Delete

on arrow_SetLinkType arrowObject, linkType, linkWidth, linkColour, linkArrow
   -- could also directly set-and-get arrowObject property
   object_WithinStackReference arrowObject
   put the link_Object of arrowObject into toGroup
   put the backLink_Object of arrowObject into fromGroup
   set_LinkArray fromGroup, toGroup, linkType, arrowObject, linkWidth, linkColour, linkArrow
end arrow_SetLinkType

function arrow_LinkType arrowObject
   -- could also directly set-and-get arrowObject property
   object_WithinStackReference arrowObject
   put the backLink_Object of arrowObject into fromGroup
   
   put flatWorld_GetArrowLinks(fromGroup, linkArray) into arrowObjects
   put linkArray[arrowObject] into linkData
   put line 2 of linkData into linkType
   return linkType
end arrow_LinkType

on flatWorld_DeleteArrowReferences arrowObject, someNode
   if exists(someNode) then
      put flatWorld_GetArrowLinks(someNode, linkArray) into oldLinks
      delete local linkArray[arrowObject]
      flatWorld_SetArrowLinks someNode, linkArray
   else
      put the params
      opn_Answer "Reference for arrow does not exist!"
   end if
end flatWorld_DeleteArrowReferences

on deleteArrow
   if exists(createdArrow) then
      put createdArrow into fromGroup
      delete word 1 to 4 of fromGroup
      
      lock screen
      delete createdArrow
      set the visible of fromGroup to false
      set the visible of fromGroup to true
      unlock screen
   end if
   put empty into createdArrow
end deleteArrow

getprop arrow_Links
   put the view_Object of the target into someNode
   put flatWorld_GetArrowLinks(someNode, linkArray) into arrowObjects
   return arrowObjects
end arrow_Links

getprop front_ArrowLinks
   put the view_Object of the target into someNode
   return flatWorld_FrontArrows(someNode)
end front_ArrowLinks

getprop back_ArrowLinks
   put the view_Object of the target into someNode
   return flatWorld_BackArrows(someNode)
end back_ArrowLinks

getprop arrow_colour
   put the long id of the target into arrowObject
   put the colour_Name of arrowObject into arrowColour
   if arrowColour is empty then
      return "None"
   else
      return arrowColour
   end if
end arrow_colour

setprop arrow_colour someColour
   put the long id of the target into arrowObject
   set the foregroundcolor of arrowObject to someColour
   set the colour_Name of arrowObject to someColour
end arrow_colour


--> Flatworld
-
getprop flatWorld_Name
   return wiki_GetName()
end flatWorld_Name

setprop flatWorld_Name someName
   set the name of this card to someName
end flatWorld_Name

getprop chapter_Names
   put the flatworld_View of me into flatworldView
   return flatWorld_ChapterNames(flatworldView)
end chapter_Names


--> Flatworld | Display
-
getprop show_Scrollbars
   return the vscrollbar of me
end show_Scrollbars

setprop show_Scrollbars boolean
   showScrollbars boolean
end show_Scrollbars


--> Flat | Image Maps
-
setprop exported_ImageMap someRect
   return construct_ImageMap(someRect)
end exported_ImageMap

setprop node_SnapShot nodeIndex
   put the long id of btn "Flat World Menu" into showIndex
   groupShot nodeIndex, true, showIndex
   return the result
end node_SnapShot


--> Node
-
getprop node_Pinned
   return the uOPN ["fixed_NodePositions"] of me to someBoolean
end node_Pinned

setprop node_Pinned someBoolean
   set the uOPN ["fixed_NodePositions"] of me to someBoolean
end node_Pinned

getprop node_Position
   put the flatworld_View of me into flatworldView
   put the view_Object of the target into someNode
   
   put item 1 of the loc of someNode - the left of flatworldView into xPos
   -- put item 2 of the loc of someNode - the top of flatworldView into yPos
   put the top of flatworldView - item 2 of the loc of someNode into yPos
   put xPos,yPos into somePosition
   dot_ConvertToInches somePosition
   return somePosition
end node_Position

getprop node_IDs [visibleOnly]
   -- get the short ids of all nodes within the target view
   return the object_TopGroupIDs [visibleOnly] of the target
end node_IDs

getprop node_Label
   put the view_Object of the target into someNode
   return the view_Label of someNode
end node_Label

setprop node_Label someLabel
   put the view_Object of the target into someNode
   set the view_Label of someNode to someLabel
end node_Label

getprop node_FillStyle
   return "filled"
   
   put the view_Object of the target into someNode
   if the opaque of someNode is true then
      return "filled"
   else
      return empty
   end if
end node_FillStyle

setprop node_FillStyle fillStyle
   put the view_Object of the target into someNode
   if fillStyle is "filled" then
      set the opaque of someNode to true
   else
      set the opaque of someNode to false
   end if
end node_FillStyle

getprop node_Names
   put the flatworld_View of the target into flatworldView
   return flatWorld_ChapterNames(flatworldView)
end node_Names

getprop node_LongIndex
   put the flatworld_View of the target into flatworldView
   return node_LongIDs(flatworldView, true)
end node_LongIndex


--> Node | Defaults
-
getprop view_Label
   -- in case it is not defined use the groups short name
   return the short name of the view_Object of the target
end view_Label

setprop view_Label someLabel
   -- in case it is not defined use the groups short name
   set the name of the view_Object of the target to someLabel
end view_Label

getprop view_Shape
   return empty
end view_Shape

getprop view_Style
   return empty
end view_Style

getprop view_BorderColour
   return the bordercolor of the view_Object of the target
end view_BorderColour

getprop view_FillColour
   return the backgroundcolor of the view_Object of the target
end view_FillColour

getprop view_Url
   return empty
end view_Url

getprop view_Image
   return empty
end view_Image


--> Node | Links
-
getprop node_FrontLinks
   put the view_Object of the target into someNode
   return flatWorld_FrontLinkNodes(someNode)
end node_FrontLinks

setprop node_Link toGroup
   put the view_Object of the target into someNode
   
   flatWorld_SetArrowLinks toGroup, empty
   linkGroups someNode, toGroup
   return the result
end node_Link

on linkGroups someNode, toGroups
   -- one to many
   repeat for each line toGroup in toGroups
      createNewArrow false, someNode
      put the result into newArrowObject
      
      put centre_Arrows(someNode, toGroup) into linkPoints
      set the points of newArrowObject to linkPoints
      choose browse tool
      show newArrowObject
      set_LinkArray someNode, toGroup, "centre", newArrowObject
   end repeat
end linkGroups

setprop copy_Links copyGroup
   set_TargetNode newGroup
   
   put flatWorld_GetArrowLinks(copyGroup, copyLinkArray) into copyLinks
   links_ResetFromArray newGroup, copyLinkArray
end copy_links

on links_ResetFromArray someNode, oldLinkArray
   repeat for each line linkArrow in keys(oldLinkArray)
      put oldLinkArray[linkArrow] into linkData
      deconstruct_LinkData linkData, linkGroup, linkDirection, linkType, linkWidth, linkColour, bugArrow
      
      if linkDirection is "forward" then
         put someNode into someNode
         put linkGroup into toGroup
      else
         put linkGroup into someNode
         put someNode into toGroup
      end if
      
      delete_LinkReference linkArrow, someNode
      set_LinkArray someNode, toGroup, "centre", linkArrow
      
      put centre_Arrows(someNode, toGroup) into linkPoints
      set the points of linkArrow to linkPoints
   end repeat
end links_ResetFromArray

on draw_ArrayLinks linkArray
   repeat for each line someNode in keys(linkArray)
      put linkArray[someNode] into toGroups
      linkGroups someNode, toGroups
   end repeat
end draw_ArrayLinks

on set_LinkArray fromGroup, toGroup, linkType, newArrowObject, linkWidth, linkColour, linkArrow
   object_WithinStackReference fromGroup
   object_WithinStackReference toGroup
   object_WithinStackReference newArrowObject
   
   set the link_Object of newArrowObject to toGroup
   set the backLink_Object of newArrowObject to fromGroup
   
   -- if a param is empty don't set
   put model_GetArray("opn_LinkArray", fromGroup) into linkArray
   put linkArray[newArrowObject] into linkData
   put construct_LinkData(toGroup, "forward", linkType, linkWidth, linkColour, linkArrow, linkData) into linkData
   put linkData into linkArray[newArrowObject]
   model_SetArray "opn_LinkArray", fromGroup, linkArray
   
   put model_GetArray("opn_LinkArray", toGroup) into linkArray
   put linkArray[newArrowObject] into linkData
   put construct_LinkData(fromGroup, "back", linkType, linkWidth, linkColour, linkArrow, linkData) into linkData
   put linkData into linkArray[newArrowObject]
   model_SetArray "opn_LinkArray", toGroup, linkArray
end set_LinkArray

function construct_LinkData someGroup, linkDirection, linkType, linkWidth, linkColour, linkArrow, linkData
   put someGroup into line 1 of linkData
   
   -- if a param is empty don't set
   if linkDirection is not empty then put linkDirection into item 1 of line 2 of linkData
   if linkType is not empty then put linkType into item 2 of line 2 of linkData
   
   if linkWidth is not empty then put linkWidth into line 3 of linkData
   if linkColour is not empty then put linkColour into line 4 of linkData
   if linkArrow is not empty then put linkArrow into line 5 of linkData
   
   return linkData
end construct_LinkData

on deconstruct_LinkData linkData, @someGroup, @linkDirection, @linkType, @linkWidth, @linkColour, @linkArrow
   put line 1 of linkData into someGroup
   put item 1 of line 2 of linkData into linkDirection
   put item 2 of line 2 of linkData into linkType
   
   put line 3 of linkData into linkWidth
   put line 4 of linkData into linkColour
   put line 5 of linkData into linkArrow
end deconstruct_LinkData

on node_Move movedObject, newLoc
   set the loc of movedObject to newLoc
   node_MovedResetPoints movedObject
end node_Move

getprop node_ResetPoints
   put the long id of the target into movedObject
   node_MovedResetPoints movedObject
   return the result
end node_ResetPoints

on node_MovedResetPoints movedObject
   put flatWorld_GetArrowLinks(movedObject, linkArray) into arrowObjects
   repeat for each line arrowObject in arrowObjects
      get linkArray[arrowObject]
      put line 1 of it into linkedObject
      if exists(linkedObject) is false then
         -- opn_Notify linkedObject
         delete_LinkReference arrowObject, movedObject
      end if
      
      put line 2 of it into linkType
      put item 1 of linkType into linkDirection
      switch item 2 of linkType
         case "centre"
            put centre_Arrows(movedObject, linkedObject, linkDirection) into newPoints
            break
         case "step"
            put step_Arrows(movedObject, linkedObject, linkDirection) into newPoints
            break
         default
            -- answer "Unknown link type"
      end switch
      
      if exists(arrowObject) then
         set the points of arrowObject to newPoints
      else
         -- answer arrowObject
         delete_LinkReference arrowObject, movedObject
      end if
   end repeat
end node_MovedResetPoints

function centre_Arrows fromControl, toControl, linkDirection
   if linkDirection is "back" then
      put the loc of fromControl into line 2 of linePoints
      put the loc of toControl into line 1 of linePoints
   else
      put the loc of fromControl into line 1 of linePoints
      put the loc of toControl into line 2 of linePoints
   end if
   return linePoints
end centre_Arrows

function flatWorld_LinkedNodes fromNode, @linkArray
   put flatWorld_GetArrowLinks(fromNode, linkArray) into arrowObjects
   put empty into groupLinks
   repeat for each line arrowObject in arrowObjects
      get linkArray[arrowObject]
      put line 1 of it into linkedObject
      put line 2 of it into arrowType
      put item 1 of arrowType into arrowDirection
      put linkedObject & return after groupLinks
   end repeat
   delete last char of groupLinks
   return groupLinks
end flatWorld_LinkedNodes

function flatWorld_FrontLinkNodes fromNode, scrollGroup
   put flatWorld_GetArrowLinks(fromNode, linkArray) into arrowObjects
   put empty into groupLinks
   repeat for each line arrowObject in arrowObjects
      get linkArray[arrowObject]
      put line 1 of it into linkedObject
      put line 2 of it into arrowType
      put item 1 of arrowType into arrowDirection
      if arrowDirection is "forward" then
         if scrollGroup is empty then
            put linkedObject & return after groupLinks
         else
            put the short id of linkedObject into someID
            put the long id of group id someID of scrollGroup into longLinkedObject
            put longLinkedObject & return after groupLinks
         end if
      end if
   end repeat
   delete last char of groupLinks
   return groupLinks
end flatWorld_FrontLinkNodes

function flatWorld_BackLinkNodes fromNode, scrollGroup
   put flatWorld_GetArrowLinks(fromNode, linkArray) into arrowObjects
   put empty into groupLinks
   repeat for each line arrowObject in arrowObjects
      get linkArray[arrowObject]
      put line 1 of it into linkedObject
      put line 2 of it into arrowType
      put item 1 of arrowType into arrowDirection
      if arrowDirection is "back" then
         if scrollGroup is empty then
            put linkedObject & return after groupLinks
         else
            put the short id of linkedObject into someID
            put the long id of group id someID of scrollGroup into longLinkedObject
            put longLinkedObject & return after groupLinks
         end if
      end if
   end repeat
   delete last char of groupLinks
   return groupLinks
end flatWorld_BackLinkNodes

function flatWorld_BackArrows someNode
   put flatWorld_GetArrowLinks(someNode, linkArray) into arrowObjects
   put empty into backArrows
   repeat for each line arrowObject in arrowObjects
      get linkArray[arrowObject]
      put line 1 of it into linkedObject
      put line 2 of it into arrowType
      put item 1 of arrowType into arrowDirection
      if arrowDirection is "back" then
         put arrowObject & return after backArrows
      end if
   end repeat
   delete last char of backArrows
   return backArrows
end flatWorld_BackArrows

function flatWorld_FrontArrows someGroup
   put flatWorld_GetArrowLinks(someGroup, linkArray) into arrowObjects
   put empty into frontArrows
   repeat for each line arrowObject in arrowObjects
      get linkArray[arrowObject]
      put line 1 of it into linkedObject
      put line 2 of it into arrowType
      put item 1 of arrowType into arrowDirection
      if arrowDirection is "forward" then
         put arrowObject & return after frontArrows
      end if
   end repeat
   delete last char of frontArrows
   return frontArrows
end flatWorld_FrontArrows

function flatWorld_GetArrowLinks someGroup, @linkArray
   -- returns the arrows linked to group
   put model_GetArray("opn_LinkArray", someGroup) into linkArray
   return keys(linkArray)
end flatWorld_GetArrowLinks

on flatWorld_SetArrowLinks someGroup, newLinkArray
   model_SetArray "opn_LinkArray", someGroup, newLinkArray
end flatWorld_SetArrowLinks

on delete_LinkReference arrowObject, someNode
   object_WithinStackReference someNode
   object_WithinStackReference arrowObject
   
   flatWorld_DeleteArrowReferences arrowObject, someNode
end delete_LinkReference

getprop first_Group
   put the flatworld_View of me into flatworldView
   put the first_Group of flatworldView into firstGroup
   if firstGroup is empty then
      put the short name of group 3 of flatworldView into firstGroup
   end if
   return firstGroup
end first_Group

getprop back_Links
   put the view_Object of the target into someNode
   return flatWorld_BackLinkNodes(someNode)
end back_Links

getprop long_BackLinks
   put the view_Object of the target into someNode
   put the long id of me into flatworldView
   return flatWorld_BackLinkNodes(someNode, flatworldView)
end long_BackLinks

getprop long_FrontLinks
   put the view_Object of the target into someNode
   put the long id of me into flatworldView
   return flatWorld_FrontLinkNodes(someNode, flatworldView)
end long_FrontLinks

getprop group_Links
   put the view_Object of the target into someNode
   put flatWorld_GetArrowLinks(someNode, linkArray) into arrowObjects
   
   put empty into groupLinks
   repeat for each line arrowObject in arrowObjects
      get linkArray[arrowObject]
      put line 1 of it & return after groupLinks
      -- put line 2 of it into arrowType
   end repeat
   delete last char of groupLinks
   return groupLinks
end group_Links

getprop long_LinkObject
   put the long id of the target into arrowObject
   put the link_Object of arrowObject into someObject
   return the long id of someObject
end long_LinkObject

getprop long_BackLinkObject
   put the long id of the target into arrowObject
   put the backLink_Object of arrowObject into someObject
   return the long id of someObject
end long_BackLinkObject


--> Flat | Selection
-
getprop selected_Nodes
   put the flatworld_View of the target into flatworldView 
   put the node_Sets["Selected"] of flatworldView into selectedNodes
   return selectedNodes
end selected_Nodes

setprop selected_Nodes selectedNodes
   put the flatworld_View of the target into flatworldView
   set the node_Sets["Selected"] of flatworldView to selectedNodes
end selected_Nodes

getprop selected_GroupNum
   put the view_Object of the target into someNode
   object_SetIdReference someNode
   put the selected_Nodes of me into someNodes
   put lineOffset(someNode, someNodes) into lineNum
   return lineNum
end selected_GroupNum

setprop selected_State boolean
   put the view_Object of the target into someNode
   put the flatworld_View of me into flatworldView
   selectNodes someNode, boolean, flatworldView
   return the result
end selected_State


--> Objects
-
getprop flatworld_View
   -- was "flatScroll_View"
   return the long id of me
end flatworld_View

getprop view_Object
   return the long id of me
end view_Object

getprop flatworld_Background
   return the long id of group "_FlatWorld Background" of me
end flatworld_Background

getprop flatworld_Image
   return the background_Image of the flatworld_Background of me
end flatworld_Image

-- getprop menu_Button
   return the long id of btn "_Menu Button" of me
end menu_Button
