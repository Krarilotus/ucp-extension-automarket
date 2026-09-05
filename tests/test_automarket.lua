ffi = require('ffi')
log = function() end
local function equal(actual, expected, label)
  assert(actual == expected, (label or '') .. ': expected ' .. tostring(expected) .. ', got ' .. tostring(actual))
end
local function preload(name, file)
  package.preload[name] = function() return dofile(file) end
end
preload('common', 'common/init.lua')
preload('common.fees', 'common/fees.lua')
preload('common.savedata', 'common/savedata.lua')
preload('ucp/modules/automarket/ui/market/fees', 'ui/market/fees.lua')
package.preload['common.addresses'] = function() return {pPlayerID=1,pProtocolInvokerPlayerID=2} end
local registered
modules = {
  cffi = {cffi=function() return ffi end},
  protocol = {registerCustomProtocol=function(_, extension, name, kind, size, handler)
    registered={size=size,handler=handler}; return 131, name
  end},
  ui = {createMenuFromFile=function() error('STOP_BEFORE_NATIVE_UI') end},
}
local controlling, invoker = 1, 1
core = {readInteger=function(a) return a == 1 and controlling or invoker end}
local extension = dofile('init.lua')
local ok, err = pcall(extension.enable, extension, {logic={marketFee={enabled=true,sliderValue=5}}})
assert(not ok and err:find('STOP_BEFORE_NATIVE_UI'))
local common = require('common')
equal(common.sizes.AutoMarketPlayerData,260,'player layout')
equal(common.sizes.AutoMarketDataV1,2380,'legacy save layout')
equal(common.sizes.AutoMarketData,2416,'save layout')
equal(registered.size+4,272,'total lockstep payload')
assert(registered.size+4 <= 1260)
local data=ffi.new('AutoMarketData')
local writes=0
core.readBytes=function(_,size) local bytes={};for i=1,size do bytes[i]=0 end;return bytes end
core.writeBytes=function() writes=writes+1 end
local function upvalue(fn, name, value)
  for i=1,30 do
    local key=debug.getupvalue(fn,i)
    if key==name then debug.setupvalue(fn,i,value);return end
  end
  error('Missing upvalue '..name)
end
upvalue(registered.handler.schedule,'pAutomarketPlayerSettings',10000)
upvalue(registered.handler.execute,'automarketData',data)
local payload={}
local params={
  serializeInteger=function(_,value)
    for i=1,4 do payload[#payload+1]=value%256;value=math.floor(value/256) end
  end,
  serializeBytes=function(_,bytes) for _,v in ipairs(bytes) do payload[#payload+1]=v end end,
}
registered.handler.schedule(nil,{parameters=params})
equal(#payload,registered.size,'actual serialized length')
equal(payload[#payload-3],5,'fee transmitted')
local nextInt=0
params.deserializeInteger=function() nextInt=nextInt+1;return nextInt==1 and controlling or 5 end
params.deserializeBytes=function(_,size) return core.readBytes(0,size) end
registered.handler.execute(nil,{parameters=params})
equal(data.marketFees[1],5,'received fee applied')
equal(writes,2,'owner and UI writes')
for _,badInvoker in ipairs({0,9,-1,2}) do
  invoker=badInvoker;nextInt=0
  registered.handler.execute(nil,{parameters=params})
  equal(writes,2,'invalid sender cannot write')
end
invoker=1;nextInt=0
params.deserializeInteger=function() nextInt=nextInt+1;return nextInt==1 and 1 or 101 end
registered.handler.execute(nil,{parameters=params})
equal(writes,2,'invalid fee cannot write')

local process=dofile('ui/market/process.lua')
local function setup(fee)
  local state=ffi.new('AutoMarketData')
  state.playerSettings[1].enabled=true
  state.marketFees[1]=fee
  local market={GameState={},AICState={},UnitsState={},marketBuildings={},playerResources={}}
  for p=1,8 do market.marketBuildings[p]={[0]=1};market.playerResources[p]=ffi.new('int[25]') end
  market.getAliveLordForPlayer=function(_,p) return p==1 and 1 or 0 end
  market.getBuyPrice=function(_,p,g,n) return 4*n end
  market.getSellPrice=function(_,p,g,n) return 4*n end
  market.buyCalls=0
  market.buyGoods=function(_,p,g,n)
    market.buyCalls=market.buyCalls+1
    if market.full then return false end
    market.playerResources[p][15]=market.playerResources[p][15]-4*n
    market.playerResources[p][g]=market.playerResources[p][g]+n
    return true
  end
  market.sellGoods=function(_,p,g,n)
    market.playerResources[p][15]=market.playerResources[p][15]+4*n
    market.playerResources[p][g]=market.playerResources[p][g]-n
  end
  return state,market
end
local function tick(s,m) process(s,m,{2,4},{[2]=1,[4]=1}) end
local s,m=setup(5)
s.playerSettings[1].buyEnabled[2]=true;s.playerSettings[1].buyValues[2]=1
for i=1,5 do tick(s,m) end
equal(s.playerCredit[1].credit,0,'unaffordable attempts keep credit')
equal(m.buyCalls,0,'unaffordable attempts do not buy')
m.playerResources[1][15]=105;s.playerSettings[1].goldReserve=100
tick(s,m)
equal(m.playerResources[1][15],100,'exact funds buy while preserving reserve')
equal(s.playerCredit[1].credit,80,'successful purchase earns credit')
m.full=true;m.playerResources[1][2]=0;m.playerResources[1][15]=110
tick(s,m)
equal(s.playerCredit[1].credit,80,'storage failure keeps credit')
equal(m.playerResources[1][15],110,'storage failure keeps gold')
m.full=false;m.playerResources[1][15]=104
tick(s,m)
equal(m.playerResources[1][15],100,'pending refund counts toward affordability')
equal(s.playerCredit[1].credit,60,'successful refund settlement')

s,m=setup(5);s.playerSettings[1].sellEnabled[2]=true
for i=1,5 do m.playerResources[1][2]=1;tick(s,m) end
equal(m.playerResources[1][15],19,'five sales after 5 percent fee')
equal(s.playerCredit[1].credit,0,'exact 100 credit paid immediately')
-- Check cumulative sale proceeds against the exact economic value, across all
-- fee settings, rather than duplicating the implementation's rounding steps.
for fee=0,100 do
  s,m=setup(fee);s.playerSettings[1].sellEnabled[2]=true
  local sold=0
  for amount=1,25 do
    m.playerResources[1][2]=amount;sold=sold+amount;tick(s,m)
    equal(m.playerResources[1][15]*100+s.playerCredit[1].credit,
      sold*4*(100-fee),'cumulative proceeds and credit conserve value')
    assert(s.playerCredit[1].credit>=0 and s.playerCredit[1].credit<100)
  end
end
for _,fee in ipairs({0,100}) do
  s,m=setup(fee);s.playerSettings[1].buyEnabled[2]=true;s.playerSettings[1].buyValues[2]=1
  m.playerResources[1][15]=4*(100+fee)/100
  tick(s,m);equal(m.playerResources[1][15],0,'fee endpoint exact purchase')
end
-- Peers have different UI preferences but the same committed fee/state.
local a,ma=setup(5);local b,mb=setup(5)
a.playerSettings[1].buyEnabled[2]=true;b.playerSettings[1].buyEnabled[2]=true
a.playerSettings[1].buyValues[2]=1;b.playerSettings[1].buyValues[2]=1
ma.playerResources[1][15]=100;mb.playerResources[1][15]=100
SETTINGS={logic={marketFee={enabled=false,value=0}}};tick(a,ma)
SETTINGS.logic.marketFee={enabled=true,value=99};tick(b,mb)
equal(ma.playerResources[1][15],mb.playerResources[1][15],'local fee preferences cannot desync trades')
equal(a.playerCredit[1].credit,b.playerCredit[1].credit,'peer credits agree')

local savedata=require('common.savedata')
local function asBytes(ptr,size)
  local bytes={};local raw=ffi.cast('unsigned char*',ptr)
  for i=0,size-1 do bytes[i+1]=tonumber(raw[i]) end
  return bytes
end
local function restore(bytes)
  local target=ffi.new('AutoMarketData')
  local raw=ffi.cast('unsigned char*',target)
  local valid=savedata.restore(target,bytes,common,
    function(values) for i,v in ipairs(values) do raw[i-1]=v end end,
    function(offset,size) ffi.fill(raw+offset,size) end)
  return target,valid
end
a.header.version=2
local loaded,valid=restore(asBytes(a,common.sizes.AutoMarketData))
assert(valid);equal(loaded.marketFees[1],5,'saved committed fee survives load')
equal(loaded.playerCredit[1].credit,a.playerCredit[1].credit,'saved credit survives load')
local legacy=ffi.new('AutoMarketDataV1');legacy.header.version=1
legacy.playerSettings[1].enabled=true;legacy.playerSettings[1].buyEnabled[2]=true
legacy.playerSettings[1].buyValues[2]=1;legacy.playerCredit[1].credit=80
loaded,valid=restore(asBytes(legacy,common.sizes.AutoMarketDataV1))
assert(valid);equal(loaded.header.version,2,'legacy version upgraded')
equal(loaded.playerSettings[1].buyValues[2],1,'legacy thresholds retained')
equal(loaded.playerCredit[1].credit,80,'legacy credit retained')
equal(loaded.marketFees[1],-1,'legacy fees require synchronized confirmation')
local _,mm=setup(5);mm.playerResources[1][15]=100;tick(loaded,mm)
equal(mm.buyCalls,0,'legacy state cannot trade with a local-only fee')
for _,bytes in ipairs({{}, {2,0,0,0}, {3,0,0,0}}) do
  loaded,valid=restore(bytes);assert(not valid)
  equal(loaded.playerSettings[1].enabled,false,'invalid saves reset settings')
end
print('PASS: packet size, sender/fee validation, trade accounting, peer determinism, and save migration')
