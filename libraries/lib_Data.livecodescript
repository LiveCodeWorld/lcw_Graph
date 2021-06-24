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
- iData = numeerically indexed array

We exploree this while moving over from older custum data formats that were often non-array based such as sKey and aData
*/


--> Working on
-
function adata_GetMarkovArray depKey, aData
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
end adata_GetMarkovArray

-- function adata_ExtractParentsAndChildrenArray sKey, aData
local subArray
--
hkeyArray_ConstructSubArray sKey, aData, childArray
put childArray into markovArray [sKey]
--
hkeyArray_ConstructParentArray sKey, aData, parentArray
repeat for each key parentHkey in parentArray
   put empty into markovArray [sKey][parentHkey]
end repeat
return subArray
end adata_ExtractParentsAndChildrenArray


--> aData
-
function adata_GetParentAndChildArray sKey, aData
   local parentArray
   repeat for each key maybeParentKey in aData 
      put aData [maybeParentKey] into childKeyArray
      if sKey is among the keys of childKeyArray then
         put empty into parentArray [maybeParentKey][sKey]
      end if
   end repeat
   return parentArray
end adata_GetParentAndChildArray

function adata_GetChildArray sKey, aData
   hkeyArray_ConstructSubArray sKey, aData, childArray
   return childArray
end adata_GetChildArray


--> Data
-
--> Deps
-
