local addresses = require("ucp/modules/automarket/common/addresses").getUI(remote.interface.core)
local pTradeAbilityArray = addresses.pTradeAbilityArray

return {
    tradeablility = ffi.cast("int *", pTradeAbilityArray)
}