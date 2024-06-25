script "Global | HkeyArray | Tree | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | HkeyArray | Tree | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into dView
   put the displayed_Object of dView into sObject
   put the displayed_HkeyArray of dView into hkeyArray
   --
   put hkeyArray into LocalArray ["hkeyArray"]
   put dView into LocalArray ["dView"]
   --
   return dView
end menu_Target

private command _DisplayMissing mTitle, mArray, dView
   put keys (mArray) into mKeys
   sort mKeys
   set the displayed_Data [mTitle] of dView to mKeys
   return mKeys
end _DisplayMissing

function hkey_ConstructMissingData hKeys, sObject, searchObjects, pDisplayView
   put hkey_ListShort (hKeys) into allShortHkeys
   --
   repeat with lineNum = 1 to the number of lines of hKeys
      if the commandKey is "down" then breakpoint
      if the shiftKey is "down" then exit repeat
      --
      put line lineNum of hKeys into hKey
      --
      if exists (pDisplayView) then
         set the hilited_Element of pDisplayView to hKey
      end if
      
      # List handler calls = allHandlerKeys
      put walk_GetHkeyArray (hKey, searchObjects) into handlerHkeyArray
      put array_ListKeys (handlerHkeyArray) into allHandlerKeys
      
      repeat for each line handlerHkey in allHandlerKeys
         put word 1 to 2 of handlerHkey into shortHandlerKey
         --
         switch
            case handlerHkey is among the lines of hKeys
               put empty into foundArray [handlerHkey]
               break
            case word -1 of handlerHkey = "Missing"
               put empty into missingArray [handlerHkey]
               break
            case shortHandlerKey is among the lines of allShortHkeys
               put empty into inShortArray [handlerHkey]
               break
            default
               put empty into foundButOutsideArray [handlerHkey]
         end switch
      end repeat
   end repeat
   --
   put foundArray into missingData ["foundArray"]
   put missingArray into missingData ["missingArray"]
   put inShortArray into missingData ["inShortArray"]
   put foundButOutsideArray into missingData ["foundButOutsideArray"]
   --
   return missingData
end hkey_ConstructMissingData


--> Global | HkeyArray | Tree | Menu
-
on menu_TestDeps dView
   menu_DisplayHkeyIndex dView
   put the result into hKeys
   put the displayed_Index of dView into hKeys
   --
   put the displayed_Object of dView into sObject
   put the walk_Hierarchy of sObject into searchObjects
   --
   put hkey_ConstructMissingData (hKeys, sObject, searchObjects, dView) into missingData
   --
   put missingData ["foundArray"] into foundArray -- fine
   put missingData ["inShortArray"] into inShortArray -- should be fine
   --
   put missingData ["foundButOutsideArray"] into foundButOutsideArray -- add dependency to index
   put missingData ["missingArray"] into missingArray -- bad
   
   # Store arrays
   set the missing_FoundArray of dView to foundArray -- fine
   set the missing_InShortArray of dView to inShortArray -- should be fine
   --
   set the missing_FoundButOutsideArray of dView to foundButOutsideArray -- add dependency to index
   set the missing_Array of dView to missingArray -- bad
   
   if keys (missingArray) is empty then
      # Display Missing but Found
      _DisplayMissing "Found but Outside", foundButOutsideArray, dView
   else
      _DisplayMissing "Missing", missingArray, dView
   end if
   
   if keys (foundButOutsideArray) is not empty then
      # Collect and display script
      put the name of sObject into sTitle
      put array_ListKeys (foundButOutsideArray) into foundButOutsideKeys
      put hkey_CollectFromObjects (foundButOutsideKeys, true) into newDepScript
      display_Text newDepScript, sTitle, "Found but Outside Script"
   end if
end menu_TestDeps


private on __
end __

on menu_MissingFoundKeys dView
   put the missing_FoundArray of dView into foundArray -- fine
   --
   _DisplayMissing "Already in Index", foundArray, dView
end menu_MissingFoundKeys

getprop checked_MissingFoundKeys [dView]
   put the missing_FoundArray of dView into foundArray -- fine
   return the keys of foundArray is not empty
end checked_MissingFoundKeys

on menu_FoundButOutside dView
   put the missing_FoundButOutsideArray of dView into foundButOutsideArray -- add dependency to index
   --
   _DisplayMissing "Found but Outside", missingPlaceArray, dView
end menu_FoundButOutside

getprop checked_FoundButOutside [dView]
   put the missing_FoundButOutsideArray of dView into foundButOutsideArray -- add dependency to index
   return the keys of foundButOutsideArray is not empty
end checked_FoundButOutside

on menu_InShortHkeys dView
   put the missing_InShortArray of dView into inShortArray -- should be fine
   --
   _DisplayMissing "In short hKeys", inShortArray, dView
end menu_InShortHkeys

getprop checked_InShortHkeys [dView]
   put the missing_InShortArray of dView into inShortArray -- should be fine
   return the keys of inShortArray is not empty
end checked_InShortHkeys

on menu_MissingKeys dView
   put the missing_Array of dView into missingArray -- bad
   --
   _DisplayMissing "Missing Hkeys", missingArray, dView
end menu_MissingKeys

getprop checked_MissingKeys [dView]
   get the missing_Array of dView
   return keys (it) is not empty
end checked_MissingKeys

private on ___
end ___

on menu_MissingModuleKeys dView
   put the displayed_Object of dView into sObject
   put the displayed_HkeyArray of dView into hkeyArray
   --
   put array_ListKeys (hkeyArray) into hKeys
   put the module_Hierarchy [true] of sObject into hObjects
   repeat for each line hObject in hObjects
      put revRuggedID (hObject) into rObject
      filter hKeys without ("*" && rObject)
   end repeat
   
   put "Deps" && the number of lines of hKeys into sTitle
   put objectHkeyArray_FromKeys (hKeys) into objectHkeyArray
   set the displayed_Data [sTitle] of dView to objectHkeyArray
end menu_MissingModuleKeys

on menu_DisplayHkeyIndex dView
   put the displayed_HkeyArray of dView into hkeyArray
   put array_ListKeys (hkeyArray) into hKeys
   set the displayed_Data of dView to hKeys
   --
   put the number of lines of hKeys into keyNum
   set the title_Text of dView to keyNum && "Hkeys"
   --
   sort lines of hKeys
   return hKeys
end menu_DisplayHkeyIndex

on menu_ShowMissingProps dView
   get the strip_MissingProps of dView
   put it is false into keepMissingProps
   set the strip_MissingProps of dView to keepMissingProps
   --
   -- put the show_How of dView into showHow
   menu_Show dView, "projects"
end menu_ShowMissingProps

getprop checked_ShowMissingProps [dView]
   -- LocalArray ["stripMissingProps"]
   put the strip_MissingProps of dView into stripMissingProps
   return stripMissingProps is not false
end checked_ShowMissingProps

private on ____
end ____

on menu_Recreate dView
   put the displayed_Object of dView into sObject
   --
   ask_CreateDepHkeyArray sObject, dView
   
   # Display
   put the script_HkeyArray of sObject into hKeyArray
   put the name of sObject into sTitle
   set the displayed_Data [sTitle] of dView to hkeyArray
end menu_Recreate

on menu_Refresh dView
   if the shiftKey is "down" then
      put the script_HkeyArray of sObject into hKeyArray
   else
      put the displayed_HkeyArray of dView into hkeyArray
   end if
   put the displayed_Object of dView into sObject
   --
   put the name of sObject into sTitle
   set the displayed_Data [sTitle] of dView to hkeyArray
end menu_Refresh

on submenu_Dev
   return menu_DevTitle ("Global | HkeyArray | Tree | Menu")
end submenu_Dev
