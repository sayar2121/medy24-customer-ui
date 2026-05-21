import 'package:customer_app/services/api_url.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayPaymentService {
  static const MethodChannel _channel = MethodChannel('razorpay_flutter');

  Razorpay? _razorpay;
  bool _handlersRegistered = false;

  /// Verifies the native Razorpay plugin is registered (fails after hot restart).
  static Future<bool> isPluginAvailable() async {
    try {
      await _channel.invokeMethod<dynamic>('resync');
      return true;
    } on MissingPluginException {
      return false;
    }
  }

  /// Registers listeners once the native plugin is available.
  Future<bool> ensureReady({
    required void Function(PaymentSuccessResponse response) onSuccess,
    required void Function(PaymentFailureResponse response) onError,
    void Function(ExternalWalletResponse response)? onExternalWallet,
  }) async {
    if (_handlersRegistered && _razorpay != null) return true;

    final available = await isPluginAvailable();
    if (!available) return false;

    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    if (onExternalWallet != null) {
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
    }
    _handlersRegistered = true;
    return true;
  }

  Future<void> openCheckout({
    required String orderId,
    required int amountPaise,
    required String contact,
    required String description,
    String? email,
    String? name,
  }) async {
    if (_razorpay == null) {
      throw StateError('Razorpay is not initialized. Call ensureReady() first.');
    }

    final options = {
      'key': ApiUrl.razorpayKeyId,
      'amount': amountPaise,
      'order_id': orderId,
      'name': name ?? 'MedApp',
      'description': description,
      'currency': 'INR',
      'prefill': {
        'contact': contact,
        if (email != null && email.isNotEmpty) 'email': email,
      },
    };
    _razorpay!.open(options);
  }

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
    _handlersRegistered = false;
  }
}
