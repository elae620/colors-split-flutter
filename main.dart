import 'package:flutter/material.dart';

import 'split_box.dart';

void main() => runApp(const ColoredSplitApp());

class ColoredSplitApp extends StatelessWidget {
  const ColoredSplitApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Colored Split',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: const SplitScreen(),
      );
}

class SplitScreen extends StatefulWidget {
  const SplitScreen({super.key});

  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> {
  static const _palette = <String, Color>{
    'Bleu': Colors.blue,
    'Vert': Colors.green,
    'Orange': Colors.orange,
    'Violet': Colors.purple,
    'Rouge': Colors.red,
  };
  bool _menuOpen = false;
  bool _randomColors = true;
  Color _baseColor = Colors.blue;
  double _borderWidth = 1;
  double _borderRadius = 0;
  final List<int> _splitHistory = [];
  final List<int> _redoHistory = [];

  void _split(int id) {
    setState(() {
      _splitHistory.add(id);
      _redoHistory.clear();
    });
  }

  void _undo() {
    if (_splitHistory.isEmpty) return;
    setState(() => _redoHistory.add(_splitHistory.removeLast()));
  }

  void _redo() {
    if (_redoHistory.isEmpty) return;
    setState(() => _splitHistory.add(_redoHistory.removeLast()));
  }

  void _reset() => setState(() {
        _splitHistory.clear();
        _redoHistory.clear();
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SplitBox(
                splitHorizontal: true,
                id: 0,
                randomColors: _randomColors,
                baseColor: _baseColor,
                borderWidth: _borderWidth,
                borderRadius: _borderRadius,
                splitIds: _splitHistory.toSet(),
                onSplit: _split,
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: _HistoryControls(
                canUndo: _splitHistory.isNotEmpty,
                canRedo: _redoHistory.isNotEmpty,
                onUndo: _undo,
                onRedo: _redo,
                onReset: _reset,
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: IconButton.filledTonal(
                tooltip: 'Ouvrir le menu',
                onPressed: () => setState(() => _menuOpen = !_menuOpen),
                icon: Icon(_menuOpen ? Icons.close : Icons.menu),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              top: 0,
              bottom: 0,
              left: _menuOpen ? 0 : -300,
              width: 290,
              child: Material(
                elevation: 10,
                color: Theme.of(context).colorScheme.surface,
                child: _SettingsMenu(
                  borderWidth: _borderWidth,
                  borderRadius: _borderRadius,
                  randomColors: _randomColors,
                  baseColor: _baseColor,
                  palette: _palette,
                  onBorderWidthChanged: (value) =>
                      setState(() => _borderWidth = value),
                  onBorderRadiusChanged: (value) =>
                      setState(() => _borderRadius = value),
                  onRandomColorsSelected: () =>
                      setState(() => _randomColors = true),
                  onColorSelected: (color) => setState(() {
                    _randomColors = false;
                    _baseColor = color;
                  }),
                  onClose: () => setState(() => _menuOpen = false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryControls extends StatelessWidget {
  const _HistoryControls({
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
    required this.onReset,
  });

  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton.filledTonal(
              tooltip: 'Annuler le dernier découpage',
              onPressed: canUndo ? onUndo : null,
              icon: const Icon(Icons.undo),
            ),
            const SizedBox(width: 6),
            IconButton.filledTonal(
              tooltip: 'Rétablir le découpage',
              onPressed: canRedo ? onRedo : null,
              icon: const Icon(Icons.redo),
            ),
            const SizedBox(width: 6),
            IconButton.filledTonal(
              tooltip: 'Réinitialiser les rectangles',
              onPressed: canUndo ? onReset : null,
              icon: const Icon(Icons.restart_alt),
            ),
          ],
        ),
      );
}

class _SettingsMenu extends StatelessWidget {
  const _SettingsMenu({
    required this.borderWidth,
    required this.borderRadius,
    required this.randomColors,
    required this.baseColor,
    required this.palette,
    required this.onBorderWidthChanged,
    required this.onBorderRadiusChanged,
    required this.onRandomColorsSelected,
    required this.onColorSelected,
    required this.onClose,
  });
  final double borderWidth;
  final double borderRadius;
  final bool randomColors;
  final Color baseColor;
  final Map<String, Color> palette;
  final ValueChanged<double> onBorderWidthChanged;
  final ValueChanged<double> onBorderRadiusChanged;
  final VoidCallback onRandomColorsSelected;
  final ValueChanged<Color> onColorSelected;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Réglages',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Fermer le menu',
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text('Épaisseur des bordures : ${borderWidth.round()} px'),
              Slider(
                value: borderWidth,
                min: 0,
                max: 12,
                divisions: 12,
                label: '${borderWidth.round()} px',
                onChanged: onBorderWidthChanged,
              ),
              const SizedBox(height: 12),
              Text('Arrondi des coins : ${borderRadius.round()} px'),
              Slider(
                value: borderRadius,
                min: 0,
                max: 48,
                divisions: 24,
                label: '${borderRadius.round()} px',
                onChanged: onBorderRadiusChanged,
              ),
              const SizedBox(height: 20),
              Text('Couleurs', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Aléatoire'),
                    selected: randomColors,
                    onSelected: (_) => onRandomColorsSelected(),
                    avatar: const Icon(Icons.shuffle, size: 18),
                  ),
                  ...palette.entries.map((entry) => ChoiceChip(
                        label: Text(entry.key),
                        selected: !randomColors && baseColor == entry.value,
                        onSelected: (_) => onColorSelected(entry.value),
                        avatar: CircleAvatar(
                          backgroundColor: entry.value,
                          radius: 8,
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      );
}

