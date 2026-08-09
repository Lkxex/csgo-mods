# 📐 Sistem Mimarisi ve Geliştirici Rehberi

Bu belge, projeyi ilk kez gören bir geliştiricinin sistemi anlayabilmesi için hazırlanmıştır.

---

## 🗂️ Plugin Bağımlılık Haritası

```
csgo_admin_selection.sp   ← Ana admin sistemi (hiçbir şeye bağımlı değil)
        │
        │  native AdminSelection_IsAdmin(client)
        │  native AdminSelection_HasFlag(client, flag)
        │  native AdminSelection_GetFlags(client)
        │  native AdminSelection_IsActive()
        │
        └──── (kullanabilir ama zorunlu değil) ──→ csgo_custom_mvp.sp (SİLİNDİ)

weapons.sp                ← Silah skin seçici (PTaH gerektirir)
gloves.sp                 ← Eldiven seçici (PTaH gerektirir)
csgo_agentschooser.sp     ← Agent seçici (clientprefs gerektirir)
csgo_pin_mvp.sp           ← MVP müzik seçici (bağımsız)
csgo_voiceagents_enabler.sp ← Voice agent etkinleştirici (bağımsız)
server_help.sp            ← Yardım menüsü (server_help.phrases.txt gerektirir)
csgo_graffiti.sp          ← Graffiti (DEVRE DIŞI - TO BE CONTINUED)
csgo_admin_test.sp        ← Geliştirici testi (admin_selection API test)
```

---

## 🗄️ SQLite Veritabanları

Tüm kalıcı veriler SQLite'ta saklanır. SourceMod otomatik olarak şu konumda oluşturur:
```
csgo/addons/sourcemod/data/sqlite/
```

### 1. `admin_selection_admins` tablosu
**Plugin:** `csgo_admin_selection.sp`  
**Bağlantı:** `storage-local` (databases.cfg'de tanımlı)

```sql
CREATE TABLE IF NOT EXISTS admin_selection_admins (
    account_id INTEGER PRIMARY KEY  -- Steam Account ID (SteamID64'ten türetilir)
);
```

**Örnek kayıtlar:**
```sql
-- Kalıcı admin ekleme
INSERT OR IGNORE INTO admin_selection_admins (account_id) VALUES (123456789);

-- Kalıcı admin listesi
SELECT account_id FROM admin_selection_admins;

-- Admin kaldırma
DELETE FROM admin_selection_admins WHERE account_id = 123456789;
```

**SteamID → Account ID dönüşümü:**
- SteamID64 `76561198083722517` → Account ID `123456789`
- Formül: `SteamID64 - 76561197960265728 = AccountID`
- Oyun içinde: `GetSteamAccountID(client)` fonksiyonu bu değeri döner

---

### 2. `sm_gloves` tablosu
**Plugin:** `gloves.sp`  
**Bağlantı:** `storage-local`

```sql
-- Gloves plugin kendi tablosunu otomatik oluşturur
-- Yapısı yaklaşık olarak:
CREATE TABLE IF NOT EXISTS sm_gloves (
    accountid   INTEGER NOT NULL,
    team        INTEGER NOT NULL,  -- 2=T, 3=CT
    defindex    INTEGER NOT NULL,  -- Eldiven item ID
    paintwear   REAL DEFAULT 0.0,  -- Float değeri (0.0 = yeni, 1.0 = yıpranmış)
    PRIMARY KEY (accountid, team)
);
```

**Örnek kayıtlar:**
```sql
-- Bir oyuncunun eldivenini görüntüle
SELECT * FROM sm_gloves WHERE accountid = 123456789;

-- Tablo ismini sm_gloves_table_prefix değiştirebilir (gloves.cfg'den)
```

---

### 3. `sm_weapons` tablosu
**Plugin:** `weapons.sp`  
**Bağlantı:** `storage-local`

```sql
-- Weapons plugin kendi tablosunu otomatik oluşturur
-- Silah skin, float, seed, stattrak bilgilerini saklar
CREATE TABLE IF NOT EXISTS sm_weapons (
    accountid   INTEGER NOT NULL,
    defindex    INTEGER NOT NULL,  -- Silah item ID (bkz. csgo item_game.txt)
    paintwear   REAL DEFAULT 0.0,
    paintindex  INTEGER DEFAULT 0, -- Skin ID
    paintseed   INTEGER DEFAULT 0,
    stattrak    INTEGER DEFAULT -1, -- -1 = kapalı
    nametag     TEXT DEFAULT '',
    PRIMARY KEY (accountid, defindex)
);
```

---

## 🔑 Admin Sistemi Nasıl Çalışır?

### Yetki Modeli
```
ROOT (z flag)     → Sadece sunucu sahibi. admins_simple.ini'den belirlenir.
                    !adminsec, !adminseckal, !adminseckaldir, !singleplayer kullanabilir.

GENERIC (b flag)  → Admin Selection ile verilen oyunculara atanır.
                    !admin menüsü, !kick, !ban, !mute, !slay, !map kullanabilir.

Normal Oyuncu     → Hiçbir admin yetkisi yok.
```

### Admin Ekleme Süreci
```
1. [ROOTsun] !adminsec 76561198083722517
        │
        ▼
2. NormalizeSteamID() → SteamID64 → AccountID (123456789) dönüşümü
        │
        ▼
3. Oyuncu sunucudaysa: g_bTempAdmins[client] = true + ApplyAdminFlag()
   Oyuncu yoksa: "Oyuncu bulunamadı" mesajı
        │
        ▼
4. AdminId oluşturulur, Admin_Generic (b) flag set edilir
5. Bu oturum kapanana kadar geçerli (map change sonrası sıfırlanır)
```

### Kalıcı Admin (!adminseckal)
```
1. [ROOTsun] !adminseckal 76561198083722517
        │
        ▼
2. NormalizeSteamID() → AccountID (123456789)
        │
        ▼
3. SQLite'a REPLACE INTO admin_selection_admins (123456789)
        │
        ▼
4. Oyuncu sunucudaysa anında yetki verilir
5. Oyuncu sonraki bağlantıda OnClientAuthorized() → SQL sorgusu → yetki yüklenir
```

### Singleplayer Modu
```
[ROOTsun] !singleplayer
        │
        ├── Sunucuda başka gerçek oyuncu var mı? → Varsa HATA
        │
        ▼
g_bSingleplayerMode = true
g_SingleplayerHostAccountID = GetSteamAccountID(sen)
        │
        ▼
Tüm oyuncular için StripAllAdminFlags() çalışır:
  - AdminId içindeki 20 flag tek tek false yapılır
  - SetUserFlagBits(client, 0)
  - AddCommandListener ile !admin menüsü engellenir
        │
        ▼
OnClientConnect() → IsFakeClient değilse bağlantı reddedilir
        │
        ▼
[ROOTsun] !singleplayer (tekrar)
        │
        ▼
g_bSingleplayerMode = false
sm_reloadadmins → SourceMod admin cache yenilenir
SQLite'tan kalıcı adminler yeniden yüklenir
```

---

## 🧩 Admin Selection API (Diğer Pluginler İçin)

`include/admin_selection.inc` dosyası aşağıdaki native'leri tanımlar:

```sourcepawn
#include <admin_selection>

// Oyuncunun Admin Selection üzerinden admin olup olmadığını kontrol eder
// Singleplayer modunda sadece host (ROOT) için true döner
bool isAdmin = AdminSelection_IsAdmin(client);

// Belirli bir flag var mı?
bool hasGeneric = AdminSelection_HasFlag(client, Admin_Generic);

// Tüm flag bitmasği
int flags = AdminSelection_GetFlags(client);

// Admin sistemi aktif mi? (Singleplayer modunda false döner)
// Bunu kullanarak diğer pluginler admin kontrolünü devre dışı bırakabilir
bool active = AdminSelection_IsActive();
```

**Örnek kullanım (başka bir plugin):**
```sourcepawn
#include <admin_selection>
#include <sourcemod>

public Action Command_OzelKomut(int client, int args)
{
    // Önce AdminSelection API'sinin aktif olup olmadığına bak
    if (LibraryExists("admin_selection") && AdminSelection_IsActive())
    {
        if (!AdminSelection_IsAdmin(client))
        {
            ReplyToCommand(client, "Bu komutu kullanmak için admin olman gerekiyor.");
            return Plugin_Handled;
        }
    }
    else
    {
        // Fallback: SM'nin kendi admin sistemi
        if (!CheckCommandAccess(client, "sm_ozelkomut", ADMFLAG_GENERIC))
        {
            ReplyToCommand(client, "Yetkin yok.");
            return Plugin_Handled;
        }
    }
    
    // Komut işleme
    return Plugin_Handled;
}
```

---

## 🎮 Oyuncu Komutları Özeti

| Komut | Plugin | Açıklama |
|---|---|---|
| `!ws` veya `!weapons` | weapons.sp | Silah skin menüsü |
| `!glove` veya `!eldiven` | gloves.sp | Eldiven seçim menüsü |
| `!agents` veya `!ajan` | csgo_agentschooser.sp | Agent/karakter seçim menüsü |
| `!mvp` veya `!music` | csgo_pin_mvp.sp | MVP müzik kiti seçimi |
| `!pin` veya `!coin` | csgo_pin_mvp.sp | Profil rozeti seçimi |
| `!help` veya `!yardim` | server_help.sp | Tüm komutları göster |

### Admin Komutları

| Komut | Plugin | Açıklama | Yetki |
|---|---|---|---|
| `!admin` | adminmenu.smx (SM) | Admin menüsü (kick, ban, mute...) | GENERIC (b) |
| `!adminsec <SteamID>` | csgo_admin_selection.sp | Geçici admin ver | ROOT (z) |
| `!adminseckal <SteamID>` | csgo_admin_selection.sp | Kalıcı admin ekle | ROOT (z) |
| `!adminseckaldir <SteamID>` | csgo_admin_selection.sp | Admin kaldır | ROOT (z) |
| `!singleplayer` | csgo_admin_selection.sp | Singleplayer modu | ROOT (z) |

---

## ⚙️ Konfigürasyon Referansı

### `admins_simple.ini` — ROOT Admin Tanımlama
```ini
// Format: "STEAM_0:X:XXXXXXX"  "flags"
// z = root (her şeye erişim)
"STEAM_0:1:12345678"   "z"
```

### `databases.cfg` — Veritabanı Bağlantısı
```
"storage-local"   → SQLite (admin_selection, gloves, weapons veritabanları buraya bağlı)
```

### `gloves.cfg` — Eldiven Plugin Ayarları
```
sm_gloves_chat_prefix      → Chat mesajlarının öneki (varsayılan: "[oyunhost.net]")
sm_gloves_db_connection    → Veritabanı bağlantısı (varsayılan: "storage-local")
sm_gloves_enable_float     → Float ayarını aç/kapat
sm_gloves_float_increment_size → Float adım büyüklüğü (0.2 = %20)
sm_gloves_enable_world_model → Diğer oyuncular eldivenleri görsün mü
```

### `weapons.cfg` — Silah Plugin Ayarları
```
sm_weapons_chat_prefix     → Chat öneki
sm_weapons_db_connection   → Veritabanı
sm_weapons_inactive_days   → Kaç günde bir pasif oyuncu verisi silinsin (30)
sm_weapons_enable_stattrak → StatTrak sayacı
sm_weapons_enable_nametag  → Name tag (isim etiketi)
sm_weapons_enable_seed     → Paint seed seçeneği
```

### `csgo_agentschooser.cfg` — Agent Seçici Ayarları
```
sm_csgoagents_autoopen        → Oyuncu bağlandığında menüyü otomatik aç (0=kapalı)
sm_csgoagents_instantly       → Anlık skin uygula (1=açık)
sm_csgoagents_previewduration → Önizleme süresi (saniye, 3.0)
```
