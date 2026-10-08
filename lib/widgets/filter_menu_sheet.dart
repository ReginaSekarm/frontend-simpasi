import 'package:flutter/material.dart';

class FilterMenuSheet extends StatefulWidget {
  const FilterMenuSheet({super.key});

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

  int _selectedAge = 0;
  final Set<int> _selectedIngredients = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- Drag handle ----------
                  Center(
                    child: Container(
                      width: 80,
                      height: 5,
                      margin: const EdgeInsets.only(top: 19, bottom: 17),
                      decoration: BoxDecoration(
                        color: dividerGrey,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),

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

                  // ---------- Age chips ----------
                  Wrap(
                    spacing: 13,
                    runSpacing: 19,
                    children: List.generate(
                      _ages.length,
                      (i) => _buildAgeChip(i),
                    ),
                  ),
                  const SizedBox(height: 35),

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
      ),
    );
  }

  // ================= AGE CHIP =================
  Widget _buildAgeChip(int index) {
    final selected = _selectedAge == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedAge = index),
      child: Container(
        width: 107,
        height: 35,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? primaryRed : chipBg,
          border: selected ? null : Border.all(color: chipBorder, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          _ages[index],
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
        for (int row = 0; row < 3; row++)
          Padding(
            padding: EdgeInsets.only(top: row == 0 ? 0 : 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int col = 0; col < 3; col++)
                  _buildIngredientCard(row * 3 + col),
              ],
            ),
          ),
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
            const SizedBox(height: 2),
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
    return GestureDetector(
      onTap: () => setState(() {
        _selectedAge = 0;
        _selectedIngredients.clear();
      }),
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: chipBg,
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
    );
  }

  // ================= TERAPKAN BUTTON =================
  Widget _buildApplyButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop({
          'age': _ages[_selectedAge],
          'ingredients':
              _selectedIngredients.map((i) => _ingredients[i].name).toList(),
        });
      },
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primaryRed,
          borderRadius: BorderRadius.circular(10),
        ),
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
    );
  }
}

// ================= HELPER CLASS =================
class _Ingredient {
  final String name;
  final String emoji;
  const _Ingredient(this.name, this.emoji);
}