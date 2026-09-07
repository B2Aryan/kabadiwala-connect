import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/language_provider.dart';
import '../../../shared/widgets/primary_button.dart';

/// Hero Create Lot Button using reusable PrimaryButton
class HeroCreateLotButton extends StatelessWidget {
  final VoidCallback onPressed;

  const HeroCreateLotButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return PrimaryButton(
      title: langProvider.tr('createNewLot'),
      subtitle: langProvider.tr('sellEWaste'),
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.add_rounded, color: Colors.white, size: 24),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
