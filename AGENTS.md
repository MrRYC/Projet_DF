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
├── ActionZone                                 # cartes jouées + IntentMarkers (2 lanes, positions déterministes, réordonnancement manuel au drag gauche)
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
   (clic droit = flip → augment). Une carte déjà en zone se **réordonne au clic gauche**
   (drag & drop dans les lanes, dépôt hors zone = annulation) et est **renvoyée en main au clic
   droit** (avec toutes les cartes jouées après elle, logique de cascade conservée).
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
- Gestion des positions de l'ActionZone fiabilisée : `calculate_action_zone_positions()` (calcul
  pur, déterministe depuis l'ordre du tableau `action_zone`), une seule tween d'agencement active
  par carte (`card_layout_tweens`), marqueurs joueur reconstruits à chaque mise à jour.
  Les marqueurs **ennemis** ne sont mis à jour qu'en fin de cascade (rappel sur `finished` de la
  dernière tween), car `update_markers_position` lit les positions réelles des cartes dans ses
  branches fin-de-tour. Comportement visuel validé à l'identique par comparaison de traces
  ancien/nouveau code (y compris « 2 attaquants fin de tour + carte déposée sur le sprite »).
- Réordonnancement manuel de l'ActionZone : drag & drop au clic gauche sur une carte en zone
  (insertion avant/après n'importe quelle carte, première/dernière positions incluses,
  annulation si dépôt hors zone). `action_zone` reste la source unique de l'ordre d'exécution —
  Fight lit le tableau inversé. Validé par banc avec souris simulée à travers les vrais
  InputManager/CardManager/ActionZone, y compris l'exécution d'une séquence réordonnée au Fight.
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
8. **`ActionZone.empty_action_zone()`** : émet `card_removed_from_action_zone(true)` sans le
   `false` de clôture (contrairement à `return_card_to_hand`) → le flag `card_removed` reste à
   `true` après un vidage et influence la branche choisie par `update_markers_position` au
   prochain ajout avec marqueurs ennemis présents.

> Corrigé le 25/11/2026 (restructuration des positions de l'ActionZone) : doublons de marqueurs
> joueur lors d'ajouts successifs (marqueurs 1+2+3… créés, dont des orphelins à des positions
> périmées) et erreur runtime « Nil into TypedArray[Vector2] » lors d'ajouts rapprochés (cartes
> récentes sans `starting_position` au moment du recalcul des marqueurs ennemis).

### Hygiène repo
- `UI.tscn` (1,5 Mo) : 6 images `sub_resource type="Image"` **embarquées en base64** → diffs git
  massives à chaque retouche d'UI. À externaliser en `.png`.
- `Main.tscn9930065313.tmp` (1,6 Mo) à la racine : résidu d'arrêt brutal de l'éditeur, à supprimer.
- `.gitignore` vide (0 Ko) — à remplir (`.godot/`, `*.tmp`, etc.).
- **Casse mixte dans l'historique git** (constaté le 25/11/2026) : `Scripts/area/ActionZone.gd`,
  `Deck.gd`, `Discard.gd`, `PlayerHand.gd` et `Scripts/ui/UI.gd` sont **commités** avec un « S »
  majuscule (vérifié via `git ls-tree HEAD`), tandis que leurs `.uid` et le reste du projet sont
  en minuscules (`scripts/…`). Inoffensif sous Windows (FS insensible à la casse) mais fragile
  sur Linux/CI — à renormaliser (`git mv` en casse seule) lors d'un commit de nettoyage.
- Changements non commités au 25/11/2026 : `ActionZone.gd` (restructuration des positions),
  plus expérimentations en cours de l'auteur dans `UI.gd` (timer d'action à 180 s) et
  `Player.gd` (reset du combo dans `check_evasion`, version commentée dans `check_block`).

## 7. Points d'attention pour intervenir dans le code

- Ne pas casser le flux de signaux : chaque système n'agit que sur `EventBus` ; vérifier
  `Event_Bus.gd` (le doc-block indique l'émetteur et le(s) récepteur(s)) avant d'ajouter un signal.
- `ActionZone.update_markers_position` positionne les marqueurs ennemis à partir des positions
  **réelles** des cartes (`card.position`) dans ses branches fin-de-tour : ne jamais déclencher
  `update_opponent_markers` avant la fin de la cascade d'animations (d'où le rappel différé sur
  `finished` de la dernière tween dans `update_action_zone_positions`).
- Convention `ActionZone.action_zone` : **index 0 = carte la plus récente** (convention
  `insert(0)` conservée après audit des dépendances du 25/11/2026 — la retourner aurait imposé
  de réécrire `update_markers_position`, la boucle de `return_card_to_hand` et l'itération de
  `_on_incoming_damage`). Ordre d'exécution = lecture **inverse** du tableau (Fight fait
  `.reverse()`), cascade visuelle = lecture inverse aussi → le haut de la zone est toujours la
  première carte exécutée. Réordonner = manipuler les index du tableau (`get_drop_index` /
  `move_card_to_index`).
- Interactions sur une carte de l'action zone : **clic gauche = drag de réordonnancement**,
  **clic droit = retour en main** (`return_card_to_hand`, multi-cartes par index).
- L'ordre d'exécution des `_ready` de `main.tscn` (tree order : Player → TurnManager → … →
  DeckPile) est significatif : `deck_loaded` est émis par Deck **après** le spawn des opponents.
- `execute_action_phase` résout les cartes en ordre **chronologique** (insertion à l'index 0 dans
  `action_zone`, puis reverse de la copie) ; les actions IA à seuil sont intercalées par index.
- Toujours passer par les snapshots (`build_card_from_dictionaries` / `add_card_to_pile`) pour
  muter `uses`/`status` : les instances `CARD_DATA` sont recréées à chaque pioche.
- Ne pas modifier `addons/` (outils tiers). Ne pas lancer le jeu headless sans `--quit`
  (playlist musicale infinie).
