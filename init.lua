

---@type CFFIInterface
local ffi = modules.cffi:cffi()
local automarket = {}

local common = require("common")
local feeConfig = require("common.fees")
local savedata = require("common.savedata")
local configuredFee = 0
local native = require("common.addresses")
local addresses
common.loadHeaders()
local autoMarketPlayerDataSize = common.sizes["AutoMarketPlayerData"]
-- Four bytes for the player ID, settings, then four bytes for the fee.
-- protocol adds its own four-byte discriminator to this body.
local commitParameterSize = 4 + autoMarketPlayerDataSize + 4
assert(4 + commitParameterSize <= 1260, "Automarket settings exceed the lockstep payload limit")
local autoMarketDataSize = common.sizes["AutoMarketData"]
local autoMarketDataHeaderSize = common.sizes["AutoMarketDataHeader"]

local automarketData, pAutomarketData, pAutomarketPlayerSettings

local automarketProtocolNumber = -1
local automarketProtocolKey = ""

local function getControllingPlayerID()
  return core.readInteger(addresses.pPlayerID)
end

local function getInvoker()
  return core.readInteger(addresses.pProtocolInvokerPlayerID)
end

---@type Handler
local automarketProtocolHandler = {
  schedule = function(self, meta, context)
    log(VERBOSE, string.format("scheduling automarket protocol for comitting data for player: %s", 1))
    meta.parameters:serializeInteger(getControllingPlayerID())
    -- 0th element is the UI state
    meta.parameters:serializeBytes(core.readBytes(pAutomarketPlayerSettings + 0, autoMarketPlayerDataSize))
    meta.parameters:serializeInteger(configuredFee)
  end,
  scheduleAfterReceive = function(self, meta)
    
  end,
  execute = function(self, meta)
    local playerID = meta.parameters:deserializeInteger()
    local realPlayer = getInvoker()

    if realPlayer < 1 or realPlayer > 8 or playerID ~= realPlayer then
      log(WARNING, string.format("player %s may be cheating by trying to set the automarket of player %s", realPlayer, playerID))
      return
    end

    local data = meta.parameters:deserializeBytes(autoMarketPlayerDataSize)
    local fee = meta.parameters:deserializeInteger()
    if not feeConfig.isValid(fee) then
      log(WARNING, "ignoring automarket settings with an invalid market fee")
      return
    end
    log(VERBOSE, string.format("executing automarket protocol for comitting data for player: %s", realPlayer))
    core.writeBytes(pAutomarketPlayerSettings + (realPlayer * autoMarketPlayerDataSize), data)
    automarketData.marketFees[realPlayer] = fee

    if realPlayer == getControllingPlayerID() then 
      -- If this data is for us, also update UI slot
      core.writeBytes(pAutomarketPlayerSettings + 0, data)
    end
  end
}

local automarketInterface = {
  initialize = function(self)
    ---@type Module_UI
    local ui = modules.ui
    self.automarket = ui:createMenuFromFile("ucp/modules/automarket/ui/automarket.lua", true, true)
    if type(self.automarket) ~= "table" then error("menu failed to load", 0) end
    if self.automarket.bindingError then error(self.automarket.bindingError, 0) end
    -- unnecessary cast?
    -- self.automarket.triggerItem.menuItemRenderFunction.simple = ffi.cast("void (__cdecl *)(int)", self.automarket.triggerItem.menuItemRenderFunction.simple)
    -- self.automarket.triggerItem.menuItemActionHandler.simple = ffi.cast("void (__cdecl *)(int)", self.automarket.triggerItem.menuItemActionHandler.simple)
  end,

  setCallbacks = function(self, callbacks)
    ---@type Module_UI
    local ui = modules.ui
    ui:registerEventHandler("automarket/ui/data/save", function(key, obj)
      log(VERBOSE, string.format("save called!"))
      callbacks.commitData()
    end)

    log(VERBOSE, string.format("setCallbacks: received pointer: %X", self.automarket.pAutoMarketData))
    callbacks.setPointer(self.automarket.pAutoMarketData)

    log(VERBOSE, string.format("setCallbacks: setting hook to callback: %X", self.automarket.pCallback))
    callbacks.allocateMarketProcess(self.automarket.pCallback)
  end,
}

function automarket:enable(config)
  configuredFee = feeConfig.fromConfig(config)
  local settings = type(config) == "table" and config.ui
  local sliders = type(settings) == "table" and settings.buySellSliders
  local wheel = type(sliders) == "table" and sliders.scrollWheel
  local invert = type(wheel) == "table" and wheel.invert
  if invert ~= nil and type(invert) ~= "boolean" then
    log(ERROR, "Automarket scroll-wheel inversion must be a boolean")
  end

  local automarketUI = automarketInterface
  local ready, reason = pcall(function()
    addresses = native.resolve(core)
    automarketUI:initialize()
    addresses.pPlayerID = assert(automarketUI.automarket.pPlayerID, "controlling player binding unavailable")
    addresses.stockpile = assert(automarketUI.automarket.stockpile, "stockpile menu binding unavailable")
  end)
  if not ready then
    log(ERROR, "Automarket is off: " .. tostring(reason))
    return
  end

  modules.ui:sendEvent("automarket/config/update", {fee = configuredFee, invertScrollWheel = invert == true})

  local visuals, displaySite, ownerOffset = pcall(native.resolveVisuals, core)
  if not visuals then log(ERROR, "Automarket marketplace indicator is off: " .. tostring(displaySite)) end

  ---@type protocol
  local p = modules.protocol
  automarketProtocolNumber, automarketProtocolKey = p:registerCustomProtocol('automarket', 'commitSingle', 'LOCKSTEP', commitParameterSize, automarketProtocolHandler)

  automarketUI:setCallbacks({
    setPointer = function(pointer)
      self.automarketData = ffi.cast("AutoMarketData *", pointer)
      self.pAutomarketData = pointer
      automarketData = self.automarketData
      pAutomarketData = self.pAutomarketData
      pAutomarketPlayerSettings = ffi.tonumber(ffi.cast("unsigned long", self.automarketData.playerSettings))
      if pAutomarketPlayerSettings == nil then error("pAutomarketPlayerSettings is nil!") end
    end,
    commitData = function()
      log(DEBUG, "do the commit!")
      p:invokeProtocol(automarketProtocolNumber)
    end,
    allocateMarketProcess = function(pointer)
      
      local asm = core.AssemblyLambda([[
          cmp dword [pWeekChanged], 0
          je finish
          push eax
          push ecx
          push edx
          call callback
          pop edx
          pop ecx
          pop eax

        finish:
          ; end of script
      ]], {
        pWeekChanged = addresses.pWeekChanged,
        callback = pointer,
      })
      local detourTarget = addresses.marketTick
      log(VERBOSE, string.format("allocateMarketProcess: inserting code at 0x%X pointing to 0x%X", detourTarget, pointer))
      core.insertCode(detourTarget, 5, {asm}, nil, "after")

    end,
  })

  local function installMenuHooks()
    log(VERBOSE, "setting trigger item")
    local menu = modules.ui:access().api.ui.Menu:fromID(0x10)
    -- log(VERBOSE, "loading ui access")
    -- local access = modules.ui:access()
    -- log(VERBOSE, "getting Menu handle from ID 0x10")
    -- local menu = access.api.ui.Menu:fromID(0x10)
    _G[menu] = true
    -- menu:reallocateMenuItems()
    -- TODO: fails:
    log(VERBOSE, string.format('inserting trigger button in market panel: %s', automarketUI.automarket.triggerItem))
    local insertionPoints = {
      {
        tab = 138,
        location = 144,
      },
      {
        tab = 144,
        location = 147,
      },
      {
        tab = 147,
        location = 150,
      },
      {
        tab =  159,
        location =  162,
      },
      {
        tab = 171,
        location = 174,
      },
      {
        tab = 179,
        location = 182,
      },
    }
    for i=#insertionPoints,1,-1 do
      local insertionPoint = insertionPoints[i]
      log(VERBOSE, string.format("inserting trigger item into tab: 0x%X", insertionPoint.tab))
      menu:insertMenuItem(insertionPoint.location, automarketUI.automarket.triggerItem)
      menu.menuItems[insertionPoint.tab].firstItemTypeData.itemsToSkip = menu.menuItems[insertionPoint.tab].firstItemTypeData.itemsToSkip + 1
    end
    


    -- TODO: write the trigger item callback logic
    local hookLocationStockpile, hookSizeStockpile = addresses.stockpile, 7
    core.insertCode(hookLocationStockpile, hookSizeStockpile, {
      core.AssemblyLambda([[
        call f
      ]], {
        f = automarketUI.automarket.renderAndHandleInOne
      })
    }, nil, "after")

    local hookLocationArmory, hookSizeArmory = addresses.armory, 7
    core.insertCode(hookLocationArmory, hookSizeArmory, {
      core.AssemblyLambda([[
        call f
      ]], {
        f = automarketUI.automarket.renderAndHandleInOne
      })
    }, nil, "after")

    if not visuals then return end
    local rawPEnabledArray = core.allocate(4 * 9, true)
    local pEnabledArray = ffi.cast("bool **", rawPEnabledArray)
    local s = pAutomarketData + common.sizes["AutoMarketDataHeader"]
    for i=0,8 do
      pEnabledArray[i] = ffi.cast("bool *", s)
      s = s + common.sizes["AutoMarketPlayerData"]
    end

    --- improved visuals of the marketplace
    core.insertCode(displaySite, 7, {
      core.AssemblyLambda([[
        mov ECX, ESI
        add ECX, ownerOffset
        movzx ecx, word [ecx]
        mov ecx, dword [pEnabledArray + 4*ECX]
        cmp byte [ecx], 1
      ]], {
        pEnabledArray = ffi.tonumber(ffi.cast("unsigned long", pEnabledArray)),
        ownerOffset = ownerOffset,
      })
    }, nil, "before")
  end
  hooks.registerHookCallback('afterInit', function()
    local ok, err = pcall(installMenuHooks)
    if not ok then log(ERROR, "Automarket menu integration failed: " .. tostring(err)) end
  end)

  local mapdatapath = "automarketplayerdata.bin"

  ---@type SerializationCallbacks
  local callbacks = {

    initialize = function(self)
      local pAutoMarketData = automarketUI.automarket.pAutoMarketData
      local offset = pAutoMarketData + common.sizes.AutoMarketDataHeader
      
      -- todo: improve by setting a default setting for everyone
      -- wipe memory except the version information
      local len = autoMarketDataSize - common.sizes.AutoMarketDataHeader
      log(DEBUG, string.format("wiping automarket data because none was found: 0x%X (len: %d)", offset, len))
      core.setMemory(offset, 0, len)
      log(DEBUG, string.format("wiped"))
    end,

    ---@param handle WriteHandle
    serialize = function(self, handle)
      handle:put(mapdatapath, core.readString(pAutomarketData, autoMarketDataSize))
    end,

    ---@param handle ReadHandle
    deserialize = function(self, handle)
      local bytes = {}
      if handle:exists(mapdatapath) then
        local contents = handle:get(mapdatapath)
        for i = 1, #contents do bytes[i] = string.byte(contents, i) end
      end
      local restored = savedata.restore(automarketData, bytes, common,
        function(data) core.writeBytes(pAutomarketData, data) end,
        function(offset, size) core.setMemory(pAutomarketData + offset, 0, size) end)
      if not restored then log(WARNING, "no compatible automarket save data; settings reset") end

    end
  }

  ---@type mapextensions
  local m = modules['map-extensions']
  m:registerSection('automarket', callbacks)
  

  
end

function automarket:disable()
end


return automarket