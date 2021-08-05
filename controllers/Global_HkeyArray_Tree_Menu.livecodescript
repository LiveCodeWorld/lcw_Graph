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
   put the display_View of tObject into displayView
   -- put the displayed_Object of displayView into displayView
   put the displayed_HkeyArray of displayView into hkeyArray
   --
   put hkeyArray into LocalArray ["hkeyArray"]
   put displayView into LocalArray ["displayView"]
   --
   return displayView
end menu_Target

getprop checked_ShowMissingProps [displayView]
   -- LocalArray ["stripMissingProps"]
   put the strip_MissingProps of displayView into stripMissingProps
   return stripMissingProps is not false
end checked_ShowMissingProps

getprop show_Param [displayView]
   -- put LocalArray ["showHow"] into showHow
   put the show_How of displayView into showHow
   if showHow is empty then put "projects" into showHow
   return showHow
end show_Param

getprop show_Params [displayView]
   return "projects,stacks,-,hkeyArray"
end show_Params


--> Global | HkeyArray | Tree | Menu
-
on menu_Show displayView, showHow
   put the displayed_HkeyArray of displayView into hkeyArray
   put the strip_MissingProps of displayView into stripMissingProps
   --
   switch showHow
      case "stacks"
         put hkeyArray_GetStackDepArray (hkeyArray) into dArray
         break
      case "projects"
         put hkeyArray_GetProjectDepArray (hkeyArray, stripMissingProps) into dArray
         break
      case "hkeyArray"
         put hkeyArray into dArray
         break
   end switch
   --
   set the displayed_Data of displayView to dArray
   set the show_How of displayView to showHow
end menu_Show

on _
end _

on menu_ShowMissingProps displayView
   get the strip_MissingProps of displayView
   put it is false into keepMissingProps
   set the strip_MissingProps of displayView to keepMissingProps
   --
   -- put the show_How of displayView into showHow
   menu_Show displayView, "projects"
end menu_ShowMissingProps

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_DisplayMissing displayView
   put the displayed_HkeyArray of displayView into hkeyArray
   --
   put hkeyArray_GetStackDepArray (hkeyArray) into depArray
   put depArray ["Missing"] into missingArray
   put hkeyArray_TidyMissing (missingArray) into prettyMissingArray
   --
   display_Data prettyMissingArray, "prettyMissingArray"
end menu_DisplayMissing


