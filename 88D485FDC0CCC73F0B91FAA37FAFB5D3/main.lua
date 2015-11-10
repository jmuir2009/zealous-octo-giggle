require("node")

URL = 'http://example.interfaceware.com:6544/current_time'

function main()
   -- get data from web service
   local R = net.http.get{url=URL,
      auth={username='admin', password='password'}, 
      live=true}
   
   -- parse and extract data
   local X = xml.parse{data=R}
   
   -- process the data
   local Year = X.time.now:nodeValue():sub(1,4)
   local Month = X.time.now:nodeValue():sub(6,8)
   local Day = X.time.now:nodeValue():sub(10,12)

   -- push the results to the queue
   queue.push(Year)
   queue.push(Month)
   queue.push(Day)
end