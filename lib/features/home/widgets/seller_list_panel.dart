import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/seller_transaction.dart';
import 'ui_kit.dart';

/// Left tile: search plus sellers grouped into "รอตรวจ" and "ตรวจแล้ว".
class SellerListPanel extends StatelessWidget {
  const SellerListPanel({
    super.key,
    required this.pending,
    required this.verified,
    required this.isSelected,
    required this.onSearch,
    required this.onSelect,
    required this.onVerify,
  });

  final List<SellerTransaction> pending;
  final List<SellerTransaction> verified;
  final bool Function(SellerTransaction seller) isSelected;
  final ValueChanged<String> onSearch;
  final ValueChanged<SellerTransaction> onSelect;
  final ValueChanged<SellerTransaction> onVerify;

  @override
  Widget build(BuildContext context) {
    final noMatches = pending.isEmpty && verified.isEmpty;

    return Tile(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(child: Text('ชื่อผู้จำหน่ายบัตร', style: AppText.display())),
                Text('Ticket sellers', style: AppText.caption()),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SearchField(onChanged: onSearch),
          const SizedBox(height: 8),
          Expanded(
            child: noMatches
                ? Center(child: Text('ไม่พบผู้จำหน่ายที่ค้นหา', style: AppText.caption()))
                : ListView(
                    children: [
                      if (pending.isNotEmpty) ...[
                        _GroupHeading(
                          'รอตรวจ',
                          count: pending.length,
                          background: AppColors.primarySoft,
                          foreground: AppColors.primaryText,
                        ),
                        for (final seller in pending) _row(seller),
                      ],
                      if (verified.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _GroupHeading(
                          'ตรวจแล้ว',
                          count: verified.length,
                          background: AppColors.tealSoft,
                          foreground: AppColors.teal,
                        ),
                        for (final seller in verified) _row(seller),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _row(SellerTransaction seller) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: _SellerRow(
          seller: seller,
          selected: isSelected(seller),
          onTap: () => onSelect(seller),
          onVerify: () => onVerify(seller),
        ),
      );
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: TextField(
        onChanged: onChanged,
        style: AppText.body(),
        decoration: InputDecoration(
          hintText: 'ค้นหารหัสหรือชื่อ',
          hintStyle: AppText.body(color: AppColors.placeholder),
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.sunken,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _GroupHeading extends StatelessWidget {
  const _GroupHeading(
    this.title, {
    required this.count,
    required this.background,
    required this.foreground,
  });

  final String title;
  final int count;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
      child: Row(children: [
        Text(title, style: AppText.caption(weight: FontWeight.w600)),
        const SizedBox(width: 8),
        Pill('$count',
            size: 11,
            background: background,
            foreground: foreground,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1)),
      ]),
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
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final verified = seller.isVerified;
    final tone = verified
        ? AvatarTone.verified
        : selected
            ? AvatarTone.active
            : AvatarTone.neutral;
    final subtitle = selected && !verified ? '${seller.code} · กำลังตรวจ' : seller.code;

    return Material(
      color: selected ? AppColors.primarySoft : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.row),
        side: selected
            ? const BorderSide(color: AppColors.primary, width: 1.5)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 52),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(children: [
                    SellerAvatar(name: seller.name, tone: tone),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            seller.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.body(weight: selected ? FontWeight.w600 : FontWeight.w500),
                          ),
                          Text(
                            subtitle,
                            style: AppText.caption(
                              color: selected && !verified ? AppColors.primaryText : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          _CheckToggle(verified: verified, enabled: selected && !verified, onVerify: onVerify),
        ],
      ),
    );
  }
}

/// "Check" box. Only the selected, unverified seller can be ticked, and a
/// tick only opens the confirmation dialog.
class _CheckToggle extends StatelessWidget {
  const _CheckToggle({required this.verified, required this.enabled, required this.onVerify});

  final bool verified;
  final bool enabled;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final color = verified
        ? AppColors.teal
        : enabled
            ? AppColors.primaryText
            : AppColors.textMuted;

    return InkWell(
      onTap: enabled ? onVerify : null,
      borderRadius: BorderRadius.circular(AppRadius.row),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.only(left: 4, right: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: 24,
                child: Checkbox(
                  value: verified,
                  onChanged: enabled ? (_) => onVerify() : null,
                  activeColor: AppColors.teal,
                  fillColor: verified ? const WidgetStatePropertyAll(AppColors.teal) : null,
                  side: BorderSide(color: enabled ? AppColors.primary : AppColors.disabledIcon, width: 1.5),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                verified ? 'ตรวจแล้ว' : 'Check',
                style: AppText.caption(
                  color: color,
                  weight: verified || enabled ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
