-- $Revision: 1.6 $
-- $Date: 2012-12-30 12:48:59 $

local function trace(a,b,c,d) return end

hjtw = {}

--[[
Generates a function to which you add HTML lines with indent levels (using tabs).
Usage, assuming function called FooHTML:
FooHTML = GetHTMLAdder(0,'') -- get an adder that starts with no indent, no html
FooHTML() - returns current HTML string
FooHTML(0,'<p>',1) -- adds '<p>\n' at current indent level, then indents by one
FooHTML(-1,'</p>') -- decreases indent level by one, and adds '</p>\n'
FooHTML('absolute','100') -- adds '100' to the HTML, with no indents or newlines
--]]
function hjtw.GetHTMLAdder(StartingIndent, StartingHTML)
   local CurIndent = StartingIndent or 0
   local CurHTML = StartingHTML or ''
   
   return function(PreIndent,NewLine,PostIndent)
      if PreIndent and PreIndent ~= 'absolute' then
         CurIndent = CurIndent + PreIndent
      end
            
      if PreIndent == 'absolute' then
         CurHTML = CurHTML .. NewLine         
      elseif NewLine then
         for i = 1, CurIndent do
            NewLine = '\t' .. NewLine
         end
         CurHTML = CurHTML .. NewLine .. '\n'
      end      
      
      PostIndent = PostIndent or 0
      CurIndent = CurIndent + PostIndent
      
      return CurHTML, CurIndent
   end
end

function hjtw.pairsByKeys (t, f)   
   local a = {}
   for n in pairs(t) do table.insert(a, n) end
   table.sort(a, f)
   local i = 0      -- iterator variable
   local iter = function ()   -- iterator function
      i = i + 1
      if a[i] == nil then return nil
      else return a[i], t[a[i]]
      end
   end
   return iter
end

function hjtw.GetOnlyKey(t)
   --returns the only key of a one-key table
   if not t then
      return nil
   else
      for a,b in next, t, nil do
         return a      
      end
   end
end

function hjtw.DeleteHelp(dir,platform)
   if os.fs.access(dir) then
      if platform == 'windows' then
         os.execute('rmdir /S /Q ' .. dir)
      else
         os.execute('rm -rf ' .. dir)
      end
   end   
end

function hjtw.CheckoutHelp(dir,platform,tag)
   hjtw.DeleteHelp(dir,platform)   
   openDir = pcall(os.mkdir,dir)
   if not tag or tag =='' then tag = 'HEAD' end
   os.execute('cvs checkout -r '..tag..' -d ' .. dir .. '/ DBD/translator_help')
end

function hjtw.GetModules(dir,platform)
   local FileList
   if platform == 'windows' then
      FileList = io.popen('dir /s ' .. dir .. ' /b')
      trace(FileList)
   else
      --FileList = ???
   end
   local ModuleTable = {}
   
   for line in FileList:lines() do      
      local CurJSON = line:match(dir .. '.*json$')
      if CurJSON then
         local ModuleLoc = CurJSON:sub((dir .. '/'):len()+1,-6)
         local ModuleName = (ModuleLoc:gsub('\\','%.'))
         ModuleLoc = ModuleLoc:gsub('\\','\/')         
         local ModuleFile = io.open(dir .. '/' .. ModuleLoc .. '.json', 'r')
         
         ModuleTable[#ModuleTable + 1] = {
            Name = ModuleName,
            Location = ModuleLoc,
            Functions = json.parse{data = ModuleFile:read('*all')},            
         }
                 
         ModuleFile:close()  
      end
   end
   
   return ModuleTable
end

function hjtw.VerifyJsonModule(ModuleFunctions)
   --returns HTML document listings warnings / issues with a help JSON file
      
   local mainHTML = hjtw.GetHTMLAdder(0,'<ul>\n')   
   local ModIssueFound = false
   
   local RequiredFields = {'Title','SummaryLine','Desc','Usage','Returns','Examples'}
   
   for a,b in hjtw.pairsByKeys(ModuleFunctions) do
      local FunIssueFound = false      
      local curHTML = hjtw.GetHTMLAdder()      
      
      curHTML(0,'<li>')
      curHTML(0,'<h3>' .. a .. '</h3>')
      curHTML(0,'<ul>',1)
      
      for i,v in ipairs(RequiredFields) do
         if not b[v] then
            FunIssueFound = true
            curHTML(0,'<li>MISSING "' .. v .. '" field</li>')
         end
      end            
                              
      local NumParamsReq = 0
      local NumParamsOpt = 0
      if b['Parameters'] then
         local ParamOrderWarned = false
         for i,v in ipairs(b['Parameters']) do
            local CurParamName = hjtw.GetOnlyKey(v)
            local CurParam = v[CurParamName]            
            if CurParam['Opt'] then              
               NumParamsOpt = NumParamsOpt + 1
            else
               NumParamsReq = NumParamsReq + 1
               if not b['ParameterTable'] and NumParamsOpt > 0 and not ParamOrderWarned then
                  curHTML(0,'<li>Required parameter listed after optional one</li>')
                  ParamOrderWarned = true
                  FunIssueFound = true
               end
            end
         end   
            
         for i,v in next, b['Parameters'], nil do            
            local CurParamName = hjtw.GetOnlyKey(v)
            local CurParam = v[CurParamName]
            if not CurParam['Desc'] then
               curHTML(0,'<li>No "Desc" for parameter "' .. CurParamName .. '"</li>')
            end
         end
      end --parameters
                  
      if b['ParameterTable'] then
         if NumParamsReq + NumParamsOpt == 0 then
               curHTML(0,'<li>Parameter table specified but no parameters specified</li>')
            FunIssueFound = true
         end
      else
         if NumParamsReq + NumParamsOpt == 0 then
            if b['Parameters'] then
               curHTML(0,'<li>Empty JSON parameter table</li>') 
            else
               curHTML(0,'<li>MISSING JSON parameter table</li>') 
            end               
            FunIssueFound = true
         end
      end
                          
      if b['SeeAlso'] then                  
         for c,d in ipairs(b['SeeAlso']) do
            if not d.Link then
               curHTML(0,'<li>"SeeAlso" link number ' .. c .. ' MISSING the link</li>')
               FunIssueFound = true
            end            
            if not d.Title then
               curHTML(0,'<li>"SeeAlso" link number ' .. c .. ' MISSING title</li>')
               FunIssueFound = true
            end           
         end
      end  
      
      if b['Returns'] then
         if type(b['Returns']) ~= 'table' then
            curHTML(0,'<li>Returns value is a '..type(b['Returns']).. ' should be a TABLE</li>')
         end
      end
      
      curHTML(-1,'</ul>')
      curHTML(0,'</li>')
      
      if FunIssueFound == true then
         ModIssueFound = true
         mainHTML('absolute',curHTML())
      end
      
   end --functions
   
   mainHTML(0,'</ul>')
   
   if ModIssueFound then
      return mainHTML()
   else 
      return ''
   end
end

function hjtw.VerifyJson(ModuleTable, DoNotWarn)
   local WarningsHTML = hjtw.GetHTMLAdder(0,'<h1>Issues with translator help files</h1>\n')
   WarningsHTML(0,'<ul>')
      
   for i,ModuleInfo in ipairs(ModuleTable) do
      if not DoNotWarn[ModuleInfo.Name] then
         WarningsHTML(0,'<li><h2>' .. ModuleInfo.Name .. '</h2></li>')
         WarningsHTML('absolute',
            hjtw.VerifyJsonModule(
               ModuleInfo.Functions
            )
         )
      end
   end
   
   WarningsHTML(0,'</ul>')
   
   return WarningsHTML()   
end

function hjtw.GetFileRevision(FileLoc)
   local FileStatus = io.popen('cvs status ' .. FileLoc):read('*a')      
   local iA, iB = FileStatus:find('Working revision:\t',0,true)
   if iA then
      local iA, iB = FileStatus:find('Working revision:\t',0,true)
      trace(iA,iB)
      iA = FileStatus:find('\n', iB+1)
      local Result = FileStatus:sub(iB+1,iA-1)
      if Result:find('No entry') then
         return nil
      else
         return Result
      end
   else
      return nil
   end
end

return hjtw