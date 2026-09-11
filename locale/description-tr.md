# Automarket

Bu uzantı otomatik bir pazar sağlar.

## Özellikler

Arayüz doğrudan oyuna entegredir.

![Automarket](https://raw.githubusercontent.com/gynt/ucp-extension-automarket/refs/heads/main/locale/ui-automarket-button.png)

Tüm katılımcılar uzantıyı etkinleştirmişse çok oyunculuda çalışır.

1.1.0 sürümü çok oyunculu ayar paketinin taşmasını ve ticaret ücreti hesabını düzeltir. Tüm oyuncular birlikte güncellemelidir. Her oyuncunun ücreti **Save & Close** ile eşitlenir. Herkes aynı oranı ödeyecekse aynı ücretleri ayarlayın. 1.0.0 kaydı yüklenirken otomatik ticaretin sürmesi için her oyuncu mevcut ayarlarını **Save & Close** ile onaylamalıdır.

## Sorun giderme ve bilinen sorunlar

Bir kararlılık sorunu, oyun yüklendikten sonra veya daha ileride rastgele çökmeye neden olabilir. Neden buysa Özelleştirmeler sekmesindeki şu seçenek yardımcı olabilir: **LuaJIT’in anında derlemesini devre dışı bırak; performansı düşürür**. Bu çökme nedenini önlemek için kutuyu işaretleyin.

![LuaJIT](https://raw.githubusercontent.com/gynt/ucp-extension-automarket/refs/heads/main/locale/stability-debugging-setting.png)

Oyun hâlâ çöküyorsa lütfen bildirin.

## Nasıl çalışır

Pazar arayüzüne eklenen düğme; tüm malları, stokları ve otomatik pazar ayarlarını gösteren bir menü açar.

Pazar her oyun haftasında önce satar, sonra satın alır. Bir malı seçip kaydırıcıları ayarlayın. İşiniz bitince onay işaretine basın.

Alış eşiği daima satış eşiğinden düşük olmalıdır. Aksi hâlde satıp hemen geri alarak tüm altınınızı harcama riski vardır. Kodda bunu önleyen tedbirler bulunur.
