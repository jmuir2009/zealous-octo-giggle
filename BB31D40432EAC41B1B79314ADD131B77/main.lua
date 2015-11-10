-- change the locations of the VMD and DB files as required
-- in this case (no path specified) the path defaults to the Iguana install directory
SQLITE_DB='test'
-- Note: the vmd must be in XML format
VMD_FILE='edit/admin/other/example/demo.vmd' 

-- this will create the database file if it does not exist
conn = db.connect{
   api=db.SQLITE,
   name=SQLITE_DB,
   live=true
}

function main(Data)
   -- create tables and then read from master file to show tables exist
   CreateVMDTables()
   conn:query('SELECT * FROM sqlite_master')
end

-- read VMD and create SQLite table creation script
-- note: the SQL create is ***SQLite*specific***
function CreateVMDTables()
   io.input(VMD_FILE)
   vmd=io.read("*all")
   X=xml.parse{data=vmd}
   trace(X.engine.config:child('table',1):child('column',1).config.is_key[1]:nodeValue())
   
   for i=1,X.engine.global:childCount('table') do
      local Sql=''
      Sql=Sql..'CREATE TABLE IF NOT EXISTS '
      Sql=Sql..X.engine.global:child('table',i).name:nodeValue()
      Sql=Sql..'\n(\n'
      for j=1,X.engine.global:child('table',i):childCount('column') do
         Sql=Sql..X.engine.global:child('table',i):child('column',j).name:nodeValue()
         -- if primary key
         if X.engine.config:child('table',i):child('column',j).config.is_key[1]:nodeValue()=='True' then
            Sql=Sql..' TEXT(255) NOT NULL PRIMARY KEY'
         else
            Sql=Sql..' TEXT(255) NULL'
         end
         -- last field
         if j~=X.engine.global:child('table',i):childCount('column') then
            Sql=Sql..',\n'
         end
      end
      Sql=Sql..'\n);\n\n'
      trace(Sql)
      conn:execute{sql=Sql,live=true}
   end
   
end

function node.S(ANode)
   return tostring(ANode)
end