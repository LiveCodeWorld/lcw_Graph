script "lib_Flatworld"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_Flatworld
type: library
version: 0.1

/*Some help*/


--> Working on
-


--> Flatworld
-
--> MetaData
-
name: FlatWorld
copyright: OPN Technologies LLP
author: David Bovill
type: library
version: 0.3

/*
--> Flatnode | Junk
-
on node_DisplayContents someNode
    -- put the long id of group "FlatWorld Display Node" into displayGroup
    -- set the displayed_Node of displayGroup to someNode
end node_DisplayContents

on opn_NodeEditor someNode
    if someNode is empty then put the view_Object of the target into someNode
    
    display_EditNode someNode
end opn_NodeEditor

on display_EditNode someNode
  --set the displayed_Node of stack "Node Editor" to someNode 
  --go to stack "Node Editor"
end display_EditNode

-- setprop link_Weight someWeight
  put the long id of the target into arrowObject
  set the graphViz_LinkWeight of arrowObject to someWeight
end link_Weight

-- getprop link_Weight
  put the long id of the target into arrowObject
  put the graphViz_LinkWeight of arrowObject into someWeight
  if someWeight is empty
end link_Weight

function node_LongIDs nestedGroup, noArrows
   breakpoint
   return the flatworld_Nodes [noArrows] of nestedGroup
end node_LongIDs

function screenNodes flatworldView
    -- put the screenRect into someRect
    breakpoint
    return the screen_Nodes of flatworldView
end screenNodes
*/

--> Events
-
on flatworld_ArrowKey which
    -- was "flatworld_Arrow"
    put the flatworld_View of the target into scrollGroup
    
    if the controlkey is "Up" then
        if which is "left" or which is "right" then
            put the width of this stack into someIncrement
        else
            put the height of this stack into someIncrement
        end if
    else if the shiftkey is "Down" then
        put 5 into someIncrement
    else
        put 1 into someIncrement
    end if
     
    put the rect of this card into cardRect
    if which is "left" then
        put translateRect(cardRect, - someIncrement, 0) into someRect
        if flat_NodesWithinRect(someRect, array_NodeRects, scrollGroup) is empty and the shiftkey is "Up" then
            exit to top
        else
            borderScroll -someIncrement, 0, scrollGroup
        end if
    else if which is "right" then
        put translateRect(cardRect, someIncrement, 0) into someRect
        if flat_NodesWithinRect(someRect, array_NodeRects, scrollGroup) is empty and the shiftkey is "Up" then
            exit to top
        else
            borderScroll someIncrement, 0, scrollGroup
        end if
    else if which is "up" then
        put translateRect(cardRect, 0, - someIncrement) into someRect
        if flat_NodesWithinRect(someRect, array_NodeRects, scrollGroup) is empty and the shiftkey is "Up" then
            exit to top
        else
            borderScroll 0, -someIncrement, scrollGroup
        end if
    else
        put translateRect(cardRect, 0, someIncrement) into someRect
        if flat_NodesWithinRect(someRect, array_NodeRects, scrollGroup) is empty and the shiftkey is "Up" then
            exit to top
        else
            borderScroll 0, someIncrement, scrollGroup
        end if
    end if
end flatworld_ArrowKey


--> Objects
-
getprop flatworldLibrary_View
    return the long id of group 1 of me
end flatworldLibrary_View

function object_BackgroundImage
    return the long id of image "Background Image" of group "Flat World Background" 
end object_BackgroundImage


--> Props
-
setprop link_Colour newColour
  -- should check it is an arrow object
  put the long id of the target into arrowObject
  --set the borderColor of arrowObject to newColour
  set the foregroundcolor of arrowObject to newColour
  arrow_SetLinkType arrowObject, "", "", newColour
end link_Colour

setprop link_Size newWidth
  -- should check it is an arrow object
  put the long id of the target into arrowObject
  set the linesize of arrowObject to newWidth
  arrow_SetLinkType arrowObject, "", newWidth
end link_Size

-- getprop graphic_Shape
    put the view_Object of the target into someNode
    put node_GraphicShape(someNode) into graphicShape
    return graphicShape
end graphic_Shape

getprop node_StyleInfo
    put the view_Object of the target into someNode
    return construct_StyleInfo(someNode)
end node_StyleInfo

setprop node_StyleInfo styleInfo
    put the view_Object of the target into someNode
    node_SetStyleFromInfo someNode, styleInfo
end node_StyleInfo

getprop stored_Sets
   put the long id of me into flatworldView
   return sets_GetStored(flatworldView)
end stored_Sets

getprop children_Visible
    put the view_Object of the target into someNode
    return the uOPN ["children_Visible"] of someNode
end children_Visible

setprop children_Visible someBoolean
    put the view_Object of the target into someNode
    put the flatworld_View of the target into flatworldView
    
    set the uOPN ["children_Visible"] of someNode to someBoolean
    if someBoolean is true then
        showSubGroups flatworldView
    else
        hideSubGroups flatworldView, someNode
    end if
end children_Visible

getprop wiki_HtmlText
  put the long id of the target into someNode
  put the long id of fld "Wiki Text" of someNode into fieldObject
  return the htmltext of fieldObject
end wiki_HtmlText


--> Flat | Node
-
function flat_NodesWithinRect someRect, @array_NodeRects, flatScrollView
    if flatScrollView is empty then put the flatworld_View of the target into flatScrollView
    
    put the flatWorld_TopNodes of flatScrollView into nodeIndex
     
    put empty into screenNodeRects
    repeat for each line someNode in nodeIndex
        put node_VisibleRect(someNode) into nodeRect
        if overLapping(nodeRect, someRect) is true then
            put nodeRect into array_NodeRects[someNode]
        end if
    end repeat
    return keys(array_NodeRects)
end flat_NodesWithinRect

function flatWorld_ChapterNames flatScrollView
    -- unique check hack
    put the flatWorld_TopNodes of flatScrollView into someNodes
    repeat for each line someObject in someNodes
        put the short name of someObject into groupName
        if array_GroupNames[groupName] is empty then
            put someObject into array_GroupNames[groupName]
        else
            put someObject into array_GroupNames[word 1 to 3 of someObject]
        end if
    end repeat
    return keys(array_GroupNames)
end flatWorld_ChapterNames


--> Flat | Node | Create
-
on cloneAndLink someNode
    get the selectedchunk
    if it is empty then
        put empty into cutText
    else
        put word 2 of it into startCharNum
        put it into fieldObject
        delete word 1 to 5 of fieldObject
        put the short id of fieldObject into fieldID
        put the text of fieldObject into fieldText
        put the number of chars of fieldText into lastCharNum
        put char startCharNum to lastCharNum of fieldText into cutText
        delete char startCharNum to lastCharNum of field id fieldID
    end if
     
    lock screen
    clone someNode
    put it into toGroup
    if cutText is empty then
        set the name of someNode to empty
    else
        set the text of field "Wiki Text" of toGroup to cutText
        resizeToFitText toGroup
        set the name of someNode to (word 1 to 4 of cutText && "...")
    end if
     
    -- put imageAdded(toGroup) into imageObject
    if the image_Object of toGroup not empty then
        delete imageObject
    end if
     
    put the loc of someNode into newLoc
    put the right of someNode into myRight
    put the width of someNode into myWidth
    put myRight + myWidth into item 1 of newLoc
    set the loc of toGroup to newLoc
     
    set the node_Style of someNode to "graphic"
    set the node_Link of someNode to toGroup
     
    unlock screen
    return toGroup
end cloneAndLink

on node_AddMedia someNode, linkNodeWikiUrl, linkNodeImage, linkNodeVideo, linkNode_LinkAction
    if linkNodeWikiUrl is not empty then
        put url linkNodeWikiUrl into someHtml
        set the node_HtmlText of someNode to someHtml
    end if
end node_AddMedia

function flatWorld_StyleNodes someStyle, flatScrollView
    -- unique check hack
    put the flatWorld_TopNodes of flatScrollView into someNodes
    put empty into styleNodes
    repeat for each line someNode in someNodes
        -- put the node_Style of someNode into nodeDisplayStyle
        put the node_Styleinfo of someNode into nodeDisplayStyle
        if nodeDisplayStyle is someStyle then
            put someNode & return after styleNodes
        end if
    end repeat
    delete last char of styleNodes
    return styleNodes
end flatWorld_StyleNodes

on showSubGroups flatworldView
    put the zoom_Hidden of flatworldView into nodeIndex
    repeat for each line someNode in nodeIndex
        showStars someNode, true
    end repeat
    set the zoom_Hidden of flatworldView to empty
    return nodeIndex
end showSubGroups

on hideSubGroups flatworldView, fromNode
    object_WithinStackReference fromNode
    put the flatWorld_TopNodes of flatworldView into nodeIndex
    line_Delete fromNode, nodeIndex
    put empty into hiddenNodes
    repeat for each line someNode in nodeIndex
        if the visible of someNode is true then
            showStars someNode, false
            put someNode & return after hiddenNodes
        end if
    end repeat
    delete last char of hiddenNodes
    set the zoom_Hidden of flatworldView to hiddenNodes
    return hiddenNodes
end hideSubGroups

function nodeSet_GetHidden flatworldView
    return the hidden_Sets of flatworldView
end nodeSet_GetHidden  

on nodeSet_DeleteFromHidden setName, flatworldView
  put the hidden_Sets of flatworldView into newSets
  line_Delete setName, newSets
  set the hidden_Sets of flatworldView to newSets
end nodeSet_DeleteFromHidden

on nodeSet_AddToHidden setName, flatworldView
  put the hidden_Sets of flatworldView into newSets
  line_Add setName, newSets
  set the hidden_Sets of flatworldView to newSets
end nodeSet_AddToHidden

on frontLinks_Show someNode, boolean
  object_WithinStackReference someNode
  put graph_Section(someNode) into nodeIndex
  line_Delete someNode, nodeIndex
  showStars nodeIndex, boolean
  if boolean is true then
    set the hidden_Nodes of someNode to empty
  else
    set the hidden_Nodes of someNode to nodeIndex
  end if
end frontLinks_Show

on node_Show someNode, boolean
    object_WithinStackReference someNode
    put graph_Section(someNode) into nodeIndex
    showStars nodeIndex, boolean
     
    put the back_Links of someNode into backLinkObjects
    repeat for each line backLinkObject in backLinkObjects
        if boolean is true then
            set the hidden_Nodes of backLinkObject to empty
        else
            set the hidden_Nodes of backLinkObject to nodeIndex
        end if
    end repeat
end node_Show

on showStars someNodes, someBoolean
    lock screen
    if someNodes is empty then put the long id of the target into someNodes
    repeat for each line someNode in someNodes
        put the arrow_Links of someNode into someArrows
        object_ShowAll someArrows, someBoolean
        set the visible of someNode to someBoolean
    end repeat
    unlock screen
end showStars


--> Flat | Select Nodes
-
on opn_SelectNodes whichNodes
    put the view_Object of the target into someNode
    flatWorld_SelectNodes whichNodes, someNode
end opn_SelectNodes

function node_GetSet setName, scrollGroup
  if scrollGroup is empty then
    put the view_Object of the target into someNode
    put the flatworld_View of someNode into scrollGroup
  end if
  return the node_Sets[setName] of scrollGroup into nodeIndex
end node_GetSet

on opn_AddToSet setName
    put the view_Object of the target into someNode
    put the flatworld_View of someNode into scrollGroup
    put the node_Sets[setName] of scrollGroup into nodeIndex
     
    if the optionkey is "Down" then 
        answer "Are you sure you want to remove this node from the stored set" && kwote(setName) with "Cancel" or "Remove"
        if it is "Cancel" then exit to top
        line_Delete  someNode, nodeIndex
    else
        line_Add  someNode, nodeIndex
    end if
    set the node_Sets[setName] of scrollGroup to nodeIndex
end opn_AddToSet

on opn_SelectSet setName
    put the view_Object of the target into someNode
    put the flatworld_View of someNode into scrollGroup
    switch setName
        case "Save selected"
            node_AskSaveSelected scrollGroup
            break
        default
            if the shiftkey is "Up" then deselect_Nodes
            if the optionkey is "Down" then 
                answer "Are you sure you want to delete the stored set" && kwote(setName) with "Cancel" or "Delete"
                if it is "Cancel" then exit to top
                node_DeleteSet setName, scrollGroup
            else
                put the node_Sets[setName] of scrollGroup into nodeIndex
                selectNodes nodeIndex, true, scrollGroup
            end if
    end switch
end opn_SelectSet

on  node_DeleteSet setName, scrollGroup
  set the custompropertyset of scrollGroup to node_Sets
  get the customkeys of scrollGroup
  set the wholematches to true
  delete line lineOffset(setName,it) of it
  set the customkeys of scrollGroup to it  
  set the custompropertyset of scrollGroup to empty
end node_DeleteSet

on node_AskSaveSelected scrollGroup
  put the selected_Nodes of scrollGroup into selectedNodes
  ask "What name would you like to save the selected nodes under?"
  put it into setName
  if setName is empty then exit to top
  set the node_Sets[setName] of scrollGroup to selectedNodes
end node_AskSaveSelected

on flatWorld_SelectNodes whichNodes, someNode
    put the flatworld_View of someNode into scrollGroup
    switch whichNodes
        case "toggle select"
            put the node_MenuFragment["SelectMenu"] of someNode into menuFragmentText
            put lineOffset("toggle", menuFragmentText) into lineNum
            put menu_GetChecked(lineNum, menuFragmentText) into toggleChecked
            put menu_SetChecked(lineNum, menuFragmentText, (not toggleChecked)) into newFragment
            node_SetMenuFragment "SelectMenu", someNode, newFragment
             
            set the select_Groups of scrollGroup to (not toggleChecked)
            break
        case "save as set"
            -- **Bookmark Entry** Save as set
            node_AskSaveSelected scrollGroup
            break
        case "same style"
            if the shiftkey is "Up" then deselect_Nodes
            put the node_Styleinfo of someNode into nodeDisplayStyle
            put flatWorld_StyleNodes(nodeDisplayStyle, scrollGroup) into nodeIndex
            selectNodes nodeIndex, true, scrollGroup
            break
        case "front links"
            if the shiftkey is "Up" then deselect_Nodes
            put flatWorld_FrontLinkNodes(someNode) into nodeIndex
            selectNodes nodeIndex, true, scrollGroup
            break
        case "back links"
            if the shiftkey is "Up" then deselect_Nodes
            put flatWorld_BackLinkNodes(someNode) into nodeIndex
            selectNodes nodeIndex, true, scrollGroup
            break
        case "all links"
            if the shiftkey is "Up" then deselect_Nodes
            put flatWorld_LinkedNodes(someNode, linkArray) into nodeIndex
            selectNodes nodeIndex, true, scrollGroup
            break
        case "nested"
            if the shiftkey is "Up" then deselect_Nodes
            put the node_Children of someNode into nodeIndex
            -- put objectsToNames(nodeIndex)
            selectNodes nodeIndex, true, scrollGroup
            break
        case "screen"
            if the shiftkey is "Up" then deselect_Nodes
            put screenNodes() into nodeIndex
            selectNodes nodeIndex, true, scrollGroup
            break
        case "all"
            put the flatWorld_Nodes of scrollGroup into someNodes
            selectNodes someNodes, true, scrollGroup
            break
        case "on"
            set the select_Groups of scrollGroup to true
            break
        default
            deselect_Nodes
            set the select_Groups of scrollGroup to false
            -- set the selected_Nodes of scrollGroup to empty
    end switch
end flatWorld_SelectNodes

on deselect_Nodes selectedNodes
  put the flatworld_View of the target into scrollGroup
  if selectedNodes is empty then
    put the selected_Nodes of scrollGroup into selectedNodes
    set the selected_Nodes of scrollGroup to empty
  end if
  repeat for each line someNode in selectedNodes
    if exists(someNode) then
      set the selected_State of someNode to false
    end if
  end repeat
end deselect_Nodes

on selectNodes nodeIndex, boolean, scrollGroup
  put the selected_Nodes of scrollGroup into selectedNodes
  repeat for each line someNode in nodeIndex
    object_WithinStackReference someNode
    if boolean is true then
      put line_AddToIndex(someNode, selectedNodes) into selectedNodes
      set the showborder of someNode to true
    else
      put line_DeleteFromIndex(someNode, selectedNodes) into selectedNodes
      set the showborder of someNode to false
    end if
  end repeat
  
  -- select_ObjectIndex selectedNodes
  set the selected_Nodes of scrollGroup to selectedNodes
  return selectedNodes
end selectNodes

on select_ObjectIndex selectedNodes
  if selectedNodes is empty then
    select empty
  else
    put "select" into doSelect
    repeat  for each line someNode in selectedNodes
      put space && someNode && "and" after doSelect
    end repeat
    delete last word of doSelect
    do doSelect
  end if
end select_ObjectIndex

on toggle_SelectGroup someNode
  put the selected_GroupNum of someNode > 0 into oldStatus
  put not oldStatus into newStatus
  set the selected_State of someNode to newStatus
  return newStatus
end toggle_SelectGroup


--> Flat | Graph Functions
-
function graph_Section someNode
    put empty into nodeArray
    put 1 into someLevel
    get branchNodes(someNode, nodeArray, someLevel)
    put keys(nodeArray) into nodeIndex
    return nodeIndex
end graph_Section

function branchNodes someNode, @nodeArray, @someLevel
    if keys(nodeArray) is empty then
        object_WithinStackReference someNode
        put the short name of someNode into testFirst
        put someLevel into nodeArray[someNode]
    end if
    put the front_ArrowLinks of someNode into someArrows
    repeat for each line arrowObject in someArrows
        put the link_Object of arrowObject into childNode
        put the short name of childNode into testChild
        object_WithinStackReference childNode -- overkill?
        -- answer the short name of childNode
         
        if nodeArray[childNode] is empty then
            -- ok so not already visited
            put the back_Links of childNode into childBackLinks
            put newBackLinks(childBackLinks, nodeArray) into foundNewBackLink
            -- answer foundNewBackLink
             
            -- put objectsToNames(childBackLinks)
            if foundNewBackLink is false then
                -- only add if an orphan (ie there are no new backlinks)
                add 1 to someLevel
                put someLevel into nodeArray[childNode]
                 
                put branchNodes(childNode, nodeArray, someLevel) into newIndex
            else
                --
            end if
        end if
    end repeat
end branchNodes

function newBackLinks childBackLinks, nodeArray
    put empty into someLevel
    repeat for each line childBackLink in childBackLinks
        put the short name of childBackLink into testName
        put nodeArray[childBackLink] into someLevel
        if someLevel is empty then
            return true
        end if
    end repeat
    return false
end newBackLinks

function downTreeNodes someNode, @nodeArray, @someLevel
    put the front_ArrowLinks of someNode into someArrows
    repeat for each line arrowObject in someArrows
        put the link_Object of arrowObject into childNode
        if nodeArray[childNode] is empty then
            put someLevel into nodeArray[childNode]
            add 1 to newLevel
            put downTreeNodes(childNode, nodeArray, newLevel) into newIndex
        end if
    end repeat
end downTreeNodes


--> Flat | Scroll
-
on flatWorld_ResetScroll storeName, scrollGroup
  if scrollGroup is empty then put the flatworld_View of the target into scrollGroup
  flatWorld_RecallScroll storeName, someH, someV, scrollGroup
  set the hscroll of scrollGroup to someH
  set the vscroll of scrollGroup to someV
end flatWorld_ResetScroll

on flatWorld_RememberScroll someH, someV, storeName, scrollGroup
  if scrollGroup is empty then put the flatworld_View of the target into scrollGroup
  put someH into scroll_Array["someH"]
  put someV into scroll_Array["someV"]
  model_SetArray storeName, scrollGroup, scroll_Array
end flatWorld_RememberScroll

on flatWorld_RecallScroll storeName, @someH, @someV, scrollGroup
  if scrollGroup is empty then put the flatworld_View of the target into scrollGroup
  put model_GetArray(storeName, scrollGroup) into scroll_Array
  put scroll_Array["someH"] into someH
  put scroll_Array["someV"] into someV
end flatWorld_RecallScroll

on flatWorld_RememberPosition scrollGroup
    put the flatworld_View of the target into scrollGroup
    if scrollGroup is empty then return empty
    
    put the rect of this stack into flatWorldRect
    -- put the loc of this card into rememberLoc
    put the vscroll of scrollGroup into yScroll
    put the hscroll of scrollGroup into xScroll
     
    set the flatWorld_Rect of scrollGroup to flatWorldRect
    set the flatWorld_LastScroll of scrollGroup to xScroll,yScroll
    put the long id of me into stackObject
    save stackObject
end flatWorld_RememberPosition

setprop flatWorld_Scroll scrollLoc
    put the flatworld_View of the target into scrollGroup
    if scrollGroup is empty then return empty
    
    put the flatWorld_Rect of scrollGroup into flatWorldRect
    if scrollLoc is empty or scrollLoc is "last" then
        put the flatWorld_LastScroll of scrollGroup into scrollLoc
    end if
    
    put item 1 of scrollLoc into xScroll
    put item 2 of scrollLoc into yScroll
     
    if flatWorldRect is not empty then set the rect of this stack to flatWorldRect
    if scrollLoc is not empty then
        flatWorld_SetScroll scrollGroup, xScroll, yScroll
    end if
end flatWorld_Scroll

on flatWorld_SetScroll scrollGroup, newX, newY
  lock screen
  set the vscroll of scrollGroup to newY
  set the hscroll of scrollGroup to newX
  unlock screen
end flatWorld_SetScroll

on showScrollbars boolean, scrollGroup,  someNode
    if someNode is empty then put the view_Object of the target into someNode
    if scrollGroup is empty then put the flatworld_View of someNode into scrollGroup 
    
    set the vscrollbar of scrollGroup to boolean
    set the hscrollbar of scrollGroup to boolean
end showScrollbars

on flashScroll someNode, toGroup, stepNum
    -- answer the params
    if stepNum is empty then put 20 into stepNum
    scrollToGroup toGroup
    exit to top
     
    put the loc of someNode into fromPoint
    put the loc of toGroup into toPoint
     
    get loc_TranslationVector(fromPoint, toPoint, xVector, yVector)
     
    put round(xVector/stepNum) into xStep
    put round(yVector/stepNum) into yStep
     
    put 1 into xStep
    put 1 into yStep
     
    put fromPoint into lastLoc
    repeat 3
        -- repeat (stepNum-1)
        -- put translateLoc(lastLoc, xStep, yStep) into newLoc
        put xStep,yStep into newLoc
        set_ScrollCentre newLoc
        -- answer newLoc
        put newLoc into lastLoc
    end repeat
    set_ScrollCentre toPoint
    -- answer toPoint
end flashScroll
-
on borderScroll xScroll, yScroll, scrollGroup
  put the vscroll of scrollGroup into oScroll_Y
  put the hscroll of scrollGroup into oScroll_X
  
  lock screen
  set the hscroll of scrollGroup to (oScroll_X + xScroll)
  set the vscroll of scrollGroup to (oScroll_y + yScroll)
  flatworld_ResetBackground scrollGroup
  unlock screen
end borderScroll

on scrollToGroup groupName
    if groupName is empty then return empty
    put the flatworld_View of the target into scrollGroup
    put object_FromName(groupName, scrollGroup) into someNode
    try
        put the loc of someNode into objectLoc
        set_ScrollCentre objectLoc
        flatworld_ResetBackground scrollGroup
    catch errorNum
        put someNode
        answer errorNum
        edit the script of me
    end try
end scrollToGroup

on set_ScrollCentre objectStartLoc
  put the flatworld_View of the target into scrollGroup
  put the loc of scrollGroup into groupLoc
  loc_TranslationVector objectStartLoc, groupLoc, xVector, yVector
  
  put the vscroll of scrollGroup into start_Y
  put the hscroll of scrollGroup into start_X
  
  put start_X + xVector into newX
  put start_Y + yVector into newY
  
  flatWorld_SetScroll scrollGroup, newX, newY
end set_ScrollCentre

on scrollMore extraLeft, extraTop, scrollGroup,  someNode
    if someNode is empty then put the view_Object of the target into someNode
    if scrollGroup is empty then put the flatworld_View of someNode into scrollGroup
     
    put the vscroll of scrollGroup into o_Vscroll
    put the hscroll of scrollGroup into o_Hscroll
     
    flatWorld_RememberScroll o_Hscroll, o_Vscroll, "Last", scrollGroup
    lock screen
    set the vscroll of scrollGroup to (o_Vscroll + extraTop)
    set the hscroll of scrollGroup to (o_Hscroll + extraLeft)
    unlock screen
end scrollMore

on scrollGroup xVector, yVector, stepNum
    -- answer xVector, yVector
    if stepNum is empty then put 40 into stepNum
    put xVector/stepNum into xStep
    put yVector/stepNum into yStep
     
    put the vscroll of group "Scroll" into start_Y
    put the hscroll of group "Scroll" into start_X
     
    put empty into stepCancelled
    put 1 into whichStep
    send "makeOneStep start_X, start_Y, xStep, yStep, whichStep, stepNum" to me in 1 tick
end scrollGroup

on makeOneStep start_X, start_Y, xStep, yStep, whichStep, stepNum
    -- answer "making step" && whichStep with "Cancel" and "OK"
    -- if it is "Cancel" then exit to top
    if stepCancelled is true then
        -- answer "Cancelled"
        exit to top
    end if
    if whichStep = stepNum then
        -- answer "Finished"
    else
        put round(start_X - (whichStep * xStep)) into newX
        put round(start_Y - (whichStep * yStep)) into newY
         
        lock screen
        set the hscroll of group "Scroll" to newX
        set the vscroll of group "Scroll" to newY
        unlock screen
         
        add 1 to whichStep
        send "makeOneStep start_X, start_Y, xStep, yStep, whichStep, stepNum" to me in tickRate tick
    end if
end makeOneStep


--> Flat | Utitlites
-
on flatworld_ShowObjects objectIndex
    repeat for each line someObject in objectIndex
        show someObject
    end repeat
end flatworld_ShowObjects

function groupArrowCentre someNode
  object_WithinStackReference someNode
  put flatWorld_GetArrowLinks(someNode, linkArray) into arrowObjects
  put line 1 of arrowObjects into firstArrowObject
  if firstArrowObject is empty then
    return the loc of someNode
  else
    put the backLink_Object of firstArrowObject into backLinkObject
    put the link_Object of firstArrowObject into linkObject
    
    if linkObject is someNode then
      return line 2 of the points of firstArrowObject
    else
      return line 1 of the points of firstArrowObject
    end if
  end if
end groupArrowCentre

function nodes_ToNameArray someObjects
    put empty into name_Array
    repeat for each line someObject in someObjects
        put the short name of someObject into objectName
        put someObject into name_Array[objectName]
    end repeat
    return name_Array
end nodes_ToNameArray

function nodes_ToArrow startNode, endNode
  -- could be sped up
  put flatWorld_FrontLinkNodes(startNode) into frontNodes
  
  -- hack
  object_WithinStackReference endNode
  set the wholematches to true
  put lineOffset(endNode, frontNodes) into lineNum
  if lineNum = 0 then
    return empty
  else
    put flatWorld_FrontArrows(startNode, linkArray) into arrowObjects
    return line lineNum of arrowObjects
  end if
end nodes_ToArrow


--> Flat | Wiki Tools
-
function wiki_GetName
  put the short name of this card into flatWorldName
  if word 1 to 2 of flatWorldName is "card id" then
    return empty
  else
    return flatWorldName
  end if
end wiki_GetName

on opn_CreateWikiPage
  put the long id of the target into someNode
  delete word 1 to 4 of someNode
  
  simpl_Send "Create Wiki from Flat Node", someNode
end opn_CreateWikiPage


--> Flat | Display
-

--> Flat | Display | Effects
-
on emphasizeNode someNode, linkType
    put the arrow_Links of someNode into emphasizeLinks
    if linkType is "Front" then
        put the front_ArrowLinks of someNode into emphasizeLinks
    else if linktype is "back" then
        put the back_ArrowLinks of someNode into emphasizeLinks
    else
        put the flatScroll_View of someNode into scrollGroup
        
        put the flatWorld_Arrows of scrollGroup into allLinks
    end if
    lock screen
    emphasizeLinks allLinks, 1, someNode
    -- put the result into array_LinkStyles
    emphasizeLinks emphasizeLinks, 4, someNode
    unlock screen
end emphasizeNode

on emphasizeLinks arrowLinks, newWidth, someNode
    -- answer arrowLinks
    repeat for each line arrowObject in arrowLinks
        if exists(arrowObject) is true then
            put the linesize of arrowObject into array_LinkStyles[arrowObject]
            set the linesize of arrowObject to newWidth
        else
            -- flatWorld_DeleteLink someGroup, toGroup
            delete_LinkReference arrowObject, someNode
        end if
    end repeat
    return array_LinkStyles
end emphasizeLinks

on rollover_ShowHidden someNode
    put the flatScroll_View of someNode into scrollGroup
    
    put the rollover_Hidden of scrollGroup into showObject
    if showObject is not empty then
        frontLinks_Show showObject, false
    end if
     
    frontLinks_Show someNode, true
    set the rollover_Hidden of scrollGroup to someNode
end rollover_ShowHidden

on stobeNodes nodeIndex
    repeat for each line someNode in nodeIndex
        strobeNode someNode
    end repeat
end stobeNodes

on strobeNode someNode
    if someNode is empty then put the long id of the target into someNode
    put the long id of graphic "Simpl Graphic" of someNode into graphicObject
     
    put the backgroundcolor of graphicObject into oColour
    set the backgroundcolor of graphicObject to red
    send "reset_Colour oColour" to graphicObject in 1 seconds
end strobeNode

on reset_Colour oColour
    put the long id of the target into graphicObject
    set the backgroundcolor of graphicObject to oColour
end reset_Colour


--> Flat | Display | Effects | Ball Animations

on button_AddEmail dObject
  put the flatScroll_View of dObject into scrollGroup

  if exists(button "email" of dObject) is false then
    put the short id of dObject into groupID
    put the top_Right of dObject into topR
    
    lock screen
    create button "Email" in group id groupID
    put it into createdButton
    choose browse tool
    
    set the icon of createdButton to 341
    set the opaque of createdButton to false
    set the showname of createdButton to false
    set the showborder of createdButton to false
    set the threed of createdButton to false
    
    set the width of createdButton to the formattedwidth of createdButton
    set the height of createdButton to the formattedheight of createdButton
    set the top_Right of createdButton to topR
    
    unlock screen
    
    put the opn_ScriptStore["email"] of scrollGroup into emailScript
    set the script of createdButton to emailScript
  end if
end button_AddEmail
-
on menu_Ball steps
  put the long id of the target into someNode
  delete word 1 to 4 of someNode
  ball_Animate someNode, steps
end menu_Ball

on node_TextRotate someNode
    if someNode is empty then put the view_Object of the target into someNode
    
    if the node_TextRotated of someNode is true and local_DoubleClicked is false then
        put the the titleText of me into someTitles
        put the titleLine of me into lineNum
        if lineNum is empty then put 1 into lineNum
        add 1 to lineNum
        put line lineNum of someTitles into newTitle
        if newTitle is empty then
            set the titleLine of me to 1
            put line 1 of someTitles into newTitle
             
            set the textsize of me to 18
            set the label of me to "π"
            shrink_Node someNode
        else
            if newTitle is "π" then
                set the textsize of me to 200
            else
                set the textsize of me to 48
            end if
            set the titleLine of me to lineNum
            set the label of me to newTitle
        end if
    else
        -- zoom_Node someNode, true
        -- zoom_Graphic someNode
        -- put "zoom_Graphic" && someNode
    end if
    put false into local_DoubleClicked
end node_TextRotate


--> Deps
-
