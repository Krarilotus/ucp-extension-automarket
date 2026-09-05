local function isValid(value)
  return type(value) == "number" and value == math.floor(value) and value >= 0 and value <= 100
end

local function fromConfig(config)
  local fee = config and config.logic and config.logic.marketFee
  if not fee or not fee.enabled then return 0 end
  if not isValid(fee.sliderValue) then error("Automarket market fee must be an integer from 0 to 100") end
  return fee.sliderValue
end

return {isValid = isValid, fromConfig = fromConfig}
