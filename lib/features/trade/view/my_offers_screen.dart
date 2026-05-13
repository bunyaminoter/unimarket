import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/features/trade/viewmodel/my_offers_viewmodel.dart';
import 'package:unimarket/models/trade_offer_model.dart';

class MyOffersScreen extends StatefulWidget {
  const MyOffersScreen({super.key});

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyOffersViewModel>().loadOffers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Tekliflerim',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: AppSizes.fontLg,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: AppSizes.fontSm,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: AppSizes.fontSm,
          ),
          tabs: const [
            Tab(text: 'Gelen Teklifler'),
            Tab(text: 'Gönderilen Teklifler'),
          ],
        ),
      ),
      body: Consumer<MyOffersViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOfferList(
                context,
                vm.incomingOffers,
                isIncoming: true,
                vm: vm,
              ),
              _buildOfferList(
                context,
                vm.sentOffers,
                isIncoming: false,
                vm: vm,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOfferList(
    BuildContext context,
    List<TradeOfferWithProducts> offers, {
    required bool isIncoming,
    required MyOffersViewModel vm,
  }) {
    if (offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isIncoming
                  ? Icons.move_to_inbox_rounded
                  : Icons.outbox_rounded,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              isIncoming
                  ? 'Henüz gelen bir teklif yok.'
                  : 'Henüz gönderilen bir teklif yok.',
              style: GoogleFonts.poppins(
                fontSize: AppSizes.fontMd,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.loadOffers,
      color: AppColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final item = offers[index];
          return _OfferCard(
            item: item,
            isIncoming: isIncoming,
            onAccept: () async {
              final success = await vm.acceptOffer(item.offer.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Teklif kabul edildi!',
                        style: GoogleFonts.poppins()),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            onReject: () async {
              final success = await vm.rejectOffer(item.offer.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Teklif reddedildi.',
                        style: GoogleFonts.poppins()),
                    backgroundColor: AppColors.textSecondary,
                  ),
                );
              }
            },
            onCancel: () async {
              final success = await vm.cancelOffer(item.offer.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Teklif iptal edildi.',
                        style: GoogleFonts.poppins()),
                    backgroundColor: AppColors.textSecondary,
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

// ─── Teklif Kartı ───────────────────────────────────────────────
class _OfferCard extends StatelessWidget {
  final TradeOfferWithProducts item;
  final bool isIncoming;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onCancel;

  const _OfferCard({
    required this.item,
    required this.isIncoming,
    required this.onAccept,
    required this.onReject,
    required this.onCancel,
  });

  Color _statusColor(TradeStatus status) {
    switch (status) {
      case TradeStatus.pending:
        return Colors.orange;
      case TradeStatus.accepted:
        return AppColors.success;
      case TradeStatus.rejected:
        return AppColors.error;
      case TradeStatus.completed:
        return AppColors.primary;
      case TradeStatus.cancelled:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final offer = item.offer;
    final status = offer.status;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Durum çubuğu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            decoration: BoxDecoration(
              color: _statusColor(status).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusLg),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isIncoming
                          ? Icons.call_received_rounded
                          : Icons.call_made_rounded,
                      size: 16,
                      color: _statusColor(status),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isIncoming ? 'Gelen Teklif' : 'Gönderilen Teklif',
                      style: GoogleFonts.poppins(
                        fontSize: AppSizes.fontXs,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(status),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(status),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Ürün bilgileri (takas çifti)
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                // Teklif edilen ürün
                Expanded(
                  child: _ProductMini(
                    label: 'Teklif Edilen',
                    product: item.offeredProduct,
                  ),
                ),

                // Ok ikonu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),

                // Hedef ürün
                Expanded(
                  child: _ProductMini(
                    label: 'Karşılığında',
                    product: item.targetProduct,
                  ),
                ),
              ],
            ),
          ),

          // Mesaj (varsa)
          if (offer.message != null && offer.message!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSizes.md,
                right: AppSizes.md,
                bottom: AppSizes.sm,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.message_outlined,
                        size: 16, color: AppColors.textHint),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        offer.message!,
                        style: GoogleFonts.poppins(
                          fontSize: AppSizes.fontXs,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Aksiyon butonları
          if (status == TradeStatus.pending)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSizes.md,
                right: AppSizes.md,
                bottom: AppSizes.md,
              ),
              child: isIncoming
                  ? Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onReject,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMd),
                              ),
                            ),
                            child: Text('Reddet',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onAccept,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMd),
                              ),
                            ),
                            child: Text('Kabul Et',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMd),
                          ),
                        ),
                        child: Text('Teklifi İptal Et',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

// ─── Mini Ürün Kartı ────────────────────────────────────────────
class _ProductMini extends StatelessWidget {
  final String label;
  final dynamic product; // ProductModel?

  const _ProductMini({required this.label, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: product != null && product.primaryImage != null
              ? CachedNetworkImage(
                  imageUrl: product.primaryImage!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 64,
                    height: 64,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                )
              : Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          product != null ? product.title : 'Silinmiş İlan',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: AppSizes.fontXs,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (product != null)
          Text(
            product.formattedPrice,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
