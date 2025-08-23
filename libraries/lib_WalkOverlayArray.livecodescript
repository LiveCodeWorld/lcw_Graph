script "lib_WalkOverlayArray"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_WalkOverlayArray
type: library
version: 0.1

/*
Here we look at the recursive wal used to constuct clustered graphs.

This is ancient code.
Hit a recuresion bug.
*/


--> Working on
-


--> Walk | OverlayArray
-
function overlayArray_DotNestedObjectClusters hIdArray, hLinkArray, graphNodeType
   -- put linkarray_FilterIdArray (hIdArray, hLinkArray) into hIdArray
   put hKeyArray_ConstructObjectIdArray (hIdArray) into linkObjectIdArray
   put keys(linkObjectIdArray) into linkObjects
   sort linkObjects
   put object_OutlineFromIndex (linkObjects) into objectOutline
   --
   put outline_ToXmlStructure (objectOutline)into structureXml
   put hKeyArray_XmlToClusters (structureXml, objectOutline, hIdArray, graphNodeType) into clusterDefs
   return clusterDefs
end overlayArray_DotNestedObjectClusters


--> Outline | XML
-
/*
See also OPML section in libOPN_Data
*/

function outline_ToXmlStructure tabbedOutline
   put outline_Simplify (tabbedOutline, idArray, keyArray) into simpleOutline
   put outline_ToXML (simpleOutline) into someXml
   put xml_Nodes (someXml) into allNodes
   
   put revCreateXMLTree (someXml, true, true, false) into treeID
   set the itemdelimiter to "/"
   repeat for each line someNode in allNodes
      revAddXMLNode treeID, someNode, "contents", "", "before"
      put the result into createdNode
      
      set the itemdelimiter to "/"
      put item -1 of someNode into attributeValue
      revSetXMLAttribute treeID, createdNode, "nodeID", attributeValue
   end repeat
   put revXMLText (treeID, "", true) into someXml
   revXMLDeleteTree treeID
   xml_TidySpace someXML
   return someXml
end outline_ToXmlStructure

function outline_ToXML tabbedOutline, propertyArray
   -- local lineNumber
   -- outline_RecurseToXML someOutline, someXml, 0, lineNumber, "Test XML"
   
   outline_ToXMLRecurse tabbedOutline, propertyArray
   put the result into treeID
   put revXMLText (treeID, "", true) into someXml
   revXMLDeleteTree treeID
   return someXml
end outline_ToXML

function outline_Simplify tabbedOutline, @idArray, @keyArray, pKeyStyle
   repeat for each line someLine in tabbedOutline
      put word 1 to -1 of someLine into someText
      put linkarray_RenameKeys(someText, idArray, keyArray, pKeyStyle) into nodeID
      put nodeID into word 1 to -1 of someLine
      put someLine & CR after simpleOutline
   end repeat
   delete char -1 of simpleOutline
   return simpleOutline
end outline_Simplify

function hKeyArray_XmlToClusters someXml, objectOutline, hIdArray, graphNodeType
   put word 1 to -1 of someXml into someXml
   delete line 1 to 3 of someXml
   delete line -1 of someXml
   put outline_DecreaseIndent(someXml, 1) into someXml
   
   put object_IndexFromOutline(objectOutline) into linkObjects
   repeat with objectNum = 1 to the number of lines of linkObjects
      put line objectNum of linkObjects into linkObject
      put "n" & objectNum into linkONodeID
      
      put hKeyArray_ReplaceOpeningTag(objectNum, someXml) into someXml
      
      put "subgraph cluster" & objectNum && "{}" into emptyDef
      put "<" & linkONodeID & "[ ]*/>" into someReg
      put replacetext (someXml, someReg, emptyDef) into someXml
      
      put "<contents nodeID=" & kwote (linkONodeID) & "></contents>" into subContentsTag
      put outline_LineOffset (subContentsTag, someXml) into lineNum
      if lineNum = 0 then next repeat
      
      put line lineNum of someXml into someLine
      put outline_TabLevel (someLine) into indentLevel
      
      put hKeyArray_SubGraphContents (linkONodeID, indentLevel, linkObject, hIdArray, graphNodeType) into subSection
      -- replace subContentsTag with subSection in someXml
      put subSection into line lineNum of someXml
   end repeat
   
   -- put CR & "}" & CR into closingDef
   put "}" into closingDef
   put replacetext (someXml, "</n.+>", closingDef)  into someXml
   return someXml
end hKeyArray_XmlToClusters


--> Deps | HkeyArray
-
function hKeyArray_SubGraphContents linkONodeID, indentLevel, linkObject, hIdArray, graphNodeType
   -- but this is hKeys and not nodeIDs ??? 
   -- put linkArray_HkeysInObject(linkObject, hIdArray) into nodeSection
   
   -- should depend on the dot_NodeType
   put hKeyArray_NodeIdsInObject (linkObject, hIdArray) into nodeSection
   replace CR with "; " in nodeSection
   
   if exists(linkObject) then
      put the name of linkObject into subGraphLabel
   else
      put linkObject into subGraphLabel
   end if
   
   if subGraphLabel = "Missing" then
      put "orange" into fillColour
      put "red" into someColour
   else
      put "grey60" into someColour
      if math_IsOdd (indentLevel) is true then
         put "grey60" into fillColour
      else
         put "grey90" into fillColour
      end if
   end if
   
   put empty into someRank
   get dot_SubGraphContents (subGraphLabel, nodeSection, someRank, "filled", someColour, fillColour)
   
   line_Indent it
   put it into subGraphContents
   return subGraphContents
end hKeyArray_SubGraphContents

function hKeyArray_ReplaceOpeningTag tagNumber, someXml
   put "subgraph cluster" & tagNumber && "{" into subHeader
   -- put CR after subHeader
   put "<n" & tagNumber & ">" into openingTag
   put replacetext(someXml, openingTag, subHeader) into someXml
   return someXml
end hKeyArray_ReplaceOpeningTag


--> Deps
-
function math_IsOdd someNumber
   -- was "isOdd"
   return someNumber mod 2 = 1
end math_IsOdd

function outline_LineOffset osTitle, someOutline
   -- was "whichOsLine"
   replace tab with empty in someOutline
   replace tab with empty in osTitle
   set the wholematches to true
   put lineoffset (osTitle, someOutline) into lineNum
   return lineNum
end outline_LineOffset


--> Private
-
private command line_Indent @sLines, pTabChars
   if pTabChars is empty then put tab into pTabChars
   --
   repeat with lineNum = 1 to the number of lines of sLines
      put pTabChars before line lineNum of sLines
   end repeat
end line_Indent

private function linkarray_RenameKeys someKeyArray, @idArray, @keyArray, pKeyStyle
   -- modified to use nested someKeyArray instead of just an index of keys
   -- a general technique for building incremental unique ids and their translations (as in a database id)
   -- for a single key this returns the (new) or existing simlified translation
   -- while building the two way arrays
   -- will also add multiple keys if needed (as with childNodes)
   
   if someKeyArray is an array then -- quick hack
      put keys (someKeyArray) into someKeys
   else
      put someKeyArray into someKeys
   end if
   
   repeat for each line someKey in someKeys
      put keyArray [someKey] into simpleID
      if simpleID is empty then
         -- not already indexed (work out new incremental ID and add to idArray and keyArray)
         put the number of lines of keys(idArray) + 1 into keyNumber
         switch pKeyStyle
            case "hName"
               hkey_Deconstruct someKey, hName, hType, hObject, hNum
               put hName into simpleID
               break
            case "short hkey"
               hkey_Deconstruct someKey, hName, hType, hObject, hNum
               put quote & hType && hName & quote into simpleID
               break
            case "number"
               put keyNumber into simpleID
               break
            default
               put "n" & keyNumber into simpleID
         end switch
         put simpleID into keyArray [someKey]
         put someKey into idArray [simpleID]
      end if
      put simpleID & CR after simpleIDs
   end repeat
   delete char -1 of simpleIDs
   return simpleIDs
end linkarray_RenameKeys

private command outline_ToXMLRecurse tabbedOutline, propertyArray, treeNode, treeID
   put propertyArray [treeNode] into nodeContents
   
   put "tree" into rootNode
   if treeNode is empty then
      -- can do a header here?
      xml_CreateTree rootNode, treeID
   else
      put rootNode & "/" & treeNode into someNode
      
      set the itemdelimiter to "/"
      put item -1 of someNode into nodeName
      put item 1 to -2 of someNode into parentPath
      
      put propertyArray [someNode] into nodeContents
      revAddXMLNode treeID, parentPath, nodeName, nodeContents
      put the result into createdNode
   end if
   
   put outline_PathChildren(treeNode, tabbedOutline) into childNodes
   repeat for each line childNode in childNodes
      outline_ToXMLRecurse tabbedOutline, propertyArray, childNode, treeID
   end repeat
   return treeID
end outline_ToXMLRecurse
