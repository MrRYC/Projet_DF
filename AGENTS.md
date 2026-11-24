# AGENTS.md — Mémoire projet « Project_DF / Daily Fighters »

> Généré le 24/11/2026 après audit complet du code. À maintenir lors des évolutions majeures.

## 1. Vue d'ensemble

**Concept** : deckbuilder de combat (« Slay the Spire × jeu de combat »). Le joueur enchaîne des
séquences de coups de boxe sous forme de cartes, contre un « matchup » d'adversaires, avec un
**timer d'action de 15 secondes** par tour. Les cartes peuvent être retournées (clic droit) pour
révéler un **augment** (Block / Dodge / Feint) joué sur soi-même.

- **Moteur** : Godot **4.7.2** (renderer Forward Plus), GDScript uniquement, 2D.
- **Fenêtre** : 1920×1080 fixe, non redimensionnable, vsync désactivé.
- **Inputs** : souris seule (aucune action mappée dans InputMap ; tout passe par `_input` + raycasts).
- **Nom de build** : `Daily Fighters` (assembly dotnet), dépôt GitHub : `MrRYC/Projet_DF`, branche `main`.
- **Pas de système de sauvegarde** ; fin de matchup ou mort → `get_tree().quit()` brut.

## 2. Commandes utiles

Binaire : `D:/Godot/Godot_v4.7.2-stable_win64.exe` (déclaré dans `opencode.json` pour le LSP
`godot-lsp-bridge`, extensions `.gd` / `.gdshader`).

```powershell
# Lancer le jeu
& "D:\Godot\Godot_v4.7.2-stable_win64.exe" --path .

# Smoke-test headless (charge autoloads + main scene, affiche les erreurs de scripts)
& "D:\Godot\Godot_v4.7.2-stable_win64.exe" --headless --quit --path .
```

Le check headless du 24/11/2026 : **aucune erreur de script**, uniquement une alerte bénigne
`Capture not registered: 'signal_lens'` à la fermeture (plugin Signal_Lens).

## 3. Autoloads (`project.godot`)

| Autoload | Fichier | Rôle |
|---|---|---|
| `Global` | `scripts/global/_Global.gd` | Constantes de timing (vitesses d'animation, intervalles de pioche) + `global_score` |
| `EventBus` | `scripts/global/Event_Bus.gd` | **Tous** les signaux du jeu, commentés « signals from X to Y » |
| `SignalLens` | addon Signal_Lens | Debug de signaux (éditeur) |

## 4. Architecture — `main.tscn`

```
Main (Node2D)
├── Player (Player.tscn, class PLAYER)         # group "Player"
│   ├── PlayerArea2D (layer 15 / mask 8) + Image (Sprite2D)
│   ├── DamagePreviewManager                   # préview dégâts entrants → main + HP
│   ├── DefensiveActionsController (DefenseController)  # block/dodge/feint charges
│   ├── HealthPips (Control, _draw custom)     # barre de vie en pips + preview clignotante
│   │   └── DefensivePips                      # pips block/dodge/feint + pips cassés
├── TurnManager                                # orchestrateur de tour + phase d'exécution
│   └── SlotEffectManager (SlotEffectRegistry, static)  # application des effets d'augments
├── InputManager                               # souris → intersect_point → dispatch par mask
├── CardManager                                # drag & drop, destinations de piles
├── OpponentManager                            # spawn des sets, IA, markers, dim, preview
├── PlayerHand                                 # positionnement de la main, drop index
├── ActionZone                                 # cartes jouées + IntentMarkers (2 lanes)
├── Piles
│   ├── DeckPile (Deck.gd)     # pioche + création des instances de Card.tscn
│   ├── WoundPile (Wound.gd)   # cartes « broken »
│   ├── DiscardPile (Discard.gd)
│   └── ExhaustPile (Exhaust.gd)
├── UserInterface (UI.tscn)    # BattleHUD : ActionTimer ring, FightButton, EmptyActionZoneButton,
│                              # TurnLabel, ComboMeter ; TrackHUD : TrackLabel + MiniEqualizer
└── SoundManager                # playlist aléatoire du dossier assets/audio/background
```

### Flux de jeu (boucle opérationnelle)

1. `Deck._ready` → `load_player_deck()` (9 cartes de `PLAYERDECK.CARDS`) → `deck_loaded` →
   **HP joueur = taille du deck** → `new_turn(true)`.
2. Pioche de 6 cartes (`HAND_DRAW_INTERVAL`), puis `activate_action_timer` → UI lance le timer 15 s.
3. Le joueur drag des cartes : sur un **adversaire** (attaque, carte face recto) ou sur **soi-même**
   (clic droit = flip → augment). Retour en main possible (cascade au-dessus de la carte cliquée).
4. Les adversaires tirent une intent aléatoire parmi `action_1..4` (`OPPONENT_DATA`) ; les
   attaquants génèrent des `IntentMarker` positionnés dans les lanes de l'ActionZone selon leur
   `attack_threshold` (rouge) ou fin de tour (jaune).
5. `Fight` → `TurnManager.execute_action_phase()` : résolution des cartes en ordre chronologique
   (attaque directe ou effet d'augment via `SlotEffectManager`), actions IA à seuil intercalées,
   puis morts (overkill si `extra_damage >= overkill_limit`) et actions IA de fin de tour.
6. `new_turn` : les cartes quittent main/action zone vers discard (ou exhaust/wound selon
   `side_effect` + `uses`), block/dodge/feint reset, re-pioche. Deck vide → reshuffle discard.
7. Matchup vide → `matchup_over` → print du score + quit. Mort du joueur → quit.

### Données (`scripts/resources/` + `entities/`)

| Source | Contenu | Statut |
|---|---|---|
| `PlayerDeck.gd` (`PLAYERDECK.CARDS`) | deck réel : 9 cartes boxe, IDs uniques `_01..` | utilisé |
| `AugmentDB.gd` (`AUGMENTDB.AUGMENTS`) | Block / Dodge (inactivate, 2 uses) / Feint (exhaust, 1 use) | utilisé |
| `OpponentSets.gd` (`OPPONENTS_SETS.SETS`) | 7 sets → 2 archétypes | utilisé |
| `opponents/*.tres` (`OPPONENT_DATA`) | Deb (5 HP, dmg 1, fin de tour) ; Jaxx (6 HP, dmg 2, seuil 3) | utilisé |
| `ComboDB.gd` (`Combo` / `BOXING_COMBO`) | 16 combos de boxe | **NON branché** |
| `CardDB.gd` (`CARD_DB.CARDS`) | doublon générique de PlayerDeck | **non utilisé** |
| `AugmentData.gd` (`AUGMENT_DATA`) | classe augment Node2D | **non utilisé** |

Les cartes instanciées ne portent qu'un **snapshot** (`id`, `status`, `slot_number`,
`effect_per_slot` avec `uses`) ; les définitions complètes sont rechargées depuis `PLAYERDECK` à
chaque pioche. Un augment épuisé avec `side_effect = "inactivate"` rend la carte visuellement inactive.

## 5. Conventions de nommage et de code

- **Commentaires en français**, séparateurs de sections :
  `#############################################################################` / `#              TITRE             #`.
- **Ordre canonique d'un script** : `#constantes` → `#variables de référence` (`@onready var x_ref :
  Type = $"../Chemin"`, suffixe `_ref`) → `#variables du script` → `_ready()` → sections métier →
  bannière `SIGNALS INTERCEPTION` avec handlers `_on_<nom_du_signal>`.
- **`class_name` en SCREAMING_CASE** pour entités et data : `PLAYER`, `OPPONENT`, `CARD_DATA`,
  `OPPONENT_DATA`, `OPPONENTS_SETS`, `PLAYERDECK`, `AUGMENTDB`, `CARD_DB`, `MARKER`.
  **PascalCase** pour composants réutilisables : `DefenseController`, `HealthPips`,
  `DefensivePips`, `SlotEffectRegistry`, `DamagePreviewManager`. (Incohérence connue : `Combo`.)
- **Communication inter-nœuds : quasi exclusivement via `EventBus`** (connect dans `_ready`,
  handlers `_on_*`). Références directes uniquement parent↔enfant ou voisins immédiats (`$"../"`).
  Quelques signaux restent non typés (`signal hovered(card)`).
- **Données de jeu** : dictionaries `const` dans des classes `extends Resource` ; ressources
  exportées en `.tres` (uniquement `OPPONENT_DATA` pour l'instant).
- **Typage** : signatures `-> void` / `: int` quasi systématique ; quelques vars volontairement non
  typées (`var target`, `var action_type`, `var card`).
- **Scènes** : fichiers `PascalCase.tscn` dans `scenes/` (sauf `main.tscn`), référencées par
  `uid://` dans les `ext_resource`. Nœuds `PascalCase`, groupes : `"Player"`, `"Opponent"`, `"Entity"`.
- **Collision layers/masks** (règle effective) : `1` = cartes, `2` = intent markers, `4` = piles,
  entités = layer `15` / mask `8`. Les constantes sont documentées en tête de `InputManager.gd`.

## 6. État d'avancement (24/11/2026)

### Fonctionnel
- Boucle de combat complète : pioche → timer → drag & drop → résolution → fin de tour → re-pioche.
- Drag & drop souris avec raycasts `intersect_point`, carte au premier plan par `z_index`,
  réordonnancement dans la main par drop index, cascade de retour en main.
- Piles complètes (Deck/Discard/Wound/Exhaust) avec snapshot des données mutables et reshuffle
  automatique du discard quand le deck vide.
- Augments : Block/Dodge/Feint, `uses` persistants entre tours via snapshots, side effects
  `inactivate` / `exhaust` / `wound`.
- IA adversaire : behavior `ATTACK_AT_THRESHOLD` / `ATTACK_AT_THE_END`, intents
  (ATTACK, SIMPLE/DUPLE_BLOCK, CANCEL_COMBO, BUFF, FAILED_ATTACK), blocks, overkill.
- Préviews complètes : dégâts HP clignotants (joueur + ennemis), pips défensifs, pips de block
  cassés par les cartes visées, cartes de main ciblées par les coups entrants, dim/highlight
  entités au survol des markers.
- Statuts de cartes INTACT/FRACTURED/BROKEN avec visuels + fracture aléatoire en cas de coup reçu.
- Audio : playlist aléatoire (mp3) sur bus `Music` (SpectrumAnalyzer présent), MiniEqualizer
  dessiné en `_draw`, label de track.

### Incomplet / volontairement temporaire
- **Combos non implémentés** : `ComboDB` (16 combos) n'est référencé nulle part ;
  `PlayerHand.combo_cards` n'est jamais rempli ; `drop_combo_cards` ne fait rien ; les cartes des
  combos (Esquive, Feinte, Rear_Cross…) n'existent pas dans `PLAYERDECK`. `combo_meter` n'est
  qu'un compteur ; `multiplicator` (UI) inutilisé.
- **Feint** : `SlotEffectManager` case `"Feint"` → simple print. `try_to_feint()` jamais appelé.
- **Esquive incohérente** : `Player.check_evasion()` lit `get_dodge()` sans consommer la charge
  (`try_to_evade()` jamais appelé).
- IA `BUFF` / `FAILED_ATTACK` → prints. Animations de combat → prints/commentaires à traiter.
- Fin de partie : `get_tree().quit()` sans écran ; score seulement `print`.
- `show_pile()` de toutes les piles → prints console (pas d'overlay).
- Code mort : `card_db_ref`, `destination_pile`, `is_end_of_turn` (CardManager), signal
  `remove_card` (ActionZone), `update_max_timer_value`, `multiplicator` (UI),
  `defensive_action_queue` (DefensivePips), `draw_round_rect` (MiniEqualizer),
  `AugmentData.gd`, `CardDB.gd`. Addons `Conductor` (typo `condcutor.gd`) et `AnimatedShape2D`
  présents mais non activés/non utilisés.
- `DamagePreviewManager` : calcul de preview marqué « provisoire » ; `incoming_hits` « à voir si utile ».

### Bugs ouverts (priorité au gameplay)
1. **`SlotEffectManager.gd`** : case `"Dodge"` appelle `add_block()` au lieu de `add_dodge()` →
   l'augment Dodge donne un block (incohérent avec les pips affichés).
2. **`ActionZone.check_attack_turn_order()`** : `elif` inatteignable (var locale réinitialisée à 0
   à chaque appel) → retourne l'ordre du *dernier* marker au lieu du *max* → mauvais
   `attack_order` des attaquants de fin de tour quand plusieurs seuils coexistent.
3. **`OpponentManager._ready`** : `spawn_random_opponent_set(0, 5)` alors que `SETS` a 7 clés →
   le set `"Trio_2"` n'est jamais tiré.
4. **`Deck.draw()`** : si deck **et** discard vides (cartes en wound/exhaust), `pop_front()` sur
   array vide → `null` → crash dans `create_card_in_hand`.
5. **`CardManager.finish_drag()`** : carte relâchée dans la main reste à `scale 1.05`
   (pas de `update_card_size` sur le chemin `move_card_to_index`).
6. **`project.godot`** : plugin déclaré 2× (`Signal_Lens` et `signal_lens`, casse différente).
7. **`Discard.gd` / `Exhaust.gd` / `Wound.gd`** : constante inutilisée
   `CARD_SCENE_PATH = "res://Scenes/Card.tscn"` — casse incorrecte, casserait sous Linux si utilisée.

### Hygiène repo
- `UI.tscn` (1,5 Mo) : 6 images `sub_resource type="Image"` **embarquées en base64** → diffs git
  massives à chaque retouche d'UI. À externaliser en `.png`.
- `Main.tscn9930065313.tmp` (1,6 Mo) à la racine : résidu d'arrêt brutal de l'éditeur, à supprimer.
- `.gitignore` vide (0 Ko) — à remplir (`.godot/`, `*.tmp`, etc.).
- Changements non commités au 24/11/2026 : `project.godot` (bump 4.6 → 4.7),
  `DamagePreviewManager.gd` (1 ligne), `opencode.json` non suivi.

## 7. Points d'attention pour intervenir dans le code

- Ne pas casser le flux de signaux : chaque système n'agit que sur `EventBus` ; vérifier
  `Event_Bus.gd` (le doc-block indique l'émetteur et le(s) récepteur(s)) avant d'ajouter un signal.
- L'ordre d'exécution des `_ready` de `main.tscn` (tree order : Player → TurnManager → … →
  DeckPile) est significatif : `deck_loaded` est émis par Deck **après** le spawn des opponents.
- `execute_action_phase` résout les cartes en ordre **chronologique** (insertion à l'index 0 dans
  `action_zone`, puis reverse de la copie) ; les actions IA à seuil sont intercalées par index.
- Toujours passer par les snapshots (`build_card_from_dictionaries` / `add_card_to_pile`) pour
  muter `uses`/`status` : les instances `CARD_DATA` sont recréées à chaque pioche.
- Ne pas modifier `addons/` (outils tiers). Ne pas lancer le jeu headless sans `--quit`
  (playlist musicale infinie).
