-- $Revision: 1.19 $
-- $Date: 2012-12-30 12:48:59 $

require 'hjtw'

hjtw_wiki = {}

local function trace(a,b,c,d) return end

-- JULIAN: converts absolute links to relative (& keeps Dmtri happy)
local function absWikiLinkToRel(S)
   return S:gsub('http://wiki.interfaceware.com/(%d+).html','default.asp?W\%1')
end

function hjtw_wiki.RevisionComment(dir, FileLoc)
   return FileLoc .. ' (CVS revision ' .. 
   (hjtw.GetFileRevision(dir .. '/' .. FileLoc) or 'missing')
   .. ')'
end

--returns two values: (1) whether request succeeded, and (2) is wiki up to date
function hjtw_wiki.GetWikiStatus(p, Name, CurRevisionComment)
   local APIresponse = xml.parse{data=
      net.http.post{
         url = p.FogBugzURL, auth= {username='julian.muir', password='oj249QqC'}, ------------------------------------------
         parameters = {
            token = p.FogBugzToken, 
            cmd = 'listRevisions',
            ixWikiPage = p.WikiMap[Name]['WikiPageNum']
         },
         live=true
      }
   }
   
   local WikiRevisionComment = ''
   local RequestFailed = false
   if APIresponse.response and APIresponse.response.revisions then
      local numRevisions = APIresponse.response.revisions:childCount('revision')            
      if APIresponse.response.revisions[numRevisions].sComment:childCount('sComment') > 0 then
         WikiRevisionComment = APIresponse.response.revisions[numRevisions].sComment[1]:nodeValue()
      end
      return true, (WikiRevisionComment == CurRevisionComment)
   elseif APIresponse.response and APIresponse.response[1]:nodeName() == 'error' then
      iguana.logError('Request for wiki revisions about ' .. Name ..
         ' failed. Output of FogBugz API: "' .. APIresponse.response[1][2]:nodeValue() .. '"')
      return false
   else
      iguana.logError('Request for wiki revisions about ' .. Name .. ' failed.')   
      return false
   end
end

function hjtw_wiki.GetHeadline(p, Name)
   local WikiHeadline
   if p.WikiMap[Name].Title then
      WikiHeadline = p.WikiMap[Name].Title
      if p.WikiMap[Name].Subtitle then
         WikiHeadline = WikiHeadline .. ' - ' .. p.WikiMap[Name].Subtitle
      end
   elseif p.WikiMap[Name].Subtitle then
      WikiHeadline = Name .. ' - ' .. p.WikiMap[Name].Subtitle
   else
      WikiHeadline = Name
   end
   if p.HeadlineAppend ~= nil then 
      return WikiHeadline .. p.HeadlineAppend
   else 
      return WikiHeadline
   end
end

function hjtw_wiki.UpdatePage(Info)
   local APIresponse = xml.parse{data=
      net.http.post{
         url = Info.Url, auth= {username='julian.muir', password='oj249QqC'}, ------------------------------------------
         parameters = {
            token = Info.Token, 
            cmd = 'editArticle',
            ixWikiPage = Info.PageNum,
            sHeadline = Info.Headline,
            sBody = Info.Content,
            sComment = Info.Comment
         }
      }
   } 
   if not APIresponse.response or APIresponse.response[1]:nodeName() == 'error' then            
      local ErrorMessage = 'Wiki update for page "' .. Info.Headline .. '" failed.'
      if not APIresponse.response == nil then
         if APIresponse.response[1]:nodeName() == 'error' then
            ErrorMessage = ErrorMessage .. ' Output of FogBugz API: "' .. APIresponse.response[1][2]:nodeValue() .. '"'
         end
      end
      iguana.logError(ErrorMessage)
   else
      iguana.logInfo('Wiki update for page "' .. Info.Headline .. '" succeeded.')
   end        
end

function hjtw_wiki.PrettifySnippet(code, indent)
   indent = indent or 0
   
   if code:sub(1,5) == '<pre>' and code:sub(-6,-1) == '</pre>' then
      code = code:sub(6,-7)
   end
   
   while code:sub(-1,-1) == '/n' do
      code = code:sub(1,-2)
   end
        
   local NumLines=1
   do 
      for word in code:gmatch('\n') do
         NumLines = NumLines + 1
      end
   end
   
   ResultHTML = hjtw.GetHTMLAdder(indent)
   
   ResultHTML(0,'<p>')
   ResultHTML(1,'<div class="codesnippet">')
   ResultHTML(1,'<table>')
   ResultHTML(1,'<tr>')
   
   --add line numbers   
   ResultHTML('absolute','<td class="hide"><pre class="linenos">')
   for i = 1, NumLines do
      ResultHTML('absolute',i .. ':\n')
   end   
   ResultHTML('absolute','</pre></td>\n')
   
   --add code   
   ResultHTML('absolute','<td><pre class="prettyprint">')
   ResultHTML('absolute',code)
   ResultHTML('absolute','</pre></td>\n')
   
   ResultHTML(0,'</tr>')     
   ResultHTML(-1,'</table>')
   ResultHTML(-1,'</div>')
   ResultHTML(-1,'</p>')
   
   return ResultHTML()
end

function hjtw_wiki.GenerateHTML(jsonTable, PageNum)
   --returns two strings: function listing and function descriptions
   
   local tocHTML = hjtw.GetHTMLAdder(0,'The functions for this module are:<br>\n')
   local mainHTML = hjtw.GetHTMLAdder(0,'<hr>\n')
   
   tocHTML(0,'<ul>',1)
   for a,b in hjtw.pairsByKeys(jsonTable) do
      
      tocHTML(0,'<li><a href="#' .. a .. '" rel="nofollow">' .. a .. '</a> : ' .. (b['SummaryLine'] or '') .. '</li>')
      
      local ParamList=''
      if b['ParameterTable'] then
         ParamList = '{}'
      else
         ParamList = '()'
      end   
            
      mainHTML(0,'<br><h2><a name="' .. a .. '">' .. b['Title'] .. '</a>' .. ParamList ..' [<a href="#" rel="nofollow">top</a>]</h2>')
      
      if b['Usage'] then
         mainHTML(0,'<p><b>Usage:</b> ' .. b['Usage'] .. '</p>')
      end      
      
      mainHTML(0,'<p>',1)
      mainHTML(0,absWikiLinkToRel(b['Desc']))
      mainHTML(-1,'</p>')
      
      mainHTML(0,'<p>',1)
      if b['Returns'] and #b['Returns'] > 0 then
         mainHTML(0,'Returns:')
         mainHTML(0,'<ul>',1) 
         if type(b['Returns'])=='table' then
            for i,v in ipairs(b['Returns']) do
               mainHTML(0,'<li>' .. v.Desc .. '</li>')
            end  
         else
            mainHTML(0,'<li>' .. b['Returns'] .. '</li>')
         end
         mainHTML(-1,'</ul>')
      else
         mainHTML(0,'Returns: nothing.')
      end      
      mainHTML(-1,'</p>')
                           
      local NumParamsReq = 0
      local NumParamsOpt = 0
      
      if b['Parameters'] then                      
         for i,v in ipairs(b['Parameters']) do
            local CurParamName = hjtw.GetOnlyKey(v)
            local CurParam = v[CurParamName]            
            if CurParam['Opt'] then               
               NumParamsOpt = NumParamsOpt + 1
            else
               NumParamsReq = NumParamsReq + 1
            end
         end
      end
         
      mainHTML(0,'<p>',1)
      if b['ParameterTable'] then
         if NumParamsReq > 0 then
            mainHTML(0,'Accepts a table with the following required entries:')
         else
            mainHTML(0,'Accepts a table with no required entries.')
         end
      else
         if NumParamsReq > 0 then
            mainHTML(0,'Required parameters:<br>')
         elseif NumParamsOpt > 0 then
            mainHTML(0,'No required parameters.<br>')
         else
            mainHTML(0,'No parameters.<br>')
         end
      end
             
      local _,CurIndent = mainHTML()
      local OptionalParams = hjtw.GetHTMLAdder(CurIndent,'')
      if b['Parameters'] and NumParamsReq + NumParamsOpt > 0 then
         mainHTML(0,'<ul>',1)     
         for i,v in ipairs(b['Parameters']) do
            -- for some reason there's extra nesting in the json file --
            local CurParamName = hjtw.GetOnlyKey(v)
            local CurParam = v[CurParamName]
            if CurParam['Opt'] then
               OptionalParams(0,'<li>',1)
               OptionalParams(0,'<b>' .. CurParamName .. '</b>: ' .. CurParam['Desc'])
               OptionalParams(-1,'</li>')
            else
               mainHTML(0,'<li>',1)
               mainHTML(0,'<b>' .. CurParamName .. '</b>: ' .. CurParam['Desc'])
               mainHTML(-1,'</li>')
            end
         end
         mainHTML(-1,'</ul>')
      end      
      mainHTML(-1,'</p>')
         
      if NumParamsOpt > 0 then
         mainHTML(0,'<p>',1)
         if b['ParameterTable'] then              
            mainHTML(0,'The following optional parameters can be added to the table:<br>')
         else
            mainHTML(0, 'Optional parameters:<br>')
         end
         mainHTML(0,'<ul>',1)
         OptionalHTML = OptionalParams()
         mainHTML('absolute',OptionalHTML)
         mainHTML(-1,'</ul>')
         mainHTML(-1,'</p>')
      end      
      
      if b['Examples'] then         
         mainHTML(0,'<h3>Sample Code</h3>')
         local _,CurIndent = mainHTML()
         for i,v in ipairs(b['Examples']) do            
            mainHTML(0,hjtw_wiki.PrettifySnippet(v,CurIndent))
         end
      end
      if b['SeeAlso'] then
         mainHTML(0,'<h3>For More Information</h3>')
         mainHTML(0,'<ul>',1)         
         for c,d in ipairs(b['SeeAlso']) do
            -- do not link back to same page (e.g., do not link 447-->447)
            if d.Link:find('http://wiki.interfaceware.com/') then
               local linkPgNum = tonumber(d.Link:sub(d.Link:find('%d+')))
               if linkPgNum ~= PageNum then -- not self-reference
                  mainHTML(0,'<li>', 1)
                  mainHTML(0,'<a href="' .. absWikiLinkToRel(d.Link) .. '">'.. d.Title ..'</a>')
                  mainHTML(-1,'</li>')
               end
            else -- always link to external pages (not in wiki)
               mainHTML(0,'<li>', 1)
               mainHTML(0,'<a href="' .. absWikiLinkToRel(d.Link) .. '">'.. d.Title ..'</a>')
               mainHTML(-1,'</li>')
            end
         end        
         mainHTML(-1,'</ul>')         
      end           
   end --functions
   tocHTML(-1,'</ul>')
   
   return tocHTML(), mainHTML()
end

--replace "links" like 'hjtw:[ModuleName]' with link to corresponding page number
--if can't find it in WikiMap, replace with empty link
--JULIAN changed to work with 'hjtw:[ModuleName]#xxxx' also
function hjtw_wiki.ReplaceModuleLinks(HTML, WikiMap)
   return HTML:gsub('href="hjtw:(.-)"', 
      function(m)
         local PageLocation = ''
         local ix = m:find('#')
         if ix then
            if WikiMap[m:sub(1,ix-1)] and WikiMap[m:sub(1,ix-1)].WikiPageNum then
               PageLocation = WikiMap[m:sub(1,ix-1)].WikiPageNum
               PageLocation = PageLocation .. m:sub(ix,#m)
            end
         else
            if WikiMap[m] and WikiMap[m].WikiPageNum then
               PageLocation = WikiMap[m].WikiPageNum
            end
         end
         return 'href="default.asp?W' .. PageLocation .. '"'
      end
   )
end

--Generate HTML from the JSON file and the template HTML file
--replace placeholder divs with generated content; should be just one of each   
function hjtw_wiki.FillTemplate(dir, FileLoc, WikiMap, PageNum)   
   local ModuleFile = io.open(dir .. '/' .. FileLoc .. '.json', 'r')
   local FunctionListHTML, FunctionDetailsHTML = hjtw_wiki.GenerateHTML(
      json.parse{
         data = ModuleFile:read('*all')               
      },
      PageNum
   )
   ModuleFile:close()   
            
   local TemplateHTMLFile = io.open(dir .. '/' .. FileLoc .. '.html', 'r')
   if TemplateHTMLFile then
      local WikiContent = TemplateHTMLFile:read('*all')
      
      --replace "links" like 'hjtw:ModuleName' with the corresponding page number
      --if can't find it in WikiMap, replace with empty link
      WikiContent = hjtw_wiki.ReplaceModuleLinks(WikiContent, WikiMap)
      
      WikiContent = WikiContent:gsub('<div id="FunctionList" />', FunctionListHTML, 1)
      WikiContent = WikiContent:gsub('<div id="FunctionDetails" />', FunctionDetailsHTML, 1)
      return WikiContent
   else      
      iguana.logInfo('Did not find ' ..FileLoc.. '.html (help template). Generating minimal documentation.')
      return FunctionListHTML .. '\n' .. FunctionDetailsHTML
   end   
end

function hjtw_wiki.WikiUpdate(p)
   --set up for running as a channel, and only running once    
   if iguana.isTest() then      
      return
   elseif HJTW_ALREADY_RUN == true then
      iguana.logError('Channel should only be run once.')
      return
   else
      HJTW_ALREADY_RUN = true
   end

   --check out files from repository   
   if p.UpdateAllFiles then
       hjtw.CheckoutHelp(p.hjtwDir,'windows',p.Tag)
   end
            
   local ModuleTable = hjtw.GetModules(p.hjtwDir,'windows')

   if p.PrintWarnings then    
      local WarningFile = io.open('Translator Help Warnings.html','w')
      WarningFile:write(hjtw.VerifyJson(ModuleTable, p.DoNotWarn))
      WarningFile:close()
      if p.OnlyPrintWarnings then
         return
      end
   end
   
   local NoMapping = false
   local channelTxt = ''
   --Generate the HTML for each module and send it off to the wiki         
   for i,ModuleInfo in ipairs(ModuleTable) do
      --Check for new modules that are in the repository but not in our mapping
      if not p.WikiMap[ModuleInfo.Name] then
         if not p.DoNotMap[ModuleInfo.Name] then
            NoMapping = true
            channelTxt = channelTxt..'Module ' .. ModuleInfo.Name .. ' isn\'t being mapped to the wiki.\n'
            iguana.setChannelStatus{color='yellow', text=channelTxt}
         end
      else                   
         --Look up CVS revision numbers and generate revision comment--             
         local CurRevisionComment = 'Generated from ' ..
         hjtw_wiki.RevisionComment(p.hjtwDir, ModuleInfo.Location .. '.json') .. ' and ' ..
         hjtw_wiki.RevisionComment(p.hjtwDir, ModuleInfo.Location .. '.html') .. '.'
         
         local RequestSucceeded, WikiUpToDate = hjtw_wiki.GetWikiStatus(p, ModuleInfo.Name, CurRevisionComment)
         
         --Only update wiki if the current version is newer  
         if not iguana.isTest() and RequestSucceeded and (not WikiUpToDate or p.ReplaceAll) then
            iguana.logInfo('Page for ' .. ModuleInfo.Name .. ' out of date on wiki. Updating wiki.')
            hjtw_wiki.UpdatePage{
               Url = p.FogBugzURL,
               Token = p.FogBugzToken,
               PageNum = p.WikiMap[ModuleInfo.Name].WikiPageNum,
               Headline = hjtw_wiki.GetHeadline(p, ModuleInfo.Name),
               Content = hjtw_wiki.FillTemplate(p.hjtwDir, ModuleInfo.Location, p.WikiMap, p.WikiMap[ModuleInfo.Name]['WikiPageNum']),
               Comment = CurRevisionComment
            }                                            
         end --if updating module on wiki
      end --if module in WikiMap
   end --module loop
   
   --map standalone HTML files to the wiki
   for PageName,PageInfo in pairs(p.WikiMap) do
      if PageInfo.FileName then --only standalone HTML files should have the FileName field
         --Look up CVS revision numbers and generate revision comment--             
         local CurRevisionComment = 'Generated from ' ..
         hjtw_wiki.RevisionComment(p.hjtwDir, PageInfo.FileName)
         
         local RequestSucceeded, WikiUpToDate = hjtw_wiki.GetWikiStatus(p, PageName, CurRevisionComment)
         
         local CurFile = io.open(p.hjtwDir .. '/' .. PageInfo.FileName, 'r')
         if not CurFile then            
            iguana.logError('File ' .. PageInfo.FileName .. ' not found.')
         else
            local WikiContent = CurFile:read('*all')
            
            --Only update wiki if the current version is newer  
            if not iguana.isTest() and RequestSucceeded and (not WikiUpToDate or p.ReplaceAll) then
               iguana.logInfo('Page ' .. PageName .. ' out of date on wiki. Updating wiki.')
               
               hjtw_wiki.UpdatePage{
                  Url = p.FogBugzURL,
                  Token = p.FogBugzToken,
                  PageNum = PageInfo.WikiPageNum,
                  Headline = hjtw_wiki.GetHeadline(p, PageName),
                  Content = hjtw_wiki.ReplaceModuleLinks(WikiContent, p.WikiMap),
                  Comment = CurRevisionComment
               }                                            
            end --if updating module on wiki
         end --if file found
      end --if standalone file
   end --module loop
   
   if not NoMapping then
      iguana.setChannelStatus{color='green', text=''}   
   end
   
   if p.DeleteFiles then
      hjtw.DeleteHelp(p.hjtwDir,'windows') 
   end
   
   iguana.logInfo('Finished wiki update.')
end

return hjtw_wiki