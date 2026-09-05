-- Version 1 did not save fees. Preserve its settings and credit, but require a
-- synchronized settings commit before trading instead of guessing a local fee.
local function restore(data, bytes, common, writeBytes, clear)
  local headerSize = common.sizes.AutoMarketDataHeader
  local size = common.sizes.AutoMarketData
  local legacySize = common.sizes.AutoMarketDataV1
  local version = #bytes >= 4 and (bytes[1] + bytes[2] * 256 + bytes[3] * 65536 + bytes[4] * 16777216) or -1
  local valid = (version == 1 and #bytes == legacySize) or (version == 2 and #bytes == size)
  clear(headerSize, size - headerSize)
  if valid then writeBytes(bytes) end
  data.header.version = 2
  if version == 1 and valid then
    for player = 0, 8 do data.marketFees[player] = -1 end
  end
  return valid
end

return {restore = restore}
