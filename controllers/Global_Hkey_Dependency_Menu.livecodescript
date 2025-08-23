script "Global | Hkey | Dependency | Menu"
--> MetaData
-
license: GPLv3
name: Global | Hkey | Dependency | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target
   put scriptEditor_GetHkey() into hKey
   return hKey
end menu_Target


--> Global | Hkey | Dependency | Menu
-
on menu_CollectDepScript hKey
   display_HkeyDepScript hKey
end menu_CollectDepScript

on menu_DisplayHandlerDeps hkey
   display_HandlerDeps hkey
end menu_DisplayHandlerDeps

on menu_DisplayHkeyArray hKey
   display_HandlerHkeyArray hKey
end menu_DisplayHkeyArray

on _
end _

on submenu_Dev
   return menu_DevTitle ("Global | Hkey | Dependency | Menu")
end submenu_Dev


--> Dev | Menu
-
on _FetchHkeyDependencies hKey
   put hkey_FetchDeps (hKey) into allShortDeps
   sort hKeyDeps
   
   display_Outline allShortDeps, hKey, "Global | HkeyArray | Menu", "Global | HkeyArray | Line | Menu", 1, false,  "palette"
end _FetchHkeyDependencies

on _FetchDependencyScript hKey
   local missingHkeys, depScript
   put hkey_FetchDeps (hKey) into depHkeys
   script_FetchFromHkeys depHkeys, depScript, missingHkeys
   put script_ConstructSuite ("Deps", depScript) into depSuite
   
   display_Lines depSuite, "hkey_FetchDeps (shortHKey)"
end _FetchDependencyScript

on _
end _

on _HkeyArrayFromExported hKey
   put hkeyArray_FromExported (hKey) into hkeyArray
   display_Array hkeyArray
end _HkeyArrayFromExported

on _CreateDependencyGraphFromExported hKey, fetchHow
   put hkeyArray_FromExported (hKey) into hKeyArray
   hkeyArray_DrawGraph hKeyArray, "hierarchical"
end _CreateDependencyGraphFromExported

on _CreateWithoutObjectClusters hKey
   breakpoint
   deps_CreateMainStackOverlay scriptObject, "hierarchical", "display", true, "none"
   put hkey_DependencyArrayFromObjects (hKey, "Menu Only", true) into hKeyArray
end _CreateWithoutObjectClusters

on _
end _

on _DepsFromExportedLinks hKey
   put hkey_FetchDeps (hKey) into allShortDeps
   sort allShortDeps
   display_Outline allShortDeps, hKey, "Global | HkeyArray | Menu", "Global | HkeyArray | Line | Menu", 1, false,  "palette"
end _DepsFromExportedLinks

on _DependencyScriptFromArray hKey, overlayName
   set the cursor to watch
   
   put library_HandlerFile (hKey) into hkeyFolder
   put overlay_GetLinkArray (hkeyFolder, overlayName) into hkeyArray
   
   put the strip_HkeyComponents of me is true into stripComponents
   put the strip_HkeyProps of me into stripProps
   -- put the include_HandlersFrom of me into includeHandlersFrom
   put item 3 of hKey into scriptObject
   put empty into pStripObjects
   
   display_HkeyArrayDependencyScript hkeyArray, scriptObject, pStripObjects, stripProps, false
   put the result into someArray
   
   put someArray ["uniqueHkeys"] into uniqueHkeys
   put someArray ["missingHkeys"] into missingHkeys
   put someArray ["duplicateHkeyArray"] into duplicateHkeyArray
   
   display_Outline uniqueHkeys, "uniqueHkeys"
   if missingHkeys is not empty then display_Outline missingHkeys, "missingHkeys"
   if duplicateHkeyArray is not empty then display_Array duplicateHkeyArray, "duplicateHkeyArray"
end _DependencyScriptFromArray

on _
end _

on _FetchHkeyLinkArray hKey, oldFetchHow
   put hkey_FetchLinkArray (hKey, fetchHow) into hKeyArray
   display_HandlerHkeyArray hkey, hKeyArray
end _FetchHkeyLinkArray

on _DepsFromStoredHkeyLinkArray hKey
   put deps_FetchFromStored (hKey) into hKeyDeps
   display_Outline hKeyDeps
end _DepsFromStoredHkeyLinkArray

on _DepsFromObjectsScriptLinkArray hKey
   put hkey_FetchDeps (hKey, "stored script_LinkArray") into hKeyDeps
   display_Outline hKeyDeps
end _DepsFromObjectsScriptLinkArray

on _AllDepsFromObjects hKey
   /*
   Fetch the handlers directly from the objects
   Extract the calls and store the handler and calls.
   Recurse
   */ 
   local pSetName, pTestExceptions
   
   timer_Start "library_HkeyFolder"
   --
   put library_HkeyFolder (hKey, pSetName, pTestExceptions) into hKeyArray
   --
   timer_Stop "library_HkeyFolder", true
   
   display_HandlerHkeyArray hkey, hKeyArray
end _AllDepsFromObjects
