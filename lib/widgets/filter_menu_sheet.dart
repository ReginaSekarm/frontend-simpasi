import 'package:flutter/material.dart';

class FilterMenuSheet extends StatefulWidget {
  final String initialAge;
  final List<String> initialIngredients;

  const FilterMenuSheet({
    super.key,
    this.initialAge = 'Semua',
    this.initialIngredients = const [],
  });

  @override
  State<FilterMenuSheet> createState() => _FilterMenuSheetState();
}

class _FilterMenuSheetState extends State<FilterMenuSheet> {
  static const Color primaryRed  = Color(0xFFD45060);
  static const Color textBlack   = Color(0xFF000000);
  static const Color textBlack71 = Color(0xB5000000);
  static const Color textBlack50 = Color(0x80000000);
  static const Color dividerGrey = Color(0xFFD9D9D9);
  static const Color chipBorder  = Color(0xFF8F8F8F);
  static const Color chipBg      = Color(0x33D9D9D9);

  final List<String> _ages = const [
    'Semua',
    '6 Bulan',
    '7 - 8 Bulan',
    '9 - 11 Bulan',
    '12 Bulan +',
  ];

  final List<_Ingredient> _ingredients = const [
    _Ingredient('Ayam', '🍗'),
    _Ingredient('Daging', '🥩'),
    _Ingredient('Ikan', '🐟'),
    _Ingredient('Seafood', '🦐'),
    _Ingredient('Telur', '🥚'),
    _Ingredient('Umbi-\numbian', '🍠'),
    _Ingredient('Sayuran', '🥦'),
    _Ingredient('Buah', '🍌'),
    _Ingredient('Kacang-\nkacangan', '🥜'),
  ];

  late int _selectedAge;
  final Set<int> _selectedIngredients = {};

  // STATE UNTUK DRAG DINAMIS
  bool _isDragging = false;
  double _sheetFraction = 0.9;

  String _normIng(String s) => s.replaceAll('\n', '').trim();

  @override
  void initState() {
    super.initState();

    // Restore usia yang dipilih
    final ageIdx = _ages.indexOf(widget.initialAge);
    _selectedAge = ageIdx >= 0 ? ageIdx : 0;

    // Restore bahan yang dipilih
    final initialNorm = widget.initialIngredients.map(_normIng).toSet();
    for (int i = 0; i < _ingredients.length; i++) {
      if (initialNorm.contains(_normIng(_ingredients[i].name))) {
        _selectedIngredients.add(i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedContainer(
      height: screenHeight * _sheetFraction,
      duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // DRAG HANDLE (DIAM / TIDAK IKUT SCROLL)
            GestureDetector(
              onVerticalDragStart: (details) {
                setState(() => _isDragging = true);
              },
              onVerticalDragUpdate: (details) {
                setState(() {
                  _sheetFraction -= details.delta.dy / screenHeight;
                  if (_sheetFraction > 1.0) _sheetFraction = 1.0;
                  if (_sheetFraction < 0.4) _sheetFraction = 0.4;
                });
              },
              onVerticalDragEnd: (details) {
                setState(() {
                  _isDragging = false;
                  if (_sheetFraction > 0.95) {
                    _sheetFraction = 1.0;
                  } else if (_sheetFraction < 0.75) {
                    Navigator.of(context).pop();
                  } else {
                    _sheetFraction = 0.9;
                  }
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 27, bottom: 17),
                alignment: Alignment.center,
                child: Container(
                  width: 80,
                  height: 5,
                  decoration: BoxDecoration(
                    color: dividerGrey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),

            // KONTEN YANG BISA DI-SCROLL
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------- Title ----------
                      Padding(
                        padding: const EdgeInsets.only(left: 1),
                        child: Text(
                          'Filter Menu',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            height: 29 / 24,
                            color: textBlack,
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),

                      // ---------- Divider ----------
                      Container(height: 1, color: dividerGrey),
                      const SizedBox(height: 21),

                      // ---------- Label: Usia ----------
                      Text(
                        'Usia',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 19 / 16,
                          color: textBlack,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ---------- Age chips (3 atas, 2 bawah) ----------
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildAgeChip(0)),
                              const SizedBox(width: 13),
                              Expanded(child: _buildAgeChip(1)),
                              const SizedBox(width: 13),
                              Expanded(child: _buildAgeChip(2)),
                            ],
                          ),
                          const SizedBox(height: 19),
                          Row(
                            children: [
                              Expanded(child: _buildAgeChip(3)),
                              const SizedBox(width: 13),
                              Expanded(child: _buildAgeChip(4)),
                              const SizedBox(width: 13),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 19),

                      // ---------- Label: Bahan Makanan ----------
                      Text(
                        'Bahan Makanan',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 19 / 16,
                          color: textBlack,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ---------- Grid 3x3 bahan ----------
                      _buildIngredientGrid(),

                      const SizedBox(height: 33),

                      // ---------- Divider ----------
                      Container(height: 1, color: dividerGrey),
                      const SizedBox(height: 16),

                      // ---------- Buttons ----------
                      Row(
                        children: [
                          Expanded(child: _buildResetButton()),
                          const SizedBox(width: 24),
                          Expanded(child: _buildApplyButton()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= AGE CHIP =================
  Widget _buildAgeChip(int index) {
    final selected = _selectedAge == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedAge = index),
      child: Container(
        height: 35,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? primaryRed : chipBg,
          border: selected ? null : Border.all(color: chipBorder, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          _ages[index],
          maxLines: 1,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 19 / 16,
            color: selected ? Colors.white : textBlack50,
          ),
        ),
      ),
    );
  }

  // ================= GRID BAHAN =================
  Widget _buildIngredientGrid() {
    return Column(
      children: [
        for (int row = 0; row < 3; row++) ...[
          if (row > 0) const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildIngredientCard(row * 3 + 0),
              _buildIngredientCard(row * 3 + 1),
              _buildIngredientCard(row * 3 + 2),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildIngredientCard(int index) {
    final selected = _selectedIngredients.contains(index);
    final item = _ingredients[index];
    final isTwoLine = item.name.contains('\n');

    return GestureDetector(
      onTap: () => setState(() {
        if (selected) {
          _selectedIngredients.remove(index);
        } else {
          _selectedIngredients.add(index);
        }
      }),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: selected ? primaryRed.withValues(alpha: 0.12) : chipBg,
          border: Border.all(
            color: selected ? primaryRed : chipBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(
              item.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isTwoLine ? 12 : 14,
                fontWeight: FontWeight.w500,
                height: isTwoLine ? 15 / 12 : 17 / 14,
                color: textBlack71,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= RESET BUTTON =================
  Widget _buildResetButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedAge = 0;
            _selectedIngredients.clear();
          });
        },
        borderRadius: BorderRadius.circular(10),
        splashColor: Colors.black.withValues(alpha: 0.05),
        highlightColor: Colors.black.withValues(alpha: 0.02),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: chipBorder, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Reset',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 19 / 16,
              color: textBlack50,
            ),
          ),
        ),
      ),
    );
  }

  // ================= TERAPKAN BUTTON =================
  Widget _buildApplyButton() {
    return Material(
      color: primaryRed,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop({
            'age': _ages[_selectedAge],
            'ingredients':
                _selectedIngredients.map((i) => _ingredients[i].name).toList(),
          });
        },
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: Text(
            'Terapkan',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 19 / 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ================= HELPER CLASS =================
class _Ingredient {
  final String name;
  final String emoji;
  const _Ingredient(this.name, this.emoji);
}