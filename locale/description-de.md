# Automarket

Diese Erweiterung stellt einen automatischen Markt bereit.

## Funktionen

Die Oberfläche ist direkt in das Spiel integriert.

![Automarket](https://raw.githubusercontent.com/gynt/ucp-extension-automarket/refs/heads/main/locale/ui-automarket-button.png)

Funktioniert im Mehrspielermodus, wenn alle Teilnehmer die Erweiterung aktiviert haben.

Version 1.1.0 behebt einen Überlauf im Mehrspieler-Einstellungspaket und korrigiert die Abrechnung von Handelsgebühren. Alle Spieler müssen gemeinsam aktualisieren. Die Gebühr jedes Spielers wird mit **Save & Close** synchronisiert. Verwende übereinstimmende Gebühren, wenn alle denselben Satz zahlen sollen. Beim Laden eines Spielstands aus 1.0.0 muss jeder Spieler seine bestehenden Einstellungen mit **Save & Close** bestätigen, bevor der automatische Handel weitergeht.

## Fehlersuche und bekannte Probleme

Ein Stabilitätsproblem kann nach dem Laden oder später zu zufälligen Spielabstürzen führen. In „Anpassungen“ gibt es eine mögliche Gegenmaßnahme, falls dies die Ursache ist: **Just-in-Time-Kompilierung von LuaJIT deaktivieren; verringert die Leistung**. Aktiviere das Kontrollkästchen, um diese Absturzursache zu vermeiden.

![LuaJIT](https://raw.githubusercontent.com/gynt/ucp-extension-automarket/refs/heads/main/locale/stability-debugging-setting.png)

Stürzt das Spiel weiterhin ab, melde das bitte.

## Funktionsweise

In der Marktoberfläche gibt es eine zusätzliche Schaltfläche. Sie öffnet ein Menü mit allen Waren, ihren Beständen und den Einstellungen des automatischen Markts.

Jede Spielwoche verkauft der Markt zuerst Waren und kauft anschließend ein. Klicke eine Ware an und passe die Regler an. Übernimm die neuen Einstellungen zum Schluss mit dem Häkchen.

Die Kaufgrenze muss immer niedriger als die Verkaufsgrenze sein. Sonst riskierst du, dein Gold durch wiederholtes Verkaufen und sofortiges Zurückkaufen aufzubrauchen. Der Code enthält Schutzmaßnahmen dagegen.
