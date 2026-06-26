# 📱 macOS To-Do App

Modern, iki panelli macOS görev yönetim uygulaması

🚀 Kurulum ve Çalıştırma (macOS)

Uygulama henüz Apple Geliştirici Havuzuna kayıtlı (notarized) olmadığı için, internetten indirildiğinde macOS güvenlik duvarı (Gatekeeper) nedeniyle varsayılan olarak engellenebilir veya *"Uygulama açılamıyor"* uyarısı verebilir. 

Uygulamayı sorunsuz bir şekilde çalıştırmak için aşağıdaki adımları izleyebilirsiniz:

## Yöntem 1: Sağ Tık ile Aç (En Kolay Yol)
1. **Releases** bölümünden indirdiğiniz zip dosyasından çıkan `.app` dosyasını `Uygulamalar (Applications)` klasörünüze taşıyın.
2. Uygulamaya çift tıklamak yerine **sağ tıklayın** (veya klavyeden `Control` tuşuna basılı tutarak tıklayın) ve **Aç (Open)** seçeneğini seçin.
3. Ekrana gelen uyarı penceresinde bu kez **Aç** butonu belirecektir. Buna tıkladığınızda uygulama açılır. (Bu işlemi sadece ilk açılışta bir kez yapmanız yeterlidir).

### Yöntem 2: Terminal ile Güvenlik Engelini Kaldırma (Eğer Yöntem 1 Çalışmazsa)
Eğer macOS hâlâ uygulamanın açılmasına izin vermiyorsa, terminal üzerinden karantina etiketini temizleyebilirsiniz:

1. **Terminal** uygulamasını açın.
2. Aşağıdaki komutu yapıştırın (en sondaki uygulama yolunu kendi bilgisayarınıza göre düzenleyin veya uygulamayı terminale sürükleyip bırakın):

```bash
xattr -cr /Applications/"to do app.app"

## 🎯 Özellikler

- 🌍 İngilizce/Türkçe tam lokalizasyon
- 🎨 Modern UI (Parallax, Glassmorphism)
- 📊 Detaylı istatistik dashboard
- 🏆 Başarı rozetleri
- 🎯 Verimlilik skorlama (0-100)
- 🎨 Tema desteği (Sistem/Aydınlık/Karanlık)

## 🚀 Gereksinimler

- macOS 14.0+
- Xcode 15.0+
- Swift 5.9+

## 📄 Lisans

© 2025 bektasing
<img width="1196" height="744" alt="Ekran Resmi 2026-06-26 11 18 12" src="https://github.com/user-attachments/assets/f97a794d-9dfa-4f23-aa44-dba4a13ad719" />
<img width="1196" height="744" alt="Ekran Resmi 2026-06-26 11 19 08" src="https://github.com/user-attachments/assets/c958eee7-58fc-4001-aa96-9f16c2ec558f" />
<img width="1196" height="744" alt="Ekran Resmi 2026-06-26 11 18 39" src="https://github.com/user-attachments/assets/d55e359f-03ba-4da8-8650-94650f26cb1f" />
