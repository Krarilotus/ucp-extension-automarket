local fees = require("ucp/modules/automarket/ui/market/fees")

-- Called in simulation order on every peer. All inputs affecting a trade must
-- come from the synchronized/saved state, never the local UI configuration.
local function process(data, market, goodsOrder, tradeability)
  for playerID = 1, 8 do
    local am = data.playerSettings[playerID]
    local fee = data.marketFees[playerID]
    local resources = market.playerResources[playerID]
    if am.enabled and fee >= 0 and fee <= 100
        and market.marketBuildings[playerID][0] ~= 0
        and market.getAliveLordForPlayer(market.UnitsState, playerID) > 0 then
      for _, good in ipairs(goodsOrder) do
        if tradeability[good] == 1 and am.sellEnabled[good]
            and (not am.buyEnabled[good] or am.sellValues[good] >= am.buyValues[good]) then
          local surplus = resources[good] - am.sellValues[good]
          if surplus > 0 then
            local rawReward = market.getSellPrice(market.GameState, playerID, good, surplus)
            local reward, credit = fees.calculateFeedReward(rawReward, fee)
            local refund, remainingCredit = fees.settleCredit(data.playerCredit[playerID].credit, credit)
            market.sellGoods(market.AICState, playerID, good, surplus)
            resources[0xF] = resources[0xF] - (rawReward - reward) + refund
            data.playerCredit[playerID].credit = remainingCredit
          end
        end
      end

      for _, good in ipairs(goodsOrder) do
        local availableGold = resources[0xF] - am.goldReserve
        if availableGold < 0 then break end
        if tradeability[good] == 1 and am.buyEnabled[good]
            and (not am.sellEnabled[good] or am.buyValues[good] <= am.sellValues[good]) then
          local shortage = am.buyValues[good] - resources[good]
          if shortage > 0 then
            local rawCost = market.getBuyPrice(market.GameState, playerID, good, shortage)
            local cost, credit = fees.calculateFeedCost(rawCost, fee)
            local refund, remainingCredit = fees.settleCredit(data.playerCredit[playerID].credit, credit)
            -- Compare the final charge, including any previously earned refund.
            -- Native buyGoods returns false if the goods cannot be stored.
            if availableGold >= cost - refund
                and market.buyGoods(market.AICState, playerID, good, shortage) then
              resources[0xF] = resources[0xF] - (cost - rawCost) + refund
              data.playerCredit[playerID].credit = remainingCredit
            end
          end
        end
      end
    end
  end
end

return process
