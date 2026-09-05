# Stronghold Crusader Automarket (UCP3)
This repository contains the source code for the Automarket extension.

The extension works with the [Unofficial Crusader Patch 3 framework](https://github.com/UnofficialCrusaderPatch/UnofficialCrusaderPatch), more information can be found [here](https://unofficialcrusaderpatch.github.io/).

## Features
- Integrated UI: the UI is integrated into the game.
- Works in Multiplayer: everyone needs to have the automarket extension activated.

## Upcoming features
- Customisations: customisations can be added based on popular demand. 

## Multiplayer and saved games
All players must use the same Automarket version. Version 1.1.0 fixes a settings-packet overflow and changes the packet format; do not mix it with 1.0.0.

Each player's configured market fee is committed with **Save & Close**. Every peer uses that committed fee for that player's trades, and saves preserve it. Agree on matching fee settings if everyone should pay the same rate; fees are not overridden by the host.

When loading a 1.0.0 save, thresholds and fee credit are preserved. Each player must confirm their settings with **Save & Close** before automated trading resumes. See [CHANGELOG.md](CHANGELOG.md) for release notes.

## Regression tests
Install Python and `lupa` (`python -m pip install 'lupa>=2.2,<3'`), then run `python tests/run.py`. The tests run the actual Lua handlers with mocked game memory and native trade functions. They do not replace two-peer in-game verification.

## Known issues
Currently there is a stability issue which makes the game exe crash when the load bar is full.
I am investigating the issue, it has probably to do with a bug in the `cffi` library.

## Usage
A button has been added to the Market interface. Upon clicking it, a modal menu will open listing all goods, its stock, and the settings of the automarket.

Every in-game week, the automarket will sell and buy goods (in that order). To configure a goods type, click on it, and then adjust the sliders. When finished, click the checkmark icon to commit your new settings.

Pay attention that your buy cutoff is always lower than your sale cutoff, otherwise you risk spending all your gold on selling and immediately buying. There are countermeasures into the code to avoid this situation.
