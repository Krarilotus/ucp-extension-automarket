local function isValid(value)
  return type(value) == "number" and value == math.floor(value) and value >= 0 and value <= 100
end

local function fromConfig(config)
  if config ~= nil and type(config) ~= "table" then
    log(ERROR, "Automarket settings must be a table; the market fee is off")
    return 0
  end
  local logic = config and config.logic
  if logic == nil then return 0 end
  if type(logic) ~= "table" then
    log(ERROR, "Automarket logic settings must be a table; the market fee is off")
    return 0
  end
  local fee = logic.marketFee
  if fee == nil then return 0 end
  if type(fee) ~= "table" then
    log(ERROR, "Automarket market fee settings must be a table; the fee is off")
    return 0
  end
  if fee.enabled ~= nil and type(fee.enabled) ~= "boolean" then
    log(ERROR, "Automarket market fee enabled setting must be a boolean; the fee is off")
    return 0
  end
  if not fee.enabled then return 0 end
  if type(fee.sliderValue) ~= "number" then
    log(ERROR, "Automarket market fee must be a number; the fee is off")
    return 0
  end
  if not isValid(fee.sliderValue) then
    log(WARNING, "Automarket market fee must be a whole number from 0 to 100; the fee is off")
    return 0
  end
  return fee.sliderValue
end

return {isValid = isValid, fromConfig = fromConfig}
