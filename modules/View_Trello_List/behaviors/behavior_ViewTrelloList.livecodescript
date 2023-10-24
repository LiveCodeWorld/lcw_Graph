script "behavior_ViewTrelloList"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewTrelloList
type: behavior
version: 0.1

on preOpenControl
   put the long id of button id 1005 of stack "revDataGridLibrary" into gridBehavior
   set the behavior of stack "behavior_ViewTrelloList" to gridBehavior
   pass preOpenControl
end preOpenControl

getprop display_View
   return the long id of me
end display_View
   

