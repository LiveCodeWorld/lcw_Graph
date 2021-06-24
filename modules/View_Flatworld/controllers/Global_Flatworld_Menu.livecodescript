script "Global | Flatworld | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Flatworld | Menu
type: controller
version: 0.1

/*
This menu comes from the original card script of the "View|Graph|Flatworld" view.

on insert_Menu
   return "Global | Graph | Flatworld | Menu"
end insert_Menu


--> Global | Graph | Flatworld | Menu
-
*/


--> Variables
-
local LocalArray
local NameArray


--> Menu | Props
-
on menu_Init tObject
   -- called only once for top menu
   pass menu_Init
end menu_Init

getprop menu_Target [tObject]
   -- called once for each menu
   return the display_View of tObject
end menu_Target

private function _NodeRefs mTarget
   -- node_Refs [mTarget]
   put empty into NameArray
   -- put menu_GetTarget() into mTarget
   put the flatWorld_TopNodes of mTarget into flatworldNodes
   put object_ConstructNameArray (flatworldNodes, NameArray) into nodeNames
   
   put "everything,arrows,balls,selected nodes" into submenu
   if nodeNames is not empty then put ",-," & nodeNames after submenu
   return submenu
end _NodeRefs

function object_ConstructNameArray objectIndex, @nameArray
   repeat for each line someObject in objectIndex
      put the name of someObject into someName
      put the long id of someObject into someObject
      if nameArray [someName] is empty then
         put someObject into nameArray [someName]
      else
         put someName && "(" & the short id of someObject & ")" into uniqueName 
         put someObject into nameArray [uniqueName]
      end if
   end repeat
   return keys(nameArray)
end object_ConstructNameArray

getprop nodes_Params [mTarget]
   return _NodeRefs (mTarget)
end nodes_Params

getprop delete_Params [mTarget]
   return _NodeRefs (mTarget)
end delete_Params

getprop drawGraph_Params [mTarget]
   -- graph_Styles
   get "radial,spring,hierarchical,-,clusters" 
   replace comma with CR in it
   return it
end drawGraph_Params

getprop nodePinned_Params [mTarget]
   return "true,false"
end nodePinned_Params

getprop insertNode_Params [mTarget]
   -- nodeType
end insertNode_Params

getprop insertView_Params [mTarget]
   -- viewSubPath
   return "All"
end insertView_Params

getprop show_Params [mTarget]
   -- showWhat
   return "All"
end show_Params

getprop frame_Params [mTarget]
   -- showWhat
   return "Show name,Hide name,Show border,Hide border"
end frame_Params


--> Global | Flatworld | Menu
-
on menu_DrawGraph mTarget, graphStyle
   put the flatworld_View of mTarget into flatworldView
   put the flatworld_Nodes [true] of mTarget into flatworldNodes
   
   repeat for each line someNode in flatworldNodes
      put the short id of someNode into nodeID
      
      put nodeID into nodeName
      put the view_Label of someNode into nodeLabel
      
      put the height of someNode into someHeight
      put the width of someNode into someWidth
      put empty into fixedSize
      put empty into nodeUrl
      put empty into nodeToolTip
      
      switch the node_Style of someNode
         case "player"
            put the node_ShapeFile of someNode into nodeShapeFile
            put dot_ConstructShapeFileDef(nodeShapeFile, someWidth, someHeight, fixedSize, nodeUrl, nodeToolTip)
            break
         case "image"
            put the node_ShapeFile of someNode into nodeShapeFile
            put dot_ConstructShapeFileDef(nodeShapeFile, someWidth, someHeight, fixedSize, nodeUrl, nodeToolTip)
            break
         case "graphic"
            put nodeID into nodeName
            put the view_Label of someNode into nodeLabel
            
            put the view_Shape of someNode into nodeShape
            put the view_BorderColour of someNode into nodeColour
            put the view_FillColour of someNode into nodeFillColour
            put the node_FillStyle of someNode into fillStyle
            
            put the view_Url of someNode into nodeUrl
            put the view_ToolTip of someNode into nodeToolTip
            
            put empty into nodeLine
            dot_AddParamToNodeDef "label", nodeLabel, nodeLine, true
            dot_AddParamToNodeDef "shape", nodeShape, nodeLine, false
            
            dot_AddParamToNodeDef "style", fillStyle, nodeLine, false
            dot_AddParamToNodeDef "color", nodeColour, nodeLine, false
            dot_AddParamToNodeDef "fillcolor", nodeFillColour, nodeLine, true
            
            dot_AddParamToNodeDef "URL", nodeUrl, nodeLine
            dot_AddParamToNodeDef "tooltip", nodeToolTip, nodeLine
            
            put the height of someNode into someHeight
            put the width of someNode into someWidth
            if someWidth is not empty then
               dot_ConvertToInches someWidth
               dot_AddParamToNodeDef "width", someWidth, nodeLine
            end if
            if someHeight is not empty then
               dot_ConvertToInches someHeight
               dot_AddParamToNodeDef "height", someHeight, nodeLine
            end if
            dot_AddParamToNodeDef "fixedsize", true, nodeLine, false
            
            put the node_Position of someNode into nodePosition
            dot_AddParamToNodeDef "pos", nodePosition, nodeLine, true
            dot_AddParamToNodeDef "pin", true, nodeLine, false
            
            -- dot_NormalizeNode someNode
            put nodeName && "[" & nodeLine & "];" into nodeDef
            break
         default
      end switch
      
      put nodeDef & CR after nodeDefs
      
      put the node_FrontLinks of someNode into nodeFrontLinks
      repeat for each line nodeFrontLink in nodeFrontLinks
         put the short id of nodeFrontLink into frontLinkName
         put nodeName && "->" && frontLinkName & ";" into linkLine
         -- line_Insert linkLine, nodeLinkSection
         put linkLine & CR after nodeLinkSection
      end repeat
      -- put CR after nodeLinkSection
   end repeat
   delete char -1 of nodeDefs
   delete char -1 of nodeLinkSection
   
   -- put nodeDefs & CR & CR & nodeLinkSection into nodeSection
   put empty into nodeSection
   text_AddParagraph nodeDefs, nodeSection, 2
   text_AddParagraph nodeLinkSection, nodeSection, 2
   
   put "FlatWorld" into graphName
   put dot_Construct (graphName, nodeSection) into dotText
   
   put 0,0 into bbRect
   put the width of flatworldView into item 3 of bbRect
   put the height of flatworldView into item 4 of bbRect
   dot_AddGraphHeaderLine dotText, "bb", bbRect, true
   
   put the graph_Margins of flatworldView into someMargins
   put item 1 of someMargins into leftM
   put item 2 of someMargins into topM
   
   -- dot_AddGraphMargin dotText, 1, 2, true
   dot_AddGraphMargin dotText, leftM, topM
   -- dot_AddGraphPadding dotText, "400,100"
   
   if the shiftkey is "Down" then
      put view_GetTemplateObject ("View|Image|OPN Image") into imageView
      put dotText
   else
      put the flatworld_background of flatworldView into imageView
   end if
   set the image_File of imageView to empty
   set the dot_Text of imageView to dotText
end menu_DrawGraph

on _
end _

on menu_TestGroupRect mTarget
   put the flatworld_View of mTarget into flatworldView
   
   put the flatworld_Nodes of mTarget into objectIndex
   put rect_GetGroupBoundary(objectIndex) into someRect
   rect_CreateTestButton someRect
   
   put item 1 of someRect - the left of flatworldView into leftM
   put item 2 of someRect - the top of flatworldView into topM
   
   put the right of flatworldView - item 3 of someRect into rightM
   put the bottom of flatworldView - item 4 of someRect into bottomM
   
   put leftM,topM,rightM,bottomM into someMarigns
   set the graph_Margins of flatworldView to someMarigns
end menu_TestGroupRect

on menu_DisplayDotText mTarget
   put the flatworld_Background of mTarget into imageView
   
   put the dot_Text [graphStyle] of imageView -- into dotText
end menu_DisplayDotText

on menu_NodePinned mTarget, someBoolean
   set the node_Pinned of the flatworld_View of mTarget to someBoolean
end menu_NodePinned

on menu_ClearGraph mTarget
   put the flatworld_Background of mTarget into imageView
   set the image_File of imageView to empty
end menu_ClearGraph

on _
end _

on menu_InsertNode mTarget, nodeType
   put lcw_Ask ("What would you like to call this new node?", "New") into nodeName
   
   put the flatworld_View of mTarget into flatWorldView
   switch nodeType
      case "Simple Node"
         set the flatworld_NewNode of flatWorldView to nodeName
         break
      case "-"
      case "Image Node"
         set the flatworld_InsertView [nodeName] of flatWorldView to "View|Image|Opn Image"
         break
      case "Video Node"
         set the flatworld_InsertView [nodeName] of flatWorldView to "View|Movie|Player"
         break
      case "Tree Node"
         set the flatworld_InsertView [nodeName] of flatWorldView to "View|Tree|Simple Tree"
         break
      case "Text Node"
         set the flatworld_InsertView [nodeName] of flatWorldView to "View|Field|HyperText"
         break
      case "Keyword Node"
         set the flatworld_InsertView [nodeName] of flatWorldView to "View|Tags|Basic"
         break
      case "Form Node"
         set the flatworld_InsertView [nodeName] of flatWorldView to "View|Form|OPN Form"
         break
      case "Web Node"
         set the flatworld_InsertView [nodeName] of flatWorldView to "View|Browser|Simple"
         break
   end switch
end menu_InsertNode

on _
end _

on menu_Show mTarget, showWhat
   switch showWhat
      case "All"
         put the flatworld_Nodes [true] of mTarget into someObjects
         object_ShowAll someObjects, true
         put the flatworld_Arrows of mTarget into someObjects
         object_ShowAll someObjects, true
         break
   end switch
end menu_Show

on menu_Nodes mTarget, nodeRef
   put NameArray [nodeRef] into someNode
end menu_Nodes

on menu_Delete mTarget, nodeRef
   put the flatworld_View of mTarget into flatworldView
   switch nodeRef
      case "everything"
         opn_Answer "Are you sure you want to delete all nodes and start again?"
         
         put the flatWorld_Objects of flatworldView into deadObjects
         object_Delete deadObjects, true
         
         set the selected_Nodes of flatworldView to empty
         model_SetArray "group_Styles", flatworldView, empty
         break
      case "arrows"
         put the flatworld_Arrows of flatworldView into deadObjects
         object_Delete deadObjects, true
         break
      case "-"
      case "balls"
         menu_DeleteBalls
         break
      case "selected nodes"
         opn_Answer "Are you sure you want to delete the currently selected nodes?"
         put the selected_Nodes of flatworldView into someNodes
         
         lock screen
         repeat for each line someNode in someNodes
            set the cursor to busy
            -- set the delete_Node of someNode to false
            deleteNode someNode
         end repeat
         unlock screen
         model_SetArray "group_Styles", flatworldView, empty
      default
         put NameArray [nodeRef] into someNode
         lock screen
         delete someNode
   end switch
end menu_Delete

on _
end _

on menu_ToggleScrollBars someNode
   if someNode is empty then put the view_Object of the target into someNode
   put the flatworld_View of someNode into flatworldView
   
   put not the vscrollbar of flatworldView into boolean
   showScrollbars boolean, flatworldView
end menu_ToggleScrollBars

on menu_Frame mTarget, showWhat
   put the long id of the target into someNode
   if word 1 of someNode is not "group" then delete word 1 to 4 of someNode
   switch showWhat
      case "Show name"
         set the showname of someNode to true
         break
      case "Hide name"
         set the showname of someNode to false
         break
      case "Show border"
         set the showborder of someNode to true
         break
      case "Hide border"
         set the showborder of someNode to false
         break
   end switch
end menu_Frame

on _
end _

on menu_InsertView mTarget, viewSubPath
   put the flatworld_View of mTarget into flatWorldView
   
   ask "What would you like to call this new node?" with "New"
   put it into nodeLabel
   if nodeLabel is empty then exit to top
   
   set the flatworld_InsertView of flatWorldView to viewSubPath
   put the result into someNode
   set the node_Name of someNode to nodeLabel
end menu_InsertView

on menu_EditMenuScript
   edit the script of me
end menu_EditMenuScript

on menu_EditFlatworldScript mTarget
   edit the script of the flatworld_View of mTarget
end menu_EditFlatworldScript

