# 🎮 CS:GO SourceMod Plugins

Özel CS:GO sunucusu için geliştirilmiş SourceMod eklenti paketi.

## 📁 Klasör Yapısı

```
csgo/
├── addons/sourcemod/
│   ├── scripting/          # Kaynak kodlar (.sp)
│   │   ├── include/        # API header dosyaları (.inc)
│   │   │   ├── admin_selection.inc
│   │   │   ├── gloves.inc
│   │   │   └── PTaH.inc
│   │   ├── csgo_admin_selection.sp
│   │   ├── csgo_agentschooser.sp
│   │   ├── csgo_graffiti.sp
│   │   ├── csgo_pin_mvp.sp
│   │   ├── csgo_voiceagents_enabler.sp
│   │   ├── gloves.sp
│   │   └── server_help.sp
│   └── plugins/            # Derlenmiş eklentiler (.smx)
└── cfg/sourcemod/          # Konfigürasyon dosyaları
```

## 🧩 Eklentiler

### 🔐 `csgo_admin_selection.sp` — Merkezi Admin Sistemi
Veritabanı destekli (SQLite) merkezi admin yönetim sistemi. Diğer eklentilere native API sunar.

| Komut | Açıklama | Yetki |
|---|---|---|
| `!adminsec <SteamID>` | Geçici admin ver (sadece bu oturum) | ROOT |
| `!adminseckal <SteamID>` | Kalıcı admin listesine ekle | ROOT |
| `!adminseckaldir <SteamID>` | Admin listesinden kaldır | ROOT |
| `!singleplayer` | Singleplayer modu aç/kapat | ROOT |

**Singleplayer Modu:** Tüm admin yetkileri devre dışı, dışarıdan kimse bağlanamaz.  
Tekrar `!singleplayer` yazınca her şey eski haline döner.

---

### 🧍 `csgo_agentschooser.sp` — Agent/Karakter Seçici
Oyuncuların kendi CS:GO karakterini (agent) seçmesine izin verir.

---

### 🧤 `gloves.sp` — Eldiven Seçici
Oyuncuların özel eldiven skin seçmesine izin verir.

---

### 📌 `csgo_pin_mvp.sp` — MVP Müzik Seçici
Maç sonu MVP müziğini özelleştirme eklentisi.

---

### 🎤 `csgo_voiceagents_enabler.sp` — Voice Agent Etkinleştirici
CS:GO agent seslerinin sunucuda aktif olmasını sağlar.

---

### ℹ️ `server_help.sp` — Sunucu Yardım Menüsü
Oyunculara sunucu komutlarını ve kuralları gösteren yardım menüsü.

---

### 🎨 `csgo_graffiti.sp` — Graffiti Sistemi
*(Geliştirme aşamasında — TO BE CONTINUED)*

---

### 🧪 `csgo_admin_test.sp` — Admin API Test
`admin_selection` API'sini test etmek için kullanılan geliştirici eklentisi.

---

## 🚀 Kurulum

1. Bu repoyu klonla veya ZIP olarak indir
2. `addons/` ve `cfg/` klasörlerini CS:GO sunucu dizinine (`csgo/`) kopyala
3. Sunucuyu başlat, eklentiler otomatik yüklenir

> `.smx` dosyaları zaten derlenmiş halde, ayrıca derlemeye gerek yok.  
> Kaynak kodu düzenlemek istersen `spcomp.exe` ile derleyebilirsin.

## ⚙️ Gereksinimler

- SourceMod 1.12+
- [PTaH Extension](https://github.com/komashchenko/PTaH) (agentschooser ve gloves için)
- SQLite (storage-local, SourceMod ile birlikte gelir)
