# 🎮 CS:GO SourceMod Plugins

Özel CS:GO listen server için geliştirilmiş SourceMod eklenti paketi.

---

## 📦 Bağımlılıklar (Kurulmadan Önce Bunlar Gerekli)

### 1. Metamod:Source
CS:GO'nun plugin altyapısı. SourceMod bunu gerektirir.
- **İndir:** https://www.sourcemm.net/downloads.php?branch=stable
- Kurulum: `csgo/addons/` altına çıkart

### 2. SourceMod
Tüm `.smx` eklentilerin çalıştığı temel framework.
- **İndir:** https://www.sourcemod.net/downloads.php?branch=stable
- Kurulum: `csgo/addons/sourcemod/` altına çıkart

### 3. PTaH Extension ✅ (Repoda mevcut)
Gloves ve Agent seçici eklentilerin çalışması için gerekli SourceMod extension'ı.
- **Repodaki konum:** `addons/sourcemod/extensions/PTaH.ext.2.csgo.dll`
- **Kaynak:** https://github.com/komashchenko/PTaH

---

## 📁 Klasör Yapısı

```
csgo/
├── addons/
│   └── sourcemod/
│       ├── configs/
│       │   ├── databases.cfg          # SQLite ayarları (admin DB için)
│       │   └── admins_simple.ini      # ROOT admin SteamID listesi
│       ├── extensions/
│       │   └── PTaH.ext.2.csgo.dll   # PTaH extension (gloves/agents için)
│       ├── plugins/                   # Derlenmiş eklentiler (.smx)
│       │   ├── csgo_admin_selection.smx
│       │   ├── csgo_agentschooser.smx
│       │   ├── csgo_graffiti.smx
│       │   ├── csgo_pin_mvp.smx
│       │   ├── csgo_voiceagents_enabler.smx
│       │   ├── gloves.smx
│       │   └── server_help.smx
│       └── scripting/                 # Kaynak kodlar (.sp)
│           ├── include/
│           │   ├── admin_selection.inc
│           │   ├── gloves.inc
│           │   └── PTaH.inc
│           ├── gloves/                # Gloves alt modülleri
│           │   ├── config.sp
│           │   ├── database.sp
│           │   ├── globals.sp
│           │   ├── helpers.sp
│           │   ├── hooks.sp
│           │   ├── menus.sp
│           │   └── natives.sp
│           └── *.sp
└── cfg/
    └── sourcemod/
        ├── csgo_agentschooser.cfg
        ├── custommvp.cfg
        └── gloves.cfg
```

---

## 🧩 Eklentiler

### 🔐 `csgo_admin_selection` — Merkezi Admin Sistemi
Veritabanı destekli (SQLite) merkezi admin yönetim sistemi. Diğer eklentilere native API sunar.

**Bağımlılıklar:** SourceMod (sdktools, cstrike)

| Komut | Açıklama | Yetki |
|---|---|---|
| `!adminsec <SteamID>` | Geçici admin ver (sadece bu oturum) | ROOT |
| `!adminseckal <SteamID>` | Kalıcı admin listesine ekle | ROOT |
| `!adminseckaldir <SteamID>` | Admin listesinden kaldır | ROOT |
| `!singleplayer` | Singleplayer modu aç/kapat | ROOT |

> **Singleplayer Modu:** Tüm admin yetkileri devre dışı, !admin menüsü engelli, dışarıdan kimse bağlanamaz. Tekrar `!singleplayer` yazınca eski haline döner.

---

### 🧍 `csgo_agentschooser` — Agent/Karakter Seçici
Oyuncuların kendi CS:GO karakterini (agent/model) seçmesine izin verir.

**Bağımlılıklar:** SourceMod (sdktools, sdkhooks, cstrike, clientprefs)

---

### 🧤 `gloves` — Eldiven Seçici
Oyuncuların özel eldiven skin seçmesine izin verir. SQLite ile seçim kaydedilir.

**Bağımlılıklar:** SourceMod (sdktools, cstrike) + **PTaH extension**

---

### 📌 `csgo_pin_mvp` — MVP Müzik Seçici
Maç sonu MVP müziğini özelleştirme eklentisi.

**Bağımlılıklar:** SourceMod (sdktools, cstrike, sdkhooks)

---

### 🎤 `csgo_voiceagents_enabler` — Voice Agent Etkinleştirici
CS:GO agent seslerinin sunucuda aktif olmasını sağlar.

**Bağımlılıklar:** SourceMod (sdktools)

---

### ℹ️ `server_help` — Sunucu Yardım Menüsü
Oyunculara sunucu komutlarını ve kuralları gösteren yardım menüsü.

**Bağımlılıklar:** SourceMod

---

### 🎨 `csgo_graffiti` — Graffiti Sistemi
*(Geliştirme aşamasında — TO BE CONTINUED)*

**Bağımlılıklar:** SourceMod (sdktools, cstrike)

---

### 🧪 `csgo_admin_test` — Admin API Test
`admin_selection` API'sini test etmek için kullanılan geliştirici eklentisi.

---

## 🚀 Kurulum

1. **Metamod:Source** ve **SourceMod**'u kur (yukarıdaki linkler)
2. Bu repoyu klonla veya ZIP olarak indir:
   ```
   git clone https://github.com/Lkxex/csgo-mods.git
   ```
3. `addons/` ve `cfg/` klasörlerini CS:GO sunucu dizinine (`csgo/`) kopyala
4. `addons/sourcemod/configs/admins_simple.ini` dosyasına kendi SteamID'ni ekle:
   ```
   "STEAM_0:X:XXXXXXXX"   "z"
   ```
5. Sunucuyu başlat — eklentiler otomatik yüklenir

> `.smx` dosyaları zaten derlenmiş, ayrıca derlemeye gerek yok.

---

## 🔧 Geliştirme

Kaynak kodu değiştirmek istersen:
```bash
# SourceMod scripting klasöründe
spcomp.exe csgo_admin_selection.sp
# Çıktıyı plugins/ klasörüne kopyala
```
