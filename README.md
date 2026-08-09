# 🎮 CS:GO SourceMod Plugins

Özel CS:GO sunucusu için geliştirilmiş SourceMod eklenti paketi.

## Eklentiler

### 🔐 `csgo_admin_selection.sp` — Merkezi Admin Sistemi
Sunucu yönetimi için gelişmiş, veritabanı destekli admin seçim sistemi.

**Komutlar:**
| Komut | Açıklama | Yetki |
|---|---|---|
| `!adminsec <SteamID>` | O anki oturum için geçici admin ver | ROOT |
| `!adminseckal <SteamID>` | Kalıcı admin listesine ekle | ROOT |
| `!adminseckaldir <SteamID>` | Kalıcı admin listesinden kaldır | ROOT |
| `!singleplayer` | Singleplayer modunu aç/kapat | ROOT |

**Singleplayer Modu:**
- Tüm admin yetkileri askıya alınır
- Başka oyuncu sunucuya bağlanamaz
- Tekrar `!singleplayer` yazınca mod kapanır ve yetkiler geri yüklenir

---

### 📌 `csgo_pin_mvp.sp` — MVP Müzik Seçici
Maç sonu MVP müziğini özelleştirme eklentisi.

---

### 🎨 `csgo_graffiti.sp` — Graffiti Sistemi
*(Geliştirme aşamasında — TO BE CONTINUED)*

---

### 🧪 `csgo_admin_test.sp` — Admin API Test Eklentisi
`admin_selection` API'sinin doğru çalışıp çalışmadığını test etmek için kullanılır.

---

## Kurulum

1. `.sp` dosyalarını `addons/sourcemod/scripting/` klasörüne kopyala
2. `include/admin_selection.inc` dosyasını `addons/sourcemod/scripting/include/` klasörüne kopyala
3. SourceMod compiler (`spcomp`) ile derle:
   ```
   spcomp.exe csgo_admin_selection.sp
   spcomp.exe csgo_pin_mvp.sp
   ```
4. Derlenen `.smx` dosyalarını `addons/sourcemod/plugins/` klasörüne kopyala
5. Sunucuda `sm plugins load <plugin_adı>` ile yükle

## Gereksinimler

- SourceMod 1.12+
- SQLite (storage-local, SourceMod ile birlikte gelir)
