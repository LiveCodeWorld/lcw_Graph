script "behavior_ViewGraph"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewGraph
type: behavior
version: 0.1


--> Graph
-
getprop link_Array
   put the graph_Nodes of me into gNodes
   repeat for each line gNode in gNodes
      put the short id of gNode into gID
      put the to_Nodes of gNode into toNodes
      repeat for each line toNode in toNodes
         put the short id of toNode into toID
         -- put the short name of toNode into linkArray [gID][toID]["label"]
         put empty into linkArray [gID][toID]
      end repeat
      --
      put the from_Nodes of gNode into fromNodes
      repeat for each line fromNode in fromNodes
         put the short id of fromNode into fromID
         -- put the short name of fromNode into linkArray [fromID][gID]["label"]
         put empty into linkArray [fromID][gID]
      end repeat
   end repeat
   return linkArray
end link_Array

getprop graph_DotArray
   ## Objects
   local objectData
   put the graph_Nodes of me into gNodes
   repeat for each line gNode in gNodes
      put the dot_ObjectArray of gNode into oArray
      indexArray_AddToEnd objectData, oArray
   end repeat
   put objectData into dotArray ["objects"]
   
   ## Edges
   local arrowData
   put the graph_Arrows of me into graphArrows
   repeat for each line gArrow in graphArrows
      put the dot_EdgeArray of gArrow into edgeArray
      indexArray_AddToEnd arrowData, edgeArray
   end repeat
   put arrowData into dotArray ["edges"]
   
   ## Graph Props
   put the short name of me into graphName
   dot_NormalizeName graphName
   put graphName into dotArray ["name"]
   --
   put true into dotArray ["splines"]
   put false into dotArray ["concentrate"]
   put true into dotArray ["directed"]
   put false into dotArray ["strict"]
   put false into dotArray ["overlap"]
   --
   return dotArray
end graph_DotArray

getprop dot_DefSection
   -- put dot_ConstructDefaultNodeDefs (nodeShape, nodeStyle, nodeColour, nodeFillColour) into defaultNodeDefs
   -- put colour_FetchNameArray() into cNameArray
   put the graph_Nodes of me into gNodes
   repeat for each line gNode in gNodes
      put the node_DefLine of gNode into defLine
      put defLine & CR after defSection
   end repeat
   delete char -1 of defSection
   return defSection
end dot_DefSection

getprop node_DefLine
   local polyParams, nodeUrl, nodeStyle, nodeColour
   put the long id of the target into gObject
   --
   put the short id of gObject into nodeID
   --
   put "filled" into nodeStyle
   put empty into nodeStyle
   --
   put the short name of gObject into nodeLabel
   -- put the label of gObject into nodeLabel
   put the toolTip of gObject into nodeToolTip
   --
   put the dot_Colour of gObject into nodeFillColour
   put the dot_Shape of gObject into nodeShape
   --
   put dot_ConstructNodeDef (nodeID, nodeLabel, nodeShape, nodeFillColour, nodeUrl, nodeToolTip, nodeStyle) into defLine
   put dot_NodeObjectArray (propArray, nodeUrl) into objectArray
   return objectArray
end node_DefLine

getprop dot_EdgeArray
   put the short id of the target into edgeArray ["_gvid"]
   put the arrow_Data of the target into arrowData
   --
   put arrowData ["from_Object"] into fromObject
   put the short id of fromObject into fromID
   put fromID into edgeArray ["tail"]
   --
   put arrowData ["to_Object"] into toObject
   put the short id of toObject into toID
   put toID into edgeArray ["head"]
   --
   return edgeArray
end dot_EdgeArray

getprop dot_ObjectArray
   put the properties of the target into propArray
   put the node_Url of the target into nodeUrl
   --
   put dot_NodeObjectArray (propArray, nodeUrl) into objectArray
   return objectArray
end dot_ObjectArray

getprop dot_Shape
   put the graph_Node of the target into gNode
   if exists (gNode) is false then return empty
   
   put the style of gNode into gStyle
   return dot_ShapeFromStyle (graphicStyle)
end dot_Shape

getprop dot_Colour
   put the effective backgroundcolor of the target into sColour
   return dot_GetColour (sColour)
end dot_Colour


--> Events
-
on mouseDoubleUp
   put the graph_Node of the target into gView
   if exists (gView) is false then pass mouseDoubleUp
   
   if the shiftKey is "Down" then
      display_ObjectProperties gView
   else
      put the short name of gView into sName
      put lcw_Ask ("Edit the name of this node..", sName) into sName
      set the name of gView to sName
   end if
end mouseDoubleUp


--> Objects
-
getprop graph_Arrows
   -- put the top_Named ["_Temporary Arrow"] of me into gArrows
   put the top_Views ["arrow_View"] of me into gArrows
   return gArrows
end graph_Arrows

getprop graph_Nodes
   -- put the top_ViewNames ["View|Node|Graphic"] of me into linkNames
   put the top_ViewObjects ["View|Node|Graphic"] of me into gNodes
   return gNodes
end graph_Nodes

getprop graph_View
   return the long id of me
end graph_View

getprop view_Object
   return the long id of me
end view_Object
