import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

/// Asks the cashier to confirm verifying a seller. Resolves to `true` on
/// "ยืนยัน".
Future<bool> confirmVerifySeller(BuildContext context) async {
  var confirmed = false;
  await Dialogs.materialDialog(
    context: context,
    barrierDismissible: false,
    title: 'Verify',
    msg: 'ยืนยันตรวจสอบรายการ',
    color: AppColors.white,
    dialogWidth: kIsWeb ? .25 : null,
    titleStyle: const TextStyle(
      fontSize: 25,
      fontFamily: AppFonts.trajanPro,
      fontWeight: FontWeight.bold,
      color: AppColors.pink,
    ),
    msgStyle: const TextStyle(fontSize: 18, fontFamily: AppFonts.pgVim, color: Colors.black87),
    actionsBuilder: (dialogContext) => [
      IconsOutlineButton(
        onPressed: () => Navigator.of(dialogContext).pop(),
        text: 'กลับ',
        iconData: Icons.cancel_outlined,
        textStyle: const TextStyle(color: Colors.grey, fontFamily: AppFonts.pgVim),
        iconColor: Colors.grey,
      ),
      IconsButton(
        onPressed: () {
          confirmed = true;
          Navigator.of(dialogContext).pop();
        },
        text: 'ยืนยัน',
        iconData: Icons.done_rounded,
        color: Colors.green,
        textStyle: const TextStyle(color: AppColors.white, fontFamily: AppFonts.pgVim),
        iconColor: AppColors.white,
      ),
    ],
  );
  return confirmed;
}
