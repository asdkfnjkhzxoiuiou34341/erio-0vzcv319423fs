local captured=nil
local oldload=load
local oldloadstring=loadstring or load
function loadstring(src, chunk)
  captured=src
  return oldloadstring("return nil", chunk)
end
_G.load=function(src, chunk,...)
  captured=src
  return oldload(src, chunk,...)
end
-- Execute protected file
local f=assert(loadfile('eblan'))
pcall(f)
if captured then
  local outfile='eblan_decoded2.lua'
  local file=io.open(outfile,'w')
  file:write(captured)
  file:close()
  print('Captured to '..outfile)
else
  print('Nothing captured')
end
