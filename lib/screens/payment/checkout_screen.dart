import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../models/test_package_booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_test_package_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/api_url.dart';
import '../../services/razorpay_payment_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final RazorpayPaymentService _razorpayService = RazorpayPaymentService();
  bool _isPaying = false;

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    ref
        .read(bookTestPackageProvider.notifier)
        .setRazorpayPaymentId(response.paymentId ?? '');
    if (!mounted) return;
    setState(() => _isPaying = false);
    _showSuccessAndExit();
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() => _isPaying = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response.message ?? 'Payment failed. Please try again.',
        ),
      ),
    );
  }

  Future<void> _onPayOnline() async {
    try {
      // Verify that Razorpay key is configured
      final _ = ApiUrl.razorpayKeyId;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Razorpay configuration error: ${e.toString()}',
          ),
        ),
      );
      return;
    }

    final user = ref.read(profileProvider).user ?? ref.read(authProvider).user;
    final bookingState = ref.read(bookTestPackageProvider);
    final booking = bookingState.confirmedBooking;

    if (booking == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No booking found')),
      );
      return;
    }

    final razorpayReady = await _razorpayService.ensureReady(
      onSuccess: _onPaymentSuccess,
      onError: _onPaymentError,
    );

    if (!razorpayReady) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Razorpay is not loaded. Stop the app completely, then run '
            'flutter run (hot restart does not load native plugins).',
          ),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    setState(() => _isPaying = true);

    BookingResponse? response = bookingState.bookingResponse;
    if (response?.transactionId == null) {
      response = await ref.read(bookTestPackageProvider.notifier).placeOnlineBooking(
        customerId: user?.customerId,
        savedAddresses: user?.savedAddresses,
      );
    }

    if (!mounted) return;

    final error = ref.read(bookTestPackageProvider).error;
    if (response == null || response.transactionId == null) {
      setState(() => _isPaying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to initiate payment')),
      );
      return;
    }

    final amountPaise =
        (response.totalAmountToBePaid * 100).round();

    try {
      await _razorpayService.openCheckout(
        orderId: response.transactionId!,
        amountPaise: amountPaise,
        contact: booking.patient.phoneNumber,
        email: user?.email ?? '',
        name: booking.patient.fullName,
        description: booking.itemName,
      );
    } on MissingPluginException {
      if (!mounted) return;
      setState(() => _isPaying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Razorpay plugin unavailable. Stop the app and run flutter run again.',
          ),
        ),
      );
    }
  }

  Future<void> _showSuccessAndExit() async {
    final bookingResponse = ref.read(bookTestPackageProvider).bookingResponse;
    final paymentId = ref.read(bookTestPackageProvider).razorpayPaymentId;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Payment successful'),
        content: Text(
          'Booking ID: ${bookingResponse?.bookingId ?? '—'}\n'
          '${paymentId != null ? 'Payment ID: $paymentId\n' : ''}'
          'Your lab test booking is confirmed.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );

    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookTestPackageProvider);
    final booking = bookingState.confirmedBooking;

    if (booking == null) {
      return Scaffold(
        appBar: const CustomAppBar(
          showBackButton: true,
          title: 'Checkout',
          subtitle: 'Review and pay',
        ),
        body: const Center(child: Text('No booking found')),
      );
    }

    final summary = booking.priceSummary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        showBackButton: true,
        title: 'Checkout',
        subtitle: 'Secure payment',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.itemName,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 17),
                  ),
                  if (booking.itemSubtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      booking.itemSubtitle!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'Patient: ${booking.patient.fullName}',
                    style: AppTextStyles.bodyMedium,
                  ),
                  Text(
                    booking.collectionAddress?.displayAddress ?? '',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildCard(
              child: Column(
                children: [
                  _row('Subtotal', summary.subtotal),
                  if (summary.discount > 0)
                    _row('Discount', summary.discount, isDiscount: true),
                  _row('Platform commission', summary.platformFee),
                  _row('Tax charges', summary.taxCharges),
                  const Divider(height: 24),
                  _row('Total', summary.totalAmount, isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.card,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pay Online',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'UPI, Credit Card, Debit Card',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Iconsax.tick_circle,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isPaying || bookingState.isSubmitting
                  ? null
                  : _onPayOnline,
              child: _isPaying || bookingState.isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Pay Online · ₹${summary.totalAmount.toStringAsFixed(0)}',
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppCardStyles.sleekCard,
      child: child,
    );
  }

  Widget _row(String label, double amount,
      {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
                color:
                    isTotal ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            isDiscount
                ? '- ₹${amount.toStringAsFixed(0)}'
                : '₹${amount.toStringAsFixed(0)}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: isDiscount
                  ? AppColors.error
                  : isTotal
                      ? AppColors.primaryAccent
                      : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
