script "lib_Moti"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Moti
type: library
version: 0.1

/*Some help*/


--> Working on
-
on mDouble_MotiGraph dView, sValue
   put the selected_Path of dView into sPath
   switch item 1 of sPath
      case "browserLink"
         launch url sValue
         break
      default
         put sValue
   end switch
end mDouble_MotiGraph


--> Moti
-
command display_MotiGraph
   put "https://coda.io/apis/v1/docs/3tDGck2m-P/tables/grid-fwNT3PP3Eb/rows/i-XlGIf6wFGH" into restURL
   put "?" after restURL
   put "useColumnNames=true" after restURL
   -- put "&valueFormat=rich" after restURL
   put "&valueFormat=simpleWithArrays" after restURL
   --
   put "7a9247ab-fe0a-486d-9965-8957355ceaef" into oAuthToken
   --
   put jsonrpc_GetArray (restURL, oAuthToken) into rData
   display_Data rData, "Moti Graph", "Coda"
   put the result into dView
   display_SetInteractions dView, "Moti | Graph", "mDouble_MotiGraph", "lcw_Graph"
   return dView
end display_MotiGraph


