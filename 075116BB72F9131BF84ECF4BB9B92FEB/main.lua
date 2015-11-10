-- $Revision: 1.15 $
-- $Date: 2012-12-30 19:50:27 $

--Generate and upload wiki documentation pages on Translator modules based on JSON files
--More information at http://fogbugz.ifware.dynip.com/default.asp?W4755

require 'hjtw'
require 'hjtw_wiki'

function main()
   if not iguana.isTest() then
      iguana.setTimeout(600)
   end
   hjtw_wiki.WikiUpdate{
      -- WikiMap for QA
      WikiMap = {
         -- START LIVE MAPPINGS     
         -- Iguana functions
         -- NOTE: optional fields: "Title", "Subtitle"
         ['ack']={Subtitle = 'create and send ACK messages', WikiPageNum = 416},
         ['chm']={Subtitle = 'legacy Chameleon vmd parse',WikiPageNum = 430},
         
         -- both db pages under 1049 = MANUAL db header page
         ['db']={Subtitle = 'old style database functions', WikiPageNum = 431},
         ['db.db_connection']={Title = 'db conn', Subtitle = 'new database methods', WikiPageNum = 1034},
         
         -- filter sub-pages - under 577 MANUAL header page
         ['filter.aes']={Subtitle = 'encrypt and decrypt', WikiPageNum = 447},
         ['filter.base64']={Subtitle = 'encode and decode', WikiPageNum = 448},
         ['filter.bzip2']={Subtitle = 'zip and unzip', WikiPageNum = 449},
         ['filter.gzip']={Subtitle = 'zip and unzip', WikiPageNum = 578},
         ['filter.hex']={Subtitle = 'encode and decode', WikiPageNum = 450},
         ['filter.html']={Subtitle = 'encode', WikiPageNum = 451},
         ['filter.uri']={Subtitle = 'encode and decode', WikiPageNum = 437},
         ['filter.uuencoding']={Subtitle = 'encode and decode', WikiPageNum = 457},
         
         ['hl7']={Subtitle = 'working with HL7 2.x messages', WikiPageNum = 414},
         ['help']={Subtitle = 'customizing the Iguana help', WikiPageNum = 438},
         
         -- both iguana pages under 1050 = MANUAL iguana header page
         ['iguana']={Subtitle = 'helpful run-time utilities', WikiPageNum = 48},
         ['iguana.project']={Subtitle = 'project location, files and guid', WikiPageNum = 463},
         
         ['json']={Subtitle = 'working with JSON', WikiPageNum = 443},
         
         -- net sub-pages - under 456 MANUAL header page
         ['net.ftp']={Subtitle = 'using ftp file transfer', WikiPageNum = 1035},
         ['net.ftps']={Subtitle = 'using ftps file transfer', WikiPageNum = 1036},
         ['net.http']={Subtitle = 'using http connections', WikiPageNum = 1037},
         ['net.sftp']={Subtitle = 'using sftp file transfer', WikiPageNum = 1038},
         ['net.smtp']={Subtitle = 'sending mail', WikiPageNum = 1039},
         ['net.tcp']={Subtitle = 'using tcp socket connections', WikiPageNum = 1040},
         
         ['node']={Subtitle = 'working with messages in Node Tree format', WikiPageNum = 444},
         ['queue']={Subtitle = 'working with the Iguana message queue', WikiPageNum = 415},
         ['util']={Subtitle = 'utility script functions', WikiPageNum = 432},
         ['x12']={Subtitle = 'working with X12', WikiPageNum = 425},
         ['xml']={Subtitle = 'working with XML', WikiPageNum = 418},
         -- Lua functions
         ['coroutine']={Subtitle='not supported in Iguana (native Lua threading)', WikiPageNum = 453},
         ['debug']={Subtitle = 'debugging functions', WikiPageNum = 454},
         ['global']={Title='Global functions', Subtitle='print, pcall, require etc', WikiPageNum = 455},
         -- both io pages under 1041 = MANUAL io header page
         ['io']={Subtitle = 'file operations (also popen for running a process)', WikiPageNum = 1042},
         ['io.filehandle']={Subtitle = 'methods for the file object', WikiPageNum = 1043},
         ['math']={Subtitle = 'mathematical functions', WikiPageNum = 1044},
         
         -- all 3 os pages under 1019 = MANUAL os header page
         ['os']={Subtitle = 'general operating system utilities (including time)', WikiPageNum = 1046},
         ['os.fs']={Subtitle = 'file system operations', WikiPageNum = 1047},
         ['os.ts']={Subtitle = 'time related functions using Unix Epoch time', WikiPageNum = 1048},
         
         ['package']={Subtitle = 'package functions', WikiPageNum = 1051},
         ['string']={Subtitle = 'string operations', WikiPageNum = 1052},
         ['table']={Subtitle = 'table operations', WikiPageNum = 1053},
         
         -- manually created "overview" pages
         ['db_overview']={FileName = 'db_overview.html', Title = 'db', Subtitle = 'interacting with databases', WikiPageNum = 1049},
         ['filter_overview']={FileName = 'filter_overview.html', Title = 'filter', Subtitle = 'encoding, compression and encryption', WikiPageNum = 577},
         ['iguana_overview']={FileName = 'iguana_overview.html', Title = 'iguana', 
            Subtitle = 'interacting with Iguana\'s run-time system', WikiPageNum = 1050},
         ['net_overview']={FileName = 'net_overview.html', Title = 'net', 
            Subtitle = 'file transfer and email using the FTP, FTPS, HTTP, SFTP and SMTP message protocols', WikiPageNum = 456},
         ['io_overview']={FileName = 'io_overview.html', Title = 'io', Subtitle = 'file operations', WikiPageNum = 1041},
         ['os_overview']={FileName = 'os_overview.html', Title = 'os', Subtitle = 'operating system utilities', WikiPageNum = 1045},
         -- END LIVE MAPPINGS
         
--[=[    -- START QA MAPPINGS     
         -- Iguana functions
         -- NOTE: optional fields: "Title", "Subtitle"
         ['ack']={Subtitle = 'create and send ACK messages', WikiPageNum = 990},
         ['chm']={Subtitle = 'legacy Chameleon vmd parse',WikiPageNum = 991},
         -- both db pages under 1026 = MANUAL db header page
         ['db']={Subtitle = 'old style database functions', WikiPageNum = 950}, 
         ['db.db_connection']={Title = 'db conn', Subtitle = 'new database methods', WikiPageNum = 1027},
         -- # links for number in WikiPageNum needs to match [db] above
         ['db#connect']={Subtitle = 'old style database functions', WikiPageNum = '950#connect'}, -- number = ['db']
         ['filter.aes']={Subtitle = 'encrypt and decrypt', WikiPageNum = 1001}, 
         ['filter.base64']={Subtitle = 'encode and decode', WikiPageNum = 1002}, 
         ['filter.bzip2']={Subtitle = 'zip and unzip', WikiPageNum = 1003}, 
         ['filter.gzip']={Subtitle = 'zip and unzip', WikiPageNum = 1004}, 
         ['filter.hex']={Subtitle = 'encode and decode', WikiPageNum = 1005}, 
         ['filter.html']={Subtitle = 'encode', WikiPageNum = 1006}, 
         ['filter.uri']={Subtitle = 'encode and decode', WikiPageNum = 984}, 
         ['filter.uuencoding']={Subtitle = 'encode and decode', WikiPageNum = 985}, 
         ['hl7']={Subtitle = 'working with HL7 2.x messages', WikiPageNum = 993},
         ['help']={Subtitle = 'customizing the Iguana help', WikiPageNum = 1013},
         -- both iguana pages under 1030 = MANUAL iguana header page
         ['iguana']={Subtitle = 'helpful run-time utilities', WikiPageNum = 959},
         ['iguana.project']={Subtitle = 'project location, files and guid', WikiPageNum = 1031},
         ['json']={Subtitle = 'working with JSON', WikiPageNum = 994},
         ['net.ftp']={Subtitle = 'using ftp file transfer', WikiPageNum = 1007},
         ['net.ftps']={Subtitle = 'using ftps file transfer', WikiPageNum = 1008},
         ['net.http']={Subtitle = 'using http connections', WikiPageNum = 1009},
         ['net.sftp']={Subtitle = 'using sftp file transfer', WikiPageNum = 1010},
         ['net.smtp']={Subtitle = 'sending mail', WikiPageNum = 1011},
         ['net.tcp']={Subtitle = 'using tcp socket connections', WikiPageNum = 1012},
         ['node']={Subtitle = 'working with messages in Node Tree format', WikiPageNum = 996},
         ['queue']={Subtitle = 'working with the Iguana message queue', WikiPageNum = 997},
         ['util']={Subtitle = 'utility script functions', WikiPageNum = 998},
         ['x12']={Subtitle = 'working with X12', WikiPageNum = 999},
         ['xml']={Subtitle = 'working with XML', WikiPageNum = 1000},
         -- Lua functions
         ['coroutine']={Subtitle='not supported in Iguana (native Lua threading)', WikiPageNum = 1014},
         ['debug']={Subtitle = 'debugging functions', WikiPageNum = 1015},
         ['global']={Title='Global functions', Subtitle='print, pcall, require etc', WikiPageNum = 1016},
         -- both io pages under 1032 = MANUAL io header page
         ['io']={Subtitle = 'file operations (also popen for running a process)', WikiPageNum = 1017},
         ['io.filehandle']={Subtitle = 'methods for the file object', WikiPageNum = 1033},
         ['math']={Subtitle = 'mathematical functions', WikiPageNum = 1018},
         -- all 3 os pages under 1019 = MANUAL os header page
         ['os']={Subtitle = 'general operating system utilities (including time)', WikiPageNum = 1023},
         ['os.fs']={Subtitle = 'file system operations', WikiPageNum = 1024},
         ['os.ts']={Subtitle = 'time related functions using Unix Epoch time', WikiPageNum = 1025},
         ['package']={Subtitle = 'package functions', WikiPageNum = 1020},
         ['string']={Subtitle = 'string operations', WikiPageNum = 1021},
         ['table']={Subtitle = 'table operations', WikiPageNum = 1022},
         -- manually created "overview" pages
         ['db_overview']={FileName = 'db_overview.html', Title = 'db', Subtitle = 'interacting with databases', WikiPageNum = 1026},
         ['filter_overview']={FileName = 'filter_overview.html', Title = 'filter', Subtitle = 'encoding, compression and encryption', WikiPageNum = 992},
         ['iguana_overview']={FileName = 'iguana_overview.html', Title = 'iguana', 
            Subtitle = 'interacting with Iguana\'s run-time system', WikiPageNum = 1030},
         ['net_overview']={FileName = 'net_overview.html', Title = 'net', 
            Subtitle = 'file transfer and email using the FTP, FTPS, HTTP, SFTP and SMTP message protocols', WikiPageNum = 995},
         ['io_overview']={FileName = 'io_overview.html', Title = 'io', Subtitle = 'file operations', WikiPageNum = 1032},
         ['os_overview']={FileName = 'os_overview.html', Title = 'os', Subtitle = 'operating system utilities', WikiPageNum = 1019},
]=]      -- END QA MAPPINGS
      },   
      --HeadlineAppend is added to headline to avoid conflicts with other version of the same page:
      --HeadlineAppend = ' (QA)',
      --HeadlineAppend = ' (TEST)',
      DoNotMap = { --modules we don't care about mapping to the wiki - don't warn about them
      -- we probably want anything here in most cases
      ['cache']=false -- looks like this will be removed see ticket #21189
   },      
      --if ReplaceAll is true, replace everything in WikiMap on the wiki regardless of whether it is different:
      --useful if the mapping in this script has changed, but not the html/json files
      ReplaceAll = true,     
      --FogBugzURL = 'http://bnw.ifware.dynip.com/bnw/api.asp?',   ------------------------------------ PAGE DOES NOT EXIST ANY MORE...
      FogBugzURL = 'https://bnw.ifware.dynip.com/bnw/api.asp?',   ------------------------------------
      --            https://ifware.dynip.com/bnw/asp.asp
      --FogBugzToken must be for a full-power user of the BNW wiki:
      --e.g. generated with: FogBugzURL .. 'cmd=logon&email=USERNAME&password=PASSWORD'
      -- https://ifware.dynip.com/bnw/api.asp?cmd=logon&email=USERNAME&password=PASSWORD
      FogBugzToken = '31i7ibkhumn36u7geaq7rkf1v48r32', -- eliot I think
      -- FogBugzToken = 'qu5fnkaltjc9ln9pk85ochr26ca712',
      hjtwDir = 'hjtw',
      UpdateAllFiles = true, --delete/recreate hjtwDir fresh from CVS repository? ----------------------------------------
      DeleteFiles = false, --remove hjtwDir after script is done?     
      PrintWarnings = true, --print a file of potential issues?
      OnlyPrintWarnings = false, --only print that file, and send nothing to the wiki?
      -- Use "Tag" to checkout the currently released Branch = change to "'Iguana_6_Branch' when 6 is released
      Tag = 'Iguana_5_5_Branch', -- checkout a specific tag (nil or '' = no tag = HEAD)
      DoNotWarn = { --modules we don't want to print warnings for (at the moment)
         --hide some Iguana help files
         ['ack']=true,--------
         ['cache']=true,---------
         ['chm']=true,--------
         ['db']=true,---------
         ['help']=true,--------
         ['hl7']=true,--------
         ['iguana']=true,--------
         ['json']=true,---------
         ['node']=true,---------
         ['queue']=true,---------
         ['util']=true,---------
         ['x12']=true,---------
         ['xml']=true,---------
         ['filter.aes']=true,---------
         ['filter.base64']=true,---------
         ['filter.bzip2']=true,---------
         ['filter.gzip']=true,---------
         ['filter.hex']=true,---------
         ['filter.html']=true,---------
         ['filter.uri']=true,---------
         ['filter.uuencoding']=true,---------
         ['net.ftp']=true,---------
         ['net.ftps']=true,---------
         ['net.http']=true,---------
         ['net.sftp']=true,---------
         ['net.smtp']=true,---------
         ['net.tcp']=true,---------
         --hide some native Lua help files
         ['coroutine']=true, -- not supported in Iguana - no point updating
         ['debug']=true,   -- help not displaying - TRY NEWER BUILD???
         ['global']=true,  -- _G stuff
         ['io']=true,      -- displays
         ['math']=true,    -- displays
         ['os']=true,      -- displays
         ['package']=true, -- displays
         ['string']=true,  -- displays
         ['table']=true,   -- displays
      },      
   } 
end