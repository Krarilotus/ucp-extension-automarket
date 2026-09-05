local ffi = ffi
if remote == nil then
  ffi = modules.cffi:cffi()  
end

local sizes = {}

local function loadHeaders()
  ffi.cdef([[

  // This info should be in lockstep
typedef struct AutoMarketPlayerData {
  bool enabled;
  int goldReserve;
  bool buyEnabled[25];
  bool sellEnabled[25];
  int buyValues[25];
  int sellValues[25];
} AutoMarketPlayerData;

typedef struct AutoMarketPlayerCredit {
  int credit;
} AutoMarketPlayerCredit;

typedef struct AutoMarketDataHeader {
  int version;
} AutoMarketDataHeader;

// This info should be saved
typedef struct AutoMarketDataV1 {
  AutoMarketDataHeader header;
  AutoMarketPlayerData playerSettings[9];
  AutoMarketPlayerCredit playerCredit[9];
} AutoMarketDataV1;

typedef struct AutoMarketData {
  AutoMarketDataHeader header;
  AutoMarketPlayerData playerSettings[9];
  AutoMarketPlayerCredit playerCredit[9];
  int marketFees[9]; // committed with each player's settings; -1 needs confirmation
} AutoMarketData;

  ]])

  -- 260
  sizes["AutoMarketPlayerData"] = ffi.sizeof("AutoMarketPlayerData")
  -- 
  sizes["AutoMarketPlayerCredit"] = ffi.sizeof("AutoMarketPlayerCredit")
  sizes["AutoMarketDataV1"] = ffi.sizeof("AutoMarketDataV1")
  -- 2416
  sizes["AutoMarketData"] = ffi.sizeof("AutoMarketData")

  -- 4
  sizes["AutoMarketDataHeader"] = ffi.sizeof("AutoMarketDataHeader")

  for k, v in pairs(sizes) do
    log(VERBOSE, string.format("sizeof: %s = %d", k, v))
  end
end

return {
  loadHeaders = loadHeaders,
  sizes = sizes,
}