---market.lua

local core = remote.interface.core
local addresses = require("ucp/modules/automarket/common/addresses").getUI(core)

local pBuyGoods = addresses.pBuyGoods
local pSellGoods = addresses.pSellGoods
local pAICState = addresses.pAICState

local AICState = ffi.cast("void *", pAICState)

---@type fun(aicState, playerID, resourceType, amount):boolean
local buyGoods = ffi.cast([[
  bool (__thiscall *)(
    void * this, // aicState
    int playerID,
    int resourceType,
    int amount
  )
]], pBuyGoods)

---@type fun(aicState, playerID, resourceType, amount):void
local sellGoods = ffi.cast([[
  void (__thiscall *)(
    void * this, // aicState
    int playerID,
    int resourceType,
    int amount
  )
]], pSellGoods)

-- 0x30d40 + 4d0

local pGameState = addresses.pGameState
local GameState = ffi.cast("void *", pGameState)
local _pResources0 = addresses._pResources0

local _pResources = ffi.new("int*[9]")
for i=0, 8 do
  _pResources[i] = ffi.cast("int*", _pResources0 + (i * 0x39f4))
end

local _pMarketBuildingID = addresses._pMarketBuildingID
local _pMarketBuildings = ffi.new("int*[9]")
for i=0, 8 do
  _pMarketBuildings[i] = ffi.cast("int*", _pMarketBuildingID + (i * 0x39f4))
end



local pGetBuyPrice = addresses.pGetBuyPrice

---@type fun(gameState, playerID, resourceType, amount):integer
local getBuyPrice = ffi.cast([[
  int (__thiscall *)(
    void * this, // game state
    int playerID, // unused actually
    int resourceType,
    int amount
  )
]], pGetBuyPrice)

local pGetSellPrice = addresses.pGetSellPrice
---@type fun(gameState, playerID, resourceType, amount):integer
local getSellPrice = ffi.cast([[
  int (__thiscall *)(
    void * this, // game state
    int playerID, // unused actually
    int resourceType,
    int amount
  )
]], pGetSellPrice)

local pUnitsState = addresses.pUnitsState
local UnitsState = ffi.cast("void *", pUnitsState)
local getAliveLordForPlayer = ffi.cast([[
  int (__thiscall *)(
    void * this, // units state
    int playerID
  )
]], addresses.getAliveLordForPlayer)

local pCurrentPlayer = addresses.pCurrentPlayer

return {
  buyGoods = buyGoods,
  sellGoods = sellGoods,
  playerResources = _pResources,
  pPlayerID = ffi.cast("int *", pCurrentPlayer),
  AICState = AICState,
  getBuyPrice = getBuyPrice,
  getSellPrice = getSellPrice,
  GameState = GameState,
  marketBuildings = _pMarketBuildings,
  UnitsState = UnitsState,
  getAliveLordForPlayer = getAliveLordForPlayer,
}