-- Utilities for "node" Values

-- Coerce a node value into a string.
--

function node.S(ANode)
   return tostring(ANode)
end

function node.setMinFields(seg, n)
   if seg[n]:isLeaf() then
      if seg[n]:isNull() then seg[n]='' end
   else
      -- recurse through tree
      node.setMinFields(seg[n], 1)
   end
end

local function isLeafTest(n)
   --any node.f() to raise an error
   --n[1]:nodeName() -- also works
   n[1]:nodeType()
end

function node.isLeaf(n)
   --isLeafTest(n) -- test isLeafTest()
   return not pcall(isLeafTest, n)
end

