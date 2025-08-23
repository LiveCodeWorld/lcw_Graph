script "lib_Data"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Data
type: library
version: 0.1

/*
In this library we explore the creation of specific data types that other libraries mmay use.
In particular we look at:

- aData = associatine or named arrays
- iData = numerically indexed array

We exploree this while moving over from older custum data formats that were often non-array based such as sKey and aData
*/


--> Working on
-

--> iData
-
command iData_Add @iData, itemArray
   put item 2 of the extents of iData into newItemNum
   add 1 to newItemNum
   put itemArray into iData [newItemNum]
   return newItemNum
end iData_Add

command iData_AddIndexArray @iData, indexedDataToAdd
   get item 2 of the extents of iData
   put it + 1 into lastNum
   repeat with itemNum = 1 to item 2 of the extents of indexedDataToAdd
      put indexedDataToAdd [itemNum] into iData [lastNum]
      add 1 to lastNum
   end repeat
   return lastNum
end iData_AddIndexArray


--> aData
-
function aData_GetMarkovArray depKey, aData
   put adata_GetChildArray (depKey, aData) into markovArray
   repeat for each key childKey in childArray
      put adata_GetParentAndChildArray (childKey, aData) into childParentArray
      union markovArray with childParentArray
   end repeat
   --
   put adata_GetParentAndChildArray (depKey, aData) into parentArray
   union markovArray with parentArray
   --
   return markovArray
end aData_GetMarkovArray

function aData_GetParentAndChildArray sKey, aData
   local parentArray
   repeat for each key maybeParentKey in aData 
      put aData [maybeParentKey] into childKeyArray
      if sKey is among the keys of childKeyArray then
         put empty into parentArray [maybeParentKey][sKey]
      end if
   end repeat
   return parentArray
end aData_GetParentAndChildArray

function aData_GetChildArray sKey, aData
   hkeyArray_ConstructSubArray sKey, aData, childArray
   return childArray
end aData_GetChildArray


--> iData | IndexedArray
-
command indexedArray_Add @indexedData, itemArray, insertNum
   if indexedData is emmpty then
      -- regardless of insertNum
      put itemArray into indexedData
      return item 2 of the extents of indexedData
   end if
   
   put item 2 of the extents of indexedData into maxNum
   -- move all items (rows) from insertNum onwards one-up
   repeat with itemNum = maxNum down to insertNum
      get indexedData [itemNum] 
      put itemNum + 1 into oneAfter
      put it into indexedData [oneAfter]
   end repeat
   
   -- insert itemArray into row insertNum (overwriting duplicated old row)
   put itemArray into indexedData [insertNum]
   return item 2 of the extents of indexedData
end indexedArray_Add

command indexedArray_Delete @indexedData, rowRow
   put item 2 of the extents of indexedData into maxNum
   put indexedData [rowRow] into rowDataToMove
   
   -- first lets delete and re-number
   put rowRow + 1 into startDeleteNum
   repeat with itemNum = startDeleteNum to maxNum
      get indexedData [itemNum]
      put itemNum - 1 into oneBefore
      put it into indexedData [oneBefore]
   end repeat
   delete variable indexedData [maxNum]
   --
   return rowDataToMove
end indexedArray_Delete


--> Array | Index
-
command array_AddToNumbered @indexedArray, keyOrArray, pValue
   /*
   Adds a value to the end of an indexed array.
   Value can be simple or an array
   If someKey is an array it adds the array
   */
   
   put item 2 of the extents of indexedArray + 1 into newIndexNum
   if keyOrArray is an array then
      put keyOrArray into indexedArray [newIndexNum]
   else
      put pValue into indexedArray [newIndexNum][keyOrArray]
   end if
   return newIndexNum
end array_AddToNumbered

function array_IsNumbered pArray pConsecutive
   /*
   was: rigIsNumberedArray ( from revIgniter script Common.lc )
   
   Check if array is numbered. 
   Parameters: array <pArray>, bool <pConsecutive> flag for checking if numbers are consecutive
   Return: list (bool,integer)
   
   copyright: Copyright (c) 2009 - 2015, dimensionB Bitter u. Bitter GmbH
   author: rabit@revigniter.com
   license: http://www.apache.org/licenses/LICENSE-2.0
   */
   
   if pConsecutive is "" then
      put FALSE into tConsecutive
   else
      put pConsecutive into tConsecutive
   end if
   
   # CHECK IF ARRAY IS NUMBERED
   # SET DEFAULT RETURN VALUE
   put TRUE into tNumbered
   put the keys of pArray into tArrayKeys
   
   if tConsecutive is true then
      sort lines of tArrayKeys numeric
      
      put 2 into tControlValue
      
      repeat for each line thisLine in tArrayKeys
         if (thisLine is not an integer) or (thisLine + 1 <> tControlValue) then
            put FALSE into tNumbered
            exit repeat
         end if
         add 1 to tControlValue
      end repeat
   else
      repeat for each line thisLine in tArrayKeys
         if thisLine is not an integer then
            put FALSE into tNumbered
            exit repeat
         end if
      end repeat
   end if
   
   put line 1 of tArrayKeys into tStartValue
   
   return tNumbered & "," & tStartValue
end array_IsNumbered
