local function bind(core, name, pattern)
  local site, reason = core.AOBScanUnique(pattern)
  assert(site, name .. ": " .. (reason or "binding unavailable"))
  return site
end

local function relativeCall(core, site)
  return site + 5 + core.readInteger(site + 1)
end

local function resolve(core)
  return {
    pProtocolInvokerPlayerID = core.readInteger(bind(core, "protocol player", "A1 ? ? ? ? 8D 48 FF 83 F9 07 77 0D") + 1),
    pWeekChanged = core.readInteger(bind(core, "week change flag", "39 ? ? ? ? ? 0F ? ? ? ? ? B9 ? ? ? ? E8 ? ? ? ? 85 C0 0F ? ? ? ? ? A1 ? ? ? ?") + 2),
    marketTick = bind(core, "market tick", "BF 01 00 00 00 8D B1 ? ? ? ? BD D0 07 00 00"),
    armory = bind(core, "armory menu", "51 8B ? ? ? ? ? A1 ? ? ? ? 53 55 56 57 33 FF 57 57 6A 10 57 57"),
  }
end

local function resolveVisuals(core)
  local site = bind(core, "marketplace display", "83 ? ? ? ? ? ? 66 ? ? ? ? ? ? BF 01 00 00 00")
  local owner = bind(core, "marketplace owner", "0F ? ? ? ? ? ? 8B 5C 24 34 8B ? ? ? ? ? ?")
  return site, core.readInteger(owner + 3)
end

local uiBindings
local function getUI(core)
  if uiBindings then return uiBindings end
  local stockpile = bind(core, "stockpile menu", "51 8B ? ? ? ? ? A1 ? ? ? ? 53 55 56 57 33 FF 57 57 6A 10 57 8D 91 00 02 00 00")
  uiBindings = {
    stockpile = stockpile,
    pBuyGoods = bind(core, "pBuyGoods", "53 8B 5C 24 10 55 8B 6C 24 10 56 8B 74 24 10"),
    pSellGoods = bind(core, "pSellGoods", "53 8B 5C 24 0C 56 8B 74 24 0C 57"),
    pAICState = core.readInteger(bind(core, "pAICState", "B9 ? ? ? ? E8 ? ? ? ? 8B ? ? ? ? ? 52 B9 ? ? ? ? E8 ? ? ? ? 8B ? ? ? ? ? 8B ? ? ? ? ? 69 C9 2C 03 00 00") + 1),
    pGameState = core.readInteger(bind(core, "pGameState", "B9 ? ? ? ? E8 ? ? ? ? 8B F3 69 F6 F4 39 00 00 8B ? ? ? ? ? 8B ? ? ? ? ?") + 1),
    _pResources0 = core.readInteger(bind(core, "_pResources0", "89 ? ? ? ? ? ? 83 C0 01 83 F8 19") + 3),
    _pMarketBuildingID = core.readInteger(bind(core, "_pMarketBuildingID", "83 ? ? ? ? ? ? B8 01 00 00 00 75 16") + 2),
    pGetBuyPrice = relativeCall(core, bind(core, "pGetBuyPrice", "E8 ? ? ? ? 39 ? ? ? ? ? 8B 4C 24 10")),
    pGetSellPrice = relativeCall(core, bind(core, "pGetSellPrice", "E8 ? ? ? ? 01 03 5D")),
    pUnitsState = core.readInteger(bind(core, "pUnitsState", "8B ? ? ? ? ? B8 01 00 00 00 3B D0 7E 3A") + 2),
    pCurrentPlayer = core.readInteger(bind(core, "pCurrentPlayer", "A1 ? ? ? ? 53 55 56 8B E9") + 1),
    getAliveLordForPlayer = bind(core, "getAliveLordForPlayer", "8B 11 B8 01 00 00 00 3B D0 55"),
    pLeftClickStart = core.readInteger(bind(core, "pLeftClickStart", "83 ? ? ? ? ? ? 0F ? ? ? ? ? 8B ? ? ? ? ? 8B ? ? ? ? ? 8D 44 0A FF") + 2),
    pMenuHandlerStateXY = core.readInteger(stockpile + 8),
    pTradeAbilityArray = core.readInteger(bind(core, "pTradeAbilityArray", "89 ? ? ? ? ? 83 C0 08 83 C1 04 83 C6 04") + 2),
  }
  return uiBindings
end

return {resolve = resolve, resolveVisuals = resolveVisuals, getUI = getUI}
