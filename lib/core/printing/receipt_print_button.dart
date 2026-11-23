import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:storeus_delivery/core/printing/rawbt_receipt_printer.dart';
import 'package:storeus_delivery/core/printing/usb_esc_pos_printer.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

typedef ReceiptBuilderCallback = Future<ReceiptDocument> Function();

/// A reusable Store Us print action for order cards and compact app bars.
/// The receipt is sent directly to RawBT; no Android share sheet is opened.
class ReceiptPrintButton extends StatefulWidget {
  const ReceiptPrintButton({
    super.key,
    required this.receiptBuilder,
    this.compact = false,
    this.label,
    this.tooltip,
  });

  final ReceiptBuilderCallback? receiptBuilder;
  final bool compact;
  final String? label;
  final String? tooltip;

  @override
  State<ReceiptPrintButton> createState() => _ReceiptPrintButtonState();
}

class _ReceiptPrintButtonState extends State<ReceiptPrintButton> {
  bool _busy = false;

  void _message(String message) {
    if (!mounted) return;
    showSimpleNotification(
      Text(message),
      position: NotificationPosition.bottom,
      duration: const Duration(seconds: 4),
    );
  }

  Future<void> _onPrint() async {
    if (_busy || widget.receiptBuilder == null) return;
    setState(() => _busy = true);

    try {
      final receipt = await widget.receiptBuilder!();
      if (!mounted) return;
      if (receipt.lines.isEmpty) {
        _message('لا توجد بيانات للطباعة.');
        return;
      }

      // The native bridge targets only RawBT (ACTION_SEND + setPackage).
      // Successful dispatch is not confirmation of physical printing.
      await RawBtReceiptPrinter.print(receipt);
    } catch (error) {
      if (error is PlatformException && error.code == 'RAWBT_NOT_INSTALLED') {
        _message('تطبيق RawBT Print غير مثبت على الجهاز.');
      } else if (error is MissingPluginException) {
        debugPrint('StoreUsRawBT MissingPluginException: $error');
        _message('MissingPlugin: ${error.message ?? error.toString()}');
      } else {
        _message('تعذر إرسال الفاتورة إلى RawBT: $error');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.receiptBuilder != null && !_busy;
    final onTap = enabled ? _onPrint : null;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final label = widget.label ?? (isArabic ? 'طباعة الفاتورة' : 'Print receipt');

    if (widget.compact) {
      return Tooltip(
        message: widget.tooltip ?? label,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.blue5,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 46,
                height: 46,
                child: Center(child: _icon(size: 22)),
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.blue5,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.16),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.white0,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: _icon(size: 19),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: enabled ? AppColors.primary : AppColors.grey4,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    'RawBT',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      color: AppColors.primary.withValues(alpha: 0.66),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _icon({required double size}) {
    if (_busy) {
      return SizedBox.square(
        dimension: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      );
    }
    return Icon(
      Icons.print_rounded,
      size: size,
      color: widget.receiptBuilder == null ? AppColors.grey4 : AppColors.primary,
    );
  }
}
