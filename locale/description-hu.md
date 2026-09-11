# Automarket

Ez a bővítmény automatikus piacot biztosít.

## Funkciók

A kezelőfelület közvetlenül a játékba épül.

![Automarket](https://raw.githubusercontent.com/gynt/ucp-extension-automarket/refs/heads/main/locale/ui-automarket-button.png)

Többjátékos módban is működik, ha minden résztvevő bekapcsolja a bővítményt.

Az 1.1.0 verzió javítja a többjátékos beállításcsomag túlcsordulását és a kereskedelmi díjak elszámolását. Minden játékosnak együtt kell frissítenie. Az egyéni díjak a **Save & Close** gombbal szinkronizálódnak. Ha mindenkinek azonos díjat kell fizetnie, állítsatok be egyező értékeket. Egy 1.0.0-s mentés betöltése után minden játékosnak meg kell erősítenie a meglévő beállításait a **Save & Close** gombbal, mielőtt az automatikus kereskedés folytatódik.

## Hibaelhárítás és ismert problémák

Egy stabilitási hiba véletlenszerű összeomlást okozhat a betöltés után vagy később. A Testreszabás lapon van egy lehetséges megoldás, ha ez az ok: **A LuaJIT futásidejű fordításának kikapcsolása csökkenti a teljesítményt**. Jelöld be ezt az összeomlási ok elkerüléséhez.

![LuaJIT](https://raw.githubusercontent.com/gynt/ucp-extension-automarket/refs/heads/main/locale/stability-debugging-setting.png)

Ha továbbra is összeomlik a játék, jelezd!

## Működés

A piac felületén egy új gomb nyitja meg az összes árut, készletet és automatikus piaci beállítást felsoroló menüt.

A piac minden játékhéten előbb elad, majd vásárol. Kattints az árura, állítsd a csúszkákat, majd a pipával erősítsd meg a módosításokat.

A vételi határ mindig legyen alacsonyabb az eladási határnál. Különben az eladással és azonnali visszavásárlással minden aranyadat elveszítheted. A kód tartalmaz védelmet ez ellen.
