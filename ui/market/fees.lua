
-- 17, 23

---@return integer cost,integer credit 
local function calculateFeedCost(rawCost, neutralFee100)
    -- 2091
  local cost100 = (100 + neutralFee100) * rawCost

  -- 91
  local decimals100 = cost100 % 100

  local roundedCost100 = cost100
  if decimals100 ~= 0 then
    -- 2100
    roundedCost100 = cost100 + 100 - decimals100
  end

  if roundedCost100 % 100 ~= 0 then error(string.format("math fail: %s, %s", rawCost, neutralFee100)) end

  -- 9
  local overpayDecimals100 = roundedCost100 - cost100

  -- 21
  local roundedCost = roundedCost100 / 100

  -- 21, 9
  return roundedCost, overpayDecimals100
end


-- 17, 23

---@return integer reward,integer credit 
local function calculateFeedReward(rawReward, neutralFee100)
  -- 1309
  local reward100 = (100 - neutralFee100) * rawReward

  -- 9
  local decimals100 = reward100 % 100

  local roundedReward100 = reward100
  if decimals100 ~= 0 then
    -- 1300
    roundedReward100 = reward100 - decimals100
  end

  if roundedReward100 % 100 ~= 0 then error(string.format("math fail: %s, %s", rawReward, neutralFee100)) end

  -- 9
  local withheldDecimals100 = decimals100

  -- 13
  local roundedReward = roundedReward100 / 100

  -- 13, 9
  return roundedReward, withheldDecimals100
end

-- Preview settlement without modifying the saved balance. The caller commits
-- remainingCredit only after the native trade succeeds.
local function settleCredit(currentCredit, tradeCredit)
  local total = currentCredit + tradeCredit
  return math.floor(total / 100), total % 100
end

return {
  calculateFeedCost = calculateFeedCost,
  calculateFeedReward = calculateFeedReward,
  settleCredit = settleCredit,
}
