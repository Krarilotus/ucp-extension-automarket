# Automarket

此扩展提供自动市场。

## 功能

界面直接集成在游戏中。

![Automarket](https://raw.githubusercontent.com/gynt/ucp-extension-automarket/refs/heads/main/locale/ui-automarket-button.png)

支持多人游戏，但所有玩家都必须启用此扩展。

1.1.0 修复了多人设置数据包溢出及交易手续费计算问题。所有玩家必须一起更新。每位玩家的费率通过 **Save & Close** 同步；如果所有人应支付相同费率，请配置一致的手续费。加载 1.0.0 存档时，每位玩家必须通过 **Save & Close** 确认原有设置，自动交易才会恢复。

## 故障排查与已知问题

目前有稳定性问题，可能导致游戏在加载后或更晚时随机崩溃。如果原因在此，可尝试“自定义”页中的选项：**禁用 LuaJIT 即时编译，这会降低性能**。勾选该项可避开这一崩溃原因。

![LuaJIT](https://raw.githubusercontent.com/gynt/ucp-extension-automarket/refs/heads/main/locale/stability-debugging-setting.png)

若仍然崩溃，请报告问题。

## 工作方式

市场界面增加了一个按钮，点击后会打开菜单，列出所有商品、库存及自动市场设置。

自动市场每个游戏周先出售、后购买。点击商品并调整滑块，完成后点击勾选图标确认新设置。

购买阈值必须低于出售阈值，否则可能不断卖出后立刻买回，耗尽金币。代码中设有防止这种情况的措施。
