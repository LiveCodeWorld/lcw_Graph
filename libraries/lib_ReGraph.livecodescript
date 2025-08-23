script "lib_ReGraph"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_ReGraph
type: library
version: 0.1


--> Working on
-


--> ReGraph
-
command reDisplayGraph_HkeyArray hkeyArray, sObject, pGraphStyle
   -- component: true
   set the cursor to watch
   --
   graph_CreateFromScriptHkeyArray hkeyArray, sObject, pGraphStyle
   put the result into svgFile
   --
   put the name of sObject into sLabel
   _DisplaySvg svgFile, sLabel, sObject, hkeyArray, pGraphStyle 
   put the result into svgView
   return svgView
end reDisplayGraph_HkeyArray

command reDisplayGraph_LinkArray hkeyArray, pDataFolder, pHkeyLabel, pGraphStyle, pProcessObject
   -- component: true
   set the cursor to watch
   --
   put empty into sObject -- might be useful to store top object or hKey?
   graph_CreateFromHkeyArray hkeyArray, pDataFolder, pGraphStyle, pProcessObject
   put the result into svgFile
   --
   _DisplaySvg svgFile, pHkeyLabel, sObject, hkeyArray, pGraphStyle 
   put the result into svgView
   return svgView
end reDisplayGraph_LinkArray


--> Private
-
private command _DisplaySvg svgFile, sLabel, sObject, hkeyArray, pGraphStyle 
   display_SVG svgFile, sLabel
   put the result into svgView
   --
   set the displayed_Object of svgView to sObject
   set the displayed_HkeyArray of svgView to hkeyArray
   set the displayed_GraphStyle of svgView to pGraphStyle
   --
   return svgView
end _DisplaySvg


--> Deps
-
