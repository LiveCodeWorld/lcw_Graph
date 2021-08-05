script "lib_DotCreate"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DotCreate
type: library
version: 0.1

/*Some help*/


--> Working on
-
command dot_AddDefaultNode @graphHeaderBase, defaultShape
   if defaultShape is not empty then
      put "shape=" & defaultShape after nodeParams
   end if
   --
   put space & "style=" & kwote ("filled") after nodeParams
   put space & "fillcolor=" & kwote ("white")  after nodeParams
   --
   put "node [" & word 1 to -1 of nodeParams & "];" into defaultNodeBit
   --
   put CR&CR & defaultNodeBit after graphHeaderBase
end dot_AddDefaultNode

function dot_Render dotText, pDotCommand, pTextFile, pOutputFormat
   -- pDotCommand is an english equivalent of graphStyle
   
   dot_SaveTemporaryFile dotText, pTextFile
   put the result into pTextFile
   
   -- dot_Render dotFile, svgFile, pDotCommand, pImageFormat
   put dot_DoShell (pTextFile, pDotCommand, pOutputFormat) into shellResult
   if shellResult is false or shellResult is empty then
      exit to top
   else
      return shellResult
   end if
end dot_Render


--> Dot | Render
-
command dot_Render dotFile, svgFile, pDotCommand, pImageFormat
   if pDotCommand is empty then put "dot" into pDotCommand
   if pImageFormat is empty then put "svg" into pImageFormat
   --
   put pDotCommand into someShell
   put space & kwote (dotFile) after someShell
   put space & "-T" & pImageFormat after someShell
   put space & "-o" && kwote (svgFile) after someShell
   --
   put shell (someShell) into gvResult
   return gvResult
end dot_Render

function dot_ConstructHeaderBase graphSize, dotPropertyArray, graphStyle, pUseInches  
   dot_DeconstructPropertyArray dotPropertyArray, overlap, concentrate, splines, cluster, direction, dotOrder, defaultShape, defaultUrl
   --
   -- delete variable dotPropertyArray ["defaultShape"]
   --
   put CR into endChar
   if pUseInches is not false then
      -- think there is a bug here (graphs too large)
      put dot_RectFromSize (graphSize) into bbRect
      put dot_GraphInchSize (bbRect, true) into inchSize
      if inchSize is not empty then
         put "size=" & kwote(inchSize) & endChar after graphHeaderBase
      end if
   else
      put dot_RectFromSize (graphSize) into bbRect
      if bbRect is not empty then
         put "bb=" & kwote(bbRect) & endChar after graphHeaderBase
      end if
   end if
   delete variable dotPropertyArray ["size"]
   
   --
   if graphStyle is not "hierarchical"  then
      if overlap is not empty then put "overlap=" & overlap & endChar after graphHeaderBase
      if dotOrder is not empty then put  "ordering=" & dotOrder & endChar after graphHeaderBase
      if concentrate is not empty then
         put "concentrate=" & concentrate & endChar after graphHeaderBase
      end if
   end if
   delete variable dotPropertyArray ["overlap"]
   delete variable dotPropertyArray ["dotOrder"]
   delete variable dotPropertyArray ["concentrate"]
   -- delete variable dotPropertyArray ["graphStyle"]
   --
   if cluster is "none" and graphStyle = "hierarchical" then put "clusterrank=" & cluster & endChar after graphHeaderBase
   delete variable dotPropertyArray ["cluster"]
   --
   if splines is not empty then put "splines=" & splines & CR after graphHeaderBase
   delete variable dotPropertyArray ["splines"]
   --
   if direction is not empty then put "rankdir=" & direction & CR after graphHeaderBase
   delete variable dotPropertyArray ["direction"]
   --
   repeat for each key someKey in dotPropertyArray
      put dotPropertyArray [someKey] into someValue
      if someValue is not empty then
         put someKey & "=" & kwote(someValue) & CR after graphHeaderBase
      end if
   end repeat
   
   -- dot_AddDefaultNode
   delete char -1 of graphHeaderBase
   return graphHeaderBase
end dot_ConstructHeaderBase

function dot_ConstructHeader graphSize, pDotPropertyArray, graphStyle, pUseInches
   -- old?
   put dot_ConstructHeaderBase (graphSize, pDotPropertyArray, graphStyle, pUseInches) into graphHeaderBase
   
   put "graph [" & CR after graphHeader
   line_Indent graphHeaderBase
   put graphHeaderBase & CR after graphHeader
   put "];" & CR after graphHeader
   
   -- default node section
   dot_DeconstructPropertyArray pDotPropertyArray, overlap, concentrate, splines, cluster, direction, dotOrder, defaultShape, defaultUrl
   if defaultUrl is not empty then put "node [URL=" & kwote(defaultUrl) & "];" & CR after defaultNodeSection
   if defaultShape is not empty then put "node [shape=" & defaultShape & "];" & CR after defaultNodeSection
   if defaultNodeSection is not empty then put CR & defaultNodeSection & CR after graphHeader
   
   delete last char of graphHeader
   return graphHeader
end dot_ConstructHeader

function dot_RectFromSize graphSize
   switch graphSize
      case empty
         return empty
      case "full"
         put "0,0,3000,3000" into someRect
         return someRect
      case "screen"
         put dot_BboxSize (the screenrect) into someRect
         return someRect
      default -- "none"
         if graphSize is a rect then
            put dot_BboxSize (graphSize) into someRect
            return someRect
         else
            return empty
         end if
   end switch 
end dot_RectFromSize

function dot_BboxSize someRect
   put item 3 of someRect - item 1 of someRect into someWidth
   put item 4 of someRect - item 2 of someRect into someHeight
   put 0,0,someWidth,someHeight into someRect
   return someRect
end dot_BboxSize

command dot_ConvertToInches @pixelSize, screenRez
   -- was "dot_ConvertSizeToInches"
   if screenRez is empty then put 96 into screenRez
   set the numberformat to "0.0000"
   repeat with itemNum = 1 to the number of items of pixelSize
      put item itemNum of pixelSize into someNumber
      put someNumber / screenRez  into item itemNum of pixelSize
   end repeat
end dot_ConvertToInches

function dot_GraphInchSize someRect, expandIfNeeded
   if someRect is empty then return empty
   put item 3 of someRect - item 1 of someRect into someWidth
   put item 4 of someRect - item 2 of someRect into someHeight
   
   put someWidth,someHeight into someSize
   dot_ConvertToInches someSize
   if expandIfNeeded is true then
      put "!" after someSize
   end if
   return someSize
end dot_GraphInchSize


--> Private
-
command dot_ConstructPropertyArray @propertyArray, overlap, concentrate, splines, cluster, direction, dotOrder, defaultShape, defaultUrl
   -- was "dot_ConstructHeaderArray" - used by a few libs
   put overlap into propertyArray ["overlap"]
   put concentrate into propertyArray ["concentrate"]
   put splines into propertyArray ["splines"]
   put cluster into propertyArray ["cluster"]
   put direction into propertyArray ["direction"]
   put dotOrder into propertyArray ["dotOrder"]
   put defaultShape into propertyArray ["defaultShape"]
   put defaultUrl into propertyArray ["defaultUrl"]
end dot_ConstructPropertyArray

private command dot_DeconstructPropertyArray pDotPropertyArray, @overlap, @concentrate, @splines, @cluster, @direction, @dotOrder, @defaultShape, @defaultUrl
   put pDotPropertyArray ["graphRect"] into graphRect
   put pDotPropertyArray ["overlap"] into overlap
   put pDotPropertyArray ["concentrate"] into concentrate
   put pDotPropertyArray ["splines"] into splines
   put pDotPropertyArray ["cluster"] into cluster
   put pDotPropertyArray ["direction"] into direction
   put pDotPropertyArray ["dotOrder"] into dotOrder
   put pDotPropertyArray ["defaultShape"] into defaultShape
   put pDotPropertyArray ["defaultUrl"] into defaultUrl
end dot_DeconstructPropertyArray

private function outline_IncreaseIndent someOsSection, byIndentLevel, indentString
   if indentString is empty then put tab into indentString
   if byIndentLevel is not a number then put 1 into byIndentLevel
   if byIndentLevel = 0 then return someOsSection
   if byIndentLevel < 0 then
      return outline_DecreaseIndent (someOsSection, abs(byIndentLevel))
   end if
   put text_RepeatString (indentString, byIndentLevel) into indentWhiteSpace
   repeat with ii = 1 to the number of lines of someOsSection
      put indentWhiteSpace before line ii of someOsSection
   end repeat
   return someOsSection
end outline_IncreaseIndent

private function outline_DecreaseIndent someOsSection, byIndentLevel
   if byIndentLevel = 0 then return someOsSection
   repeat with ii = 1 to the number of lines of someOsSection
      put line ii of someOsSection into osTitle
      repeat byIndentlevel
         if char 1 of osTitle is tab then
            delete char 1 of osTitle
         else
            exit repeat
         end if
      end repeat
      put osTitle into line ii of someOsSection
   end repeat
   return someOsSection
end outline_DecreaseIndent

private command file_CreateText someText, pFile
   if pFile is empty then put the tempname into pFile
   --
   put folder_Above (pFile) into someFolder
   folder_CreateNested someFolder
   put someText into url ("file:" & pFile)
   return pFile
end file_CreateText

private function folder_Above fileOrFolder
   set the itemdelimiter to "/"
   if char -1 of fileOrFolder is "/" then delete char -1 of fileOrFolder
   delete last item of fileOrFolder
   if fileOrFolder is empty then 
      return "."
   else
      return fileOrFolder & "/"
   end if
end folder_Above

private command folder_CreateNested someFolder
   if there is a folder someFolder then return empty   
   set the itemdelimiter to "/"
   repeat with itemNum = 2 to the number of items of someFolder
      put item 1 to itemNum of someFolder & "/" into testFolder
      if there is a folder testFolder then next repeat
      create folder testFolder
   end repeat
   text_AddTrailing someFolder, slash
   return someFolder
end folder_CreateNested

private function kwote someText, pQuoteChar
   if pQuoteChar is empty then put quote into pQuoteChar
   return pQuoteChar & someText & pQuoteChar
end kwote

private command array_AddToIndex newLines, someKey, @someArray
   -- if the number of lines of keys(someArray) > 5 and someKey contains "form_IsRed" then breakpoint
   put someArray [someKey] into someIndex
   line_AddToIndex newLines, someIndex
   put word 1 to -1 of someIndex into someArray [someKey]
   return the number of lines of someIndex
end array_AddToIndex

private command line_AddToIndex newLines, @someIndex
   repeat for each line someLine in newLines
      line_Add someLine, someIndex
   end repeat
   if line 1 of someIndex is empty then delete line 1 of someIndex
end line_AddToIndex

private command line_Add someLines, @someIndex
   repeat for each line someLine in someLines
      if someLine is empty then next repeat
      set the wholematches to true
      put lineoffset(someLine, someIndex) into lineNum
      if lineNum is 0 then
         put the number of lines of someIndex into maxLine
         put maxLine + 1 into lineNum
         put someLine into line lineNum of someIndex
      else
         put lineNum & comma after lineNums
      end if
   end repeat
   delete char -1 of lineNums
   return lineNums
end line_Add

private command text_AddTrailing @someText, someChar
   if char -1 of someText is not someChar then
      put someChar after someText
   end if
end text_AddTrailing

private function text_RepeatString someString, repeatNum
   repeat repeatNum
      put someString after repeatString
   end repeat
   return repeatString
end text_RepeatString
