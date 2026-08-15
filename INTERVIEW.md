# 📝 Aether Alchemist – Master Game Design & Architecture Document (v1.0 Final)

**Projekt**: Aether Alchemist (Element Shapers)  
**Pfad**: `D:\anana\Pictures\Roblox Projects\Mein_Roblox_Projekt\`  
**Datum**: 13. August 2026  
**Status**: 100% Lückenlos Spezifiziert & Ausbalanciert (Bereit für Produktion)

---

## 📌 1. Vision & Release-Strategie (v1.0 MVP)

- **Genre**: Innovative Crafting & Fantasy Action Simulator
- **Plattformen**: Alle (Mobile/Touch, PC/Maus-Tastatur, Konsole/Gamepad, Tablet)
- **v1.0 Level-Cap**: **Level 25** (6 bis 10 Stunden reine Spielzeit für den ersten Durchlauf).
- **Abgelehnt**: Keine Pay-to-Win Pets! (Ersetzt durch aktive 2nd-Ability Elementar-Wesen).
- **Keine Crafting-Wartezeit**: 0s Instant Crafting.
- **Kein Rucksack-Limit**: Unbegrenztes Inventar.

---

## 📌 2. Visuelles Design-System (Look & Feel)

- **UI-Thema**: **Modern Glassmorphism** (Dunkelblau/Obsidian halbtransparentes Glas mit edlen goldenen Rändern & leuchtenden Akzenten).
- **3D-Artstyle**: **Stylized Low-Poly** mit Future Lighting & PBR SurfaceAppearance (Bunte, saubere Geometrie; butterweiche 60 FPS Performance auf Mobilgeräten).
- **VFX-Stil**: **Magisch & Leuchtend** (Soft-Glowing Partikelstürme, Funken, LightEmission Energy-Glows & geschmeidiges Camera-Shake Feedback).

---

## 📌 3. Elemente, Erze, Mobs & Content-Tabellen

### 3.1 Erze & Verkaufspreise beim Alchemie-Händler NPC
| Erz-Name | Element | Seltenheit | Fundort / Zone | Verkaufspreis (Aether-Essenz) |
| :--- | :--- | :--- | :--- | :--- |
| **Erd-Topas** | Erde | Gewöhnlich (Common) | Zone 1 (Elementar-Wiese) | 5 Essenz |
| **Feuer-Rubin** | Feuer | Selten (Rare) | Zone 1 & 2 | 20 Essenz |
| **Ozean-Saphir** | Wasser | Selten (Rare) | Zone 1 & 2 | 20 Essenz |
| **Wind-Smaragd** | Wind | Selten (Rare) | Zone 2 (Kristall-Schlucht) | 20 Essenz |
| **Blitz-Amethyst** | Blitz | Episch (Epic) | Zone 2 & 3 | 60 Essenz |
| **Void-Kristall** | Void | Mythisch (Mythic) | Zone 3 (Koloss-Gipfel) | 200 Essenz |

### 3.2 Boss-Loot-Tabelle (Kristall-Koloss Drops)
| Item-Name | Seltenheit | Drop-Chance | Zweck / Verwendung | Verkaufspreis |
| :--- | :--- | :--- | :--- | :--- |
| **Koloss-Splitter** | Common | 100% (1–3x) | Rezept-Zutat für Kristall-Panzer & Koloss-Verstärkung | 50 Essenz |
| **Koloss-Kern** | Rare | 40% (1x) | Rezept-Zutat für Sturm-Schneide Klinge | 150 Essenz |
| **Koloss-Herzen** | Epic | 15% (1x) | Rezept-Zutat für Aether-Rausch & Kristall-Krone | 400 Essenz |

### 3.3 Waffen-Progression (Tier 1 bis 5)
| Klingen-Name | Tier | Schaden | Effekt / Skill | Freischaltung / Herkunft |
| :--- | :--- | :--- | :--- | :--- |
| **Anfänger-Klinge** | Tier 1 | 10 Dmg | Basis-Nahkampf | Startausrüstung |
| **Feuer-Säbel** | Tier 2 | 25 Dmg | +5 DoT-Brandschaden (2s) | Kessel-Rezept (`2x Feuer-Rubin`) |
| **Ozean-Dreizack** | Tier 3 | 45 Dmg | Heilt 5 HP pro Treffer | Kessel-Rezept (`2x Ozean-Saphir + 1x Erd-Topas`) |
| **Sturm-Schneide** | Tier 4 | 75 Dmg | Abfeuert Blitz-Schockwelle | Boss-Drop Rezept (`3x Blitz-Amethyst + 1x Koloss-Kern`) |
| **Void-Schattenklinge** | Tier 5 | 110 Dmg | Teleport-Treffer + 20% Krit | Kessel-Rezept (`3x Void-Kristall + 1x Koloss-Herzen`) |

### 3.4 Mobs & Bosse in den Zonen
- **Zone 1 (Elementar-Wiese)**: *Erd-Schleim* (50 HP, 5 Dmg) – Droppt Erd-Topas & 20 XP.
- **Zone 2 (Kristall-Schlucht)**: *Kristall-Krabbe* (150 HP, 15 Dmg) & **Kristall-Krabben-Elite (Zone 2 Mini-Boss)** (250 HP, 20 Dmg).
- **Zone 3 (Koloss-Gipfel)**: *Void-Stalker* (350 HP, 30 Dmg) & **Kristall-Koloss (Hauptboss)** (500 BaseHP).
- **Boss Phase 2 Minions**: *Mini Kristall-Koloss* (100 HP, 8 Dmg per Schlag).

---

## 📌 4. Elementar-Wesen (Begleiter / 2nd Ability) & Freischaltung

Das Wesen schwebt neben der Schulter des Spielers und wird per Taste `E` / Mobile-Button aktiviert:
1. **Feuer-Phönix** *(Start-Wesen)*: Feuerwelle nach vorne (50 Schaden + Verbrennung). *Freischaltung: Von Beginn an*.
2. **Eis-Golem** *(Zone 2 Begleiter)*: Frost-Schild (absorbiert 100 Schaden) + Slow-Aura. *Freischaltung: Besiege den Kristall-Krabben-Elite (Zone 2 Mini-Boss)*.
3. **Void-Phantom** *(Zone 3 Begleiter)*: 15-Stud Teleport nach vorne + Schatten-Explosion (75 Schaden). *Freischaltung: Besiege den Kristall-Koloss (Zone 3 Hauptboss)*.

---

## 📌 5. Kessel-Crafting & Profit-Balancing

*Grundregel*: Gecraftete Tränke/Artefakte bringen beim Händler **+50% mehr Aether-Essenz** als die Rohstoffe ODER verleihen mächtige Spielvorteile!

1. **Inferno-Trank**: `2x Feuer-Rubin + 1x Wind-Smaragd` $\rightarrow$ +20% Angriffs-Schaden (5 Min). *Verkauf: 90 Essenz*.
2. **Gletscher-Schutz**: `2x Ozean-Saphir + 1x Erd-Topas` $\rightarrow$ Absorbiert 100 Schaden. *Verkauf: 70 Essenz*.
3. **Sturm-Tempo**: `2x Blitz-Amethyst + 1x Wind-Smaragd` $\rightarrow$ +30% Speed (5 Min). *Verkauf: 210 Essenz*.
4. **Aether-Elixier**: `1x Feuer-Rubin + 1x Ozean-Saphir + 1x Void-Kristall` $\rightarrow$ +50% XP-Bonus (10 Min). *Verkauf: 360 Essenz*.
5. **Kosmische Essenz**: `2x Void-Kristall + 1x Blitz-Amethyst` $\rightarrow$ +15% Krit-Chance (5 Min). *Verkauf: 690 Essenz*.

---

## 📌 6. Trading-System zwischen Spielern

- **Handelbare Items**: Erze, Elemente, Tränke, Schriftrollen/Rezepte & Artefakte.
- **Nicht-Handelbar**: Start-Ausrüstung (Anfänger-Klinge) & gekaufte GamePasses.
- **Sicherheits-Countdown**: 3-Sekunden Sperre nach jeder Item-Änderung gegen Trading-Scams.

---

## 📌 7. Elden-Ring-Style Boss-System & Smart Scaling Engine

### 7.1 Der 1. Hauptboss: Kristall-Koloss (Zone 3)
- **Basis-HP auf Level 1**: 500 HP | **Basis-Schaden Spieler**: 10 Schaden.
- **Phase 1 (100%–50% HP)**: Roter Warnkreis (1,5s AOE), 3 Kristall-Projektile, Ansturm.
- **Phase 2 Rage-Modus (<50% HP)**: **+20% Tempo** & beschwört **2 Mini-Kristall-Kolosse** (je 100 HP, 8 Dmg).
- **Sensorkreis Warteschlange (60–120s)**: Skaliert **nur** auf aktive Teilnehmer im Bereich! Unbeteiligte Server-Spieler werden ignoriert.
- **Formel**: $\text{Boss HP} = \text{BaseHP} \times \text{TeilnehmerAnzahl} \times \left(1 + 0.5 \times \text{DurchschnittsLevel}\right)$.
- **Elden-Ring-Feeling**: Hochspannung, kein Erze-Verlust bei Tod, Respawn am Arenarand nach 5s, automatischer Kamera-Zoom-Out.

---

## 📌 8. Technical & UI Specifications

### 8.1 DataStore Schema (`ProfileService`)
```luau
{
    Level = 1,
    XP = 0,
    AetherEssence = 100,
    SkillPoints = 0,
    Skills = { Harvester = 0, Alchemist = 0, Summoner = 0 },
    Inventory = { ["EarthTopaz"] = 5, ["FireRuby"] = 2 },
    UnlockedRecipes = { "InfernoPotion" },
    EquippedWeapon = "BasicBlade",
    EquippedSummon = "FirePhoenix",
    Settings = { MusicVolume = 0.5, SFXVolume = 0.8, CameraShake = true }
}
```

---

## 📌 9. 3D-Welt, Future-Lighting & Statische Map-Architektur

### 9.1 Map-Layout & Geometrie
- **Startdorf (Elementar-Wiese)**: Bunte Low-Poly Grasebene (`350x6x350 Studs`) auf Position `(0, -3, 0)` mit Pflasterstein-Dorfplatz (`80x0.4x80 Studs`).
- **Alchemie-Kessel Altar**: Erhöhtes Marmor-Podest (`20x2x20 Studs`) bei `(0, 1, 45)` mit Metall-Kessel (`AlchemicalCauldron`) & blauer Lichtquelle (`PointLight`).
- **Alchemie-Händler Stand**: Holz-Marktstand (`14x8x10 Studs`) bei `(-45, 4, 0)` mit Händler-NPC Part & Interaktions-Prompt (`ProximityPrompt`).
- **Abbau-Knoten (Wiese)**: 7 leuchtende Neon-Kristalladern (Erd-Topas, Feuer-Rubin, Ozean-Saphir, Void-Kristall) mit eigenen Lichtquellen & ProximityPrompts.
- **Kristall-Koloss Arena**: Schiefer-Arena (`160x4x160 Studs`) bei `(0, -2, -180)` mit leuchtend rotem Warteschlangen-Sensorkreis (`BossQueueCircle`).

### 9.2 Lighting & Atmosphaere Setup
- **Beleuchtung**: Roblox `Future Lighting` (ClockTime 14.5, Brightness 2.2).
- **Post-Processing**: `BloomEffect` (Intensity 0.6), `SunRaysEffect` (Intensity 0.25), `ColorCorrectionEffect` (Contrast 0.12, Saturation 0.2) & `Atmosphere` (Density 0.25).

### 9.3 Statische XML Model-Struktur (`src/Workspace/Map.rbxmx`)
- Alle 3D-Knoten, Inseln, Wege & Prompts sind als statisches Roblox XML Model (`Map.rbxmx`) vorkompiliert, wodurch das gesamte Startdorf direkt beim Öffnen in Roblox Studio im 3D-Editor geladen wird.

---

## 📌 10. Detaillierte System- & Design-Spezifikationen (Gap-Check Phase A)

### 10.1 Terrain & Zonen-Architektur (3D-Welt)
- **Zone 1 (Elementar-Wiese)**: Level 1–9 | `350x6x350 Studs` bei `(0, -3, 0)` | Spawn bei `(0, 5, 0)`. Enthält 7 Erz-Knoten (Erd-Topas, Feuer-Rubin, Ozean-Saphir).
- **Zone 2 (Kristall-Schlucht)**: Level 10–19 | `400x15x300 Studs` bei `(0, 10, 350)` | Kristalline Schlucht mit 8 Erz-Knoten (Wind-Smaragd, Blitz-Amethyst).
- **Zone 3 (Koloss-Gipfel)**: Level 20–25 | `300x40x300 Studs` bei `(0, 50, 700)` | Berg-Plateau mit 6 Void-Knoten + Boss-Arena `160x4x160` bei `(0, 50, 850)`.

### 10.2 UI Design System & Farbcodes (Modern Glassmorphism)
- **Hintergrund**: Dunkelblau/Obsidian `Color3.fromRGB(15, 23, 42)` (Slate-900), `BackgroundTransparency = 0.25`.
- **Rahmen / Akzent**: Edles Gold `Color3.fromRGB(212, 175, 55)` (`UIStroke`, Thickness = 2).
- **Magische Akzente**: Aether-Cyan `Color3.fromRGB(56, 189, 248)`.
- **Typografie**: Header `Enum.Font.GothamBold`, Body `Enum.Font.Gotham`. Text-Farbe `Color3.fromRGB(248, 250, 252)`.
- **Responsive Layout**: Zentriert (`AnchorPoint = Vector2.new(0.5, 0.5)`), `UIScale` dynamisch skaliert für Mobile Screens (<600px Breite).

### 10.3 Kamera-System
- **Standard Third-Person**: Basis-Abstand 14 Studs, FOV 70, Vertical Height Offset 2.5 Studs.
- **Zoom-Grenzen**: Min 6 Studs, Max 28 Studs.
- **Kollision**: Raycast Occlusion Detection schiebt Kamera bei Wandkontakt automatisch nach vorne.
- **Boss-Kamera**: Automatisches Zoom-Out auf 24 Studs & FOV 75 beim Betreten des `BossQueueCircle`.

### 10.4 Charakter-Grundbewegung & Steuerung
- **Basis WalkSpeed**: 16 Studs/s | **JumpPower**: 50 Studs/s.
- **Sprint-Mechanik**: `LeftShift` (PC) / Touch-Sprint-Button (Mobile) schaltet Sprint um (+30% WalkSpeed -> 20.8 Studs/s).

### 10.5 Zonen-Übergänge & Barrieren
- **Nahtlose Welt**: Keine Loading-Screens. Zonen sind durch magische Energie-Barrieren getrennt.
- **Level-Gating**: Zone 2 Barriere prüft `Level >= 10`. Zone 3 Barriere prüft `Level >= 20`. Bei Kontakt ohne Mindestlevel erfolgt sanfter Knockback (15 Studs) mit Hinweis-UI.

### 10.6 Erz-Knoten Respawn-Zeiten
- **Erd-Topas (Gewöhnlich)**: 12 Sekunden Respawn.
- **Feuer-Rubin / Ozean-Saphir / Wind-Smaragd (Selten)**: 25 Sekunden Respawn.
- **Blitz-Amethyst (Episch)**: 45 Sekunden Respawn.
- **Void-Kristall (Mythisch)**: 90 Sekunden Respawn.

### 10.7 Server-Kapazität & Matchmaking
- **Max. Spieler pro Server**: 12 Spieler (optimiert für 60 FPS Mobile Performance).
- **Boss-Matchmaking**: In-Server Warteschlange über 60–120s Sensorkreis (`BossQueueCircle`).

### 10.8 Fehlerfall-Behandlung & Datensicherheit
- **ProfileService Auto-Save**: Speicherung alle 30s + Session-Locking verhindert Datenverlust bei Disconnects.
- **Trading-Abbruch**: Bei Trennung während eines Trades wird der Handel storniert und Items werden sicher zurückerstattet.
- **Boss-Disconnect**: Spieler wird ohne Verlust von Items/Essenz aus der Warteschlange/Kampf entfernt.

---

## 📌 11. Spieler-Tod & Respawn-System
- **Kein Item- oder Essenz-Verlust**: Spieler behalten alle gesammelten Erze, Tränke, Waffen und Währung.
- **Buff-Erhalt**: Laufende temporäre Trank-Buffs bleiben beim Tod voll aktiv.
- **Respawn**: Nach 3 Sekunden automatischer Respawn am Dorfplatz (Zone 1 Spawn) mit 100% HP.
- **Boss-Arenen-Schutz**: Stirbt ein Spieler in der Boss-Arena, spawnt er am sicheren Arenarand außerhalb der Gefahrenzone.

---

## 📌 12. First-Time User Experience (FTUE / Starter-Quests)
- **3-Stufige Starter-Questreihe**:
  1. **Schritt 1: Erster Ertrag** – Baue 3x `Erd-Topas` ab. *(Belohnung: 50 Aether-Essenz)*
  2. **Schritt 2: Handelsbeziehung** – Verkaufe 1x beliebiges Erz beim Alchemie-Händler. *(Belohnung: 50 Aether-Essenz)*
  3. **Schritt 3: Erste Alchemie** – Crafte 1x beliebiges Rezept am Kessel-Altar. *(Belohnung: 50 Aether-Essenz)*
- **UI-Anzeige**: Elegantes Mini-Glassmorphism-Panel am oberen rechten Bildschirmrand mit Live-Fortschritt.

---

## 📌 13. Dynamisches Audio- & Sound-Design
- **Zonen-Hintergrundmusik (BGM)**:
  - Zone 1 (Elementar-Wiese): Friedliche, magische Fantasy-Flöten & Harfen.
  - Zone 2 (Kristall-Schlucht): Mystische, atmosphärische Glockenspiel-Klänge.
  - Zone 3 (Koloss-Gipfel): Düstere, drängende Streicher & Windgeräusche.
  - Boss-Arena (Kristall-Koloss): Epische Orchester-Choräle (Elden Ring / Souls-Style).
- **3D Positional SFX**:
  - Kristall-Mining: Kristallines Klopfen mit variiertem Pitch (`math.random(92, 108)/100`).
  - Kessel-Brodeln: Sanftes Blubbern & magisches Gong-Signal bei erfolgreichem Craft.
  - Waffenschwünge & Treffer: Wuchtige Slash- & Impact-Sounds.
  - UI: Feine, zarte Glass-Klickgeräusche für GlassButton.

---

## 📌 14. Umfassender Anti-Exploit- & Hardening-Katalog
- **Network Rate Limiting (Token Bucket)**:
  - Max. 12 Events/Sekunde für Angriffe (`AttackSwing_RE`).
  - Max. 2 Requests/Sekunde für Mining (`HarvestOre_RF`).
  - Max. 5 Requests/Sekunde für Crafting & Shop (`CraftRecipe_RF`, `SellItems_RF`).
- **Payload-Sanitization**:
  - Alle numerischen Parameter werden strikt auf positive Ganzzahlen (`typeof(n) == "number" and n == math.floor(n) and n > 0 and n <= 100000`) validiert.
  - String-IDs werden gegen statische Whitelists (`OresConfig`, `RecipesConfig`, `WeaponsConfig`) abgeglichen.
- **Anti-Speedhack & Anti-Fly**:
  - Serverseitiger Positionsvergleich: Maximale Bewegung $\le 45$ Studs/s ohne legitimen Dash-Skill.
  - Raycast-Wandprüfung für Teleport-Skills (`Anti-Noclip`).
- **Graceful Server Shutdown**:
  - `game:BindToClose` sichert alle offenen Profile innerhalb von 25 Sekunden transaktional ab.


