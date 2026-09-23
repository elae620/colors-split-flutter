# Documentation — Colored Split

## Objectif de l’application

Cette application Flutter permet de construire une composition de rectangles colorés. L’utilisateur appuie sur un rectangle pour le diviser en deux. Chaque nouveau rectangle peut ensuite être divisé à son tour.

L’application offre aussi des réglages visuels (couleurs, bordures et arrondi) ainsi qu’un historique des découpages.

## Lancer le projet

Depuis le dossier du projet :

```bash
flutter run
```

Pour lancer les tests :

```bash
flutter test
```

## Structure des fichiers

| Fichier | Rôle |
| --- | --- |
| `lib/main.dart` | Point d’entrée, écran principal, menu de réglages et historique. |
| `lib/split_box.dart` | Widget récursif qui affiche et découpe les rectangles. |
| `test/widget_test.dart` | Tests des découpages, de l’annulation, du rétablissement, de la réinitialisation et de l’ouverture du menu. |
| `pubspec.yaml` | Configuration Flutter et dépendances du projet. |

## Éléments visibles à l’écran

### Zone de rectangles

La plus grande partie de l’écran est la zone de travail. Elle contient initialement un seul rectangle.

- Un appui sur un rectangle le remplace par deux rectangles.
- Les séparations alternent : une séparation côte à côte, puis une séparation haut/bas, et ainsi de suite.
- Un rectangle qui a déjà été séparé ne peut plus être directement cliqué : ses rectangles enfants prennent le relais.

### Bouton menu — en haut à gauche

L’icône de menu ouvre le panneau latéral de réglages. Lorsque le panneau est ouvert, l’icône devient une croix. Le panneau possède également son propre bouton de fermeture.

### Boutons d’historique — en haut à droite

| Icône | Action | Disponibilité |
| --- | --- | --- |
| ↶ | Annule le dernier découpage effectué. | Active après au moins un découpage. |
| ↷ | Rétablit le dernier découpage annulé. | Active après une annulation. |
| ↻ | Réinitialise la zone pour revenir à un seul rectangle. | Active après au moins un découpage. |

Après une annulation, effectuer un nouveau découpage supprime les actions qui pouvaient encore être rétablies. C’est le comportement habituel d’un historique annuler/rétablir.

### Panneau « Réglages »

Le panneau arrive depuis la gauche et contient les contrôles suivants :

| Contrôle | Valeurs | Effet |
| --- | --- | --- |
| Curseur « Épaisseur des bordures » | 0 à 12 px | Change l’épaisseur de la bordure noire de tous les rectangles. |
| Curseur « Arrondi des coins » | 0 à 48 px | Change le rayon des coins de tous les rectangles. La valeur 0 donne des angles droits. |
| Choix « Aléatoire » | Activé ou désactivé | Donne une couleur différente à chaque rectangle. |
| Bleu, Vert, Orange, Violet, Rouge | Une couleur à sélectionner | Applique à tous les rectangles des nuances de la couleur sélectionnée. |
| Bouton ✕ | — | Ferme le panneau de réglages. |

Les réglages sont globaux : ils modifient les rectangles déjà affichés et les futurs rectangles créés par découpage.

## Fonctionnement du code

### 1. Démarrage de l’application

La fonction `main()` appelle `runApp(const ColoredSplitApp())`. `ColoredSplitApp` crée le `MaterialApp` et affiche `SplitScreen` comme écran principal.

### 2. État central : `SplitScreen`

`SplitScreen` est un `StatefulWidget`. Son état (`_SplitScreenState`) est le point central de l’application et conserve :

| Variable | Signification |
| --- | --- |
| `_menuOpen` | Indique si le panneau latéral est ouvert. |
| `_randomColors` | Indique si le mode de couleurs aléatoires est actif. |
| `_baseColor` | Couleur de base du mode palette. |
| `_borderWidth` | Épaisseur actuelle de la bordure. |
| `_borderRadius` | Rayon actuel des coins. |
| `_splitHistory` | Liste ordonnée des rectangles qui ont été séparés. |
| `_redoHistory` | Liste des découpages annulés et donc rétablissables. |

À chaque modification, `setState()` reconstruit l’interface avec les nouvelles valeurs. C’est pourquoi les réglages sont visibles immédiatement.

### 3. Historique des découpages

Lorsqu’un rectangle est cliqué, `SplitBox` appelle `onSplit(id)`, qui correspond à la méthode `_split` de l’écran principal.

1. L’identifiant du rectangle est ajouté à `_splitHistory`.
2. `_redoHistory` est vidé, car une nouvelle action crée une nouvelle branche d’historique.
3. L’écran est reconstruit.

`_undo()` retire le dernier identifiant de `_splitHistory` et le place dans `_redoHistory`. `_redo()` fait exactement l’opération inverse. `_reset()` vide les deux listes.

### 4. Construction récursive : `SplitBox`

`SplitBox` est un `StatelessWidget` récursif. Il reçoit notamment son `id`, l’ensemble `splitIds` et les réglages visuels.

- Si son `id` n’est pas dans `splitIds`, il affiche un rectangle cliquable (`GestureDetector` + `Container`).
- Si son `id` est dans `splitIds`, il crée deux nouveaux `SplitBox` enfants.
- Quand `splitHorizontal` est vrai, les deux enfants sont placés dans un `Row` (gauche/droite).
- Sinon, ils sont placés dans un `Column` (haut/bas).

Les identifiants forment un arbre binaire : le rectangle racine utilise `0`, puis les enfants du rectangle `id` utilisent `id * 2 + 1` et `id * 2 + 2`. Cette règle permet de reconstruire exactement la même disposition à partir de l’historique, sans devoir stocker des widgets.

### 5. Couleurs et décoration

La propriété privée `_color` de `SplitBox` détermine la couleur à afficher.

- En mode aléatoire, la teinte HSL est calculée à partir de l’identifiant du rectangle. Chaque rectangle garde donc une couleur distincte et stable pendant les reconstructions de l’écran.
- En mode palette, la teinte de base sélectionnée est conservée, mais la luminosité varie selon l’identifiant. Les rectangles obtiennent donc différentes nuances de la même couleur.

Le `BoxDecoration` du rectangle applique ensuite la couleur, la bordure noire et `BorderRadius.circular(borderRadius)` pour l’arrondi des coins.

## Résumé du parcours utilisateur

1. L’utilisateur arrive sur un rectangle unique.
2. Il touche un rectangle pour le diviser.
3. Il peut répéter l’opération sur n’importe quel rectangle visible.
4. Il ouvre le menu pour modifier les couleurs, les bordures ou l’arrondi.
5. Il utilise les boutons en haut à droite pour annuler, rétablir ou repartir de zéro.
