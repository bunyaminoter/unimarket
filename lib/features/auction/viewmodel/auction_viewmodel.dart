import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unimarket/features/auction/repository/auction_repository.dart';
import 'package:unimarket/models/auction_bid_model.dart';
import 'package:unimarket/models/product_model.dart';

/// Auction ViewModel
///
/// Açık artırma detay sayfasının state yönetimi.
/// Geri sayım, teklif verme ve teklif listesi.
class AuctionViewModel extends ChangeNotifier {
  final AuctionRepository _repository;

  AuctionViewModel({AuctionRepository? repository})
    : _repository = repository ?? AuctionRepository();

  // ── State ────────────────────────────────────────────────
  List<AuctionBidModel> _bids = [];
  bool _isLoading = false;
  bool _isPlacingBid = false;
  String? _errorMessage;
  String? _successMessage;
  Duration _timeLeft = Duration.zero;
  Timer? _countdownTimer;
  StreamSubscription? _bidSubscription;

  // ── Getters ──────────────────────────────────────────────
  List<AuctionBidModel> get bids => _bids;
  bool get isLoading => _isLoading;
  bool get isPlacingBid => _isPlacingBid;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  Duration get timeLeft => _timeLeft;
  bool get isExpired => _timeLeft == Duration.zero;

  /// Geri sayım formatı: "12s 05d 30sn"
  String get formattedTimeLeft {
    if (_timeLeft == Duration.zero) return 'Süre Doldu';
    final hours = _timeLeft.inHours;
    final minutes = _timeLeft.inMinutes.remainder(60);
    final seconds = _timeLeft.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}s ${minutes.toString().padLeft(2, '0')}d ${seconds.toString().padLeft(2, '0')}sn';
    }
    return '${minutes.toString().padLeft(2, '0')}d ${seconds.toString().padLeft(2, '0')}sn';
  }

  // ── Geri Sayım Başlat ──────────────────────────────────
  void startCountdown(ProductModel product) {
    _countdownTimer?.cancel();
    if (product.auctionEndTime == null) return;

    _updateTimeLeft(product.auctionEndTime!);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeLeft(product.auctionEndTime!);
      if (_timeLeft == Duration.zero) {
        _countdownTimer?.cancel();
        // Süre dolduğunda otomatik finalize
        _repository.finalizeAuction(product.id);
      }
    });
  }

  void _updateTimeLeft(DateTime endTime) {
    final diff = endTime.difference(DateTime.now());
    _timeLeft = diff.isNegative ? Duration.zero : diff;
    notifyListeners();
  }

  // ── Teklifleri Dinle ──────────────────────────────────────
  void watchBids(String productId) {
    _bidSubscription?.cancel();
    _bidSubscription = _repository.watchBids(productId).listen((bids) {
      _bids = bids;
      notifyListeners();
    });
  }

  // ── Teklif Ver ────────────────────────────────────────────
  Future<bool> placeBid({
    required String productId,
    required String bidderId,
    required String bidderName,
    required double amount,
  }) async {
    try {
      _isPlacingBid = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      await _repository.placeBid(
        productId: productId,
        bidderId: bidderId,
        bidderName: bidderName,
        amount: amount,
      );

      _isPlacingBid = false;
      _successMessage = 'Teklifiniz başarıyla verildi!';
      notifyListeners();
      return true;
    } catch (e) {
      _isPlacingBid = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ── Teklifleri Yükle ──────────────────────────────────────
  Future<void> loadBids(String productId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _bids = await _repository.getBids(productId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Teklifler yüklenirken hata oluştu.';
      notifyListeners();
    }
  }

  // ── Mesajları Temizle ─────────────────────────────────────
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _bidSubscription?.cancel();
    super.dispose();
  }
}
