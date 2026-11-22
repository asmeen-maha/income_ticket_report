import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../data/models/seller_transaction.dart';
import 'common.dart';

/// Left column: the day's ticket sellers with their verification checkbox.
class SellerListPanel extends StatelessWidget {
  const SellerListPanel({
    super.key,
    required this.sellers,
    required this.isLoading,
    required this.isSelected,
    required this.onSelect,
    required this.onVerify,
  });

  final List<SellerTransaction> sellers;
  final bool isLoading;
  final bool Function(SellerTransaction seller) isSelected;
  final ValueChanged<SellerTransaction> onSelect;
  final void Function(SellerTransaction seller, bool verified) onVerify;

  @override
  Widget build(BuildContext context) {
    if (sellers.isEmpty) return _placeholder(context);

    return Container(
      width: context.vw(.185),
      height: context.vh(.85),
      margin: EdgeInsets.only(left: context.vw(.01)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            HeaderCell(
              'ชื่อผู้จำหน่ายบัตร',
              width: context.vw(.135),
              radius: const BorderRadius.horizontal(left: Radius.circular(8)),
            ),
            HeaderCell(
              'Check',
              width: context.vw(.04),
              radius: const BorderRadius.horizontal(right: Radius.circular(8)),
            ),
          ]),
          Expanded(
            child: ListView.builder(
              itemCount: sellers.length,
              itemBuilder: (context, index) {
                final seller = sellers[index];
                return _SellerRow(
                  seller: seller,
                  selected: isSelected(seller),
                  onTap: () => onSelect(seller),
                  onVerify: (verified) => onVerify(seller, verified),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: context.vw(.15),
      height: context.vh(.85),
      padding: const EdgeInsets.all(5),
      margin: EdgeInsets.only(left: context.vw(.01), right: context.vw(.03)),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: isLoading ? const LoadingIndicator() : const MessageText('ไม่พบข้อมูล'),
    );
  }
}

class _SellerRow extends StatelessWidget {
  const _SellerRow({
    required this.seller,
    required this.selected,
    required this.onTap,
    required this.onVerify,
  });

  final SellerTransaction seller;
  final bool selected;
  final VoidCallback onTap;
  final ValueChanged<bool> onVerify;

  Color get _background {
    if (selected) return AppColors.sellerSelected;
    return seller.isVerified ? AppColors.sellerVerified : AppColors.sellerPending;
  }

  @override
  Widget build(BuildContext context) {
    // Only the selected, not-yet-verified seller can be ticked.
    final canVerify = selected && !seller.isVerified;

    return Row(
      children: [
        Card(
          margin: const EdgeInsets.all(5),
          elevation: selected ? 0 : 5,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: context.vw(.14),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: _background,
              ),
              child: Text(
                seller.displayName,
                style: TextStyle(
                  fontSize: context.vw(.009),
                  fontFamily: AppFonts.pgVim,
                  color: selected ? AppColors.white : AppColors.black,
                ),
              ),
            ),
          ),
        ),
        Checkbox(
          value: seller.hasFlag,
          activeColor: AppColors.darkPink,
          onChanged: canVerify ? (value) => onVerify(value ?? false) : null,
        ),
        if (selected)
          Icon(
            Icons.arrow_circle_right_outlined,
            color: AppColors.darkPink,
            size: context.vw(.02),
          ),
      ],
    );
  }
}
