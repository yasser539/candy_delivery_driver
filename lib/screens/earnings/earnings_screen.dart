import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../blocs/app_bloc.dart';
import '../../core/design_system/design_system.dart';
import '../../widgets/earnings_card.dart';
// import '../../widgets/currency_icon.dart';
import '../../widgets/modern_app_bar.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  // String _selectedPeriod = 'اليوم';

  @override
  Widget build(BuildContext context) {
    final appBloc = Provider.of<AppBloc>(context);
    final isDark = appBloc.isDarkMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? DesignSystem.darkBackground : DesignSystem.background,
        appBar: ModernAppBar(
          title: 'الأرباح',
          actions: [
            IconButton(
              icon: Icon(Icons.history),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('سجل الأرباح'),
                    backgroundColor: DesignSystem.info,
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Earnings Overview
              _buildEarningsOverview(isDark),
              const SizedBox(height: 24),

              // Earnings Breakdown
              _buildEarningsBreakdown(isDark),
              const SizedBox(height: 24),

              // Recent Transactions
              _buildRecentTransactions(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsOverview(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إجمالي الأرباح',
              style: DesignSystem.titleMedium.copyWith(
                color: DesignSystem.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            EarningsCard(
              title: 'إجمالي الأرباح',
              amount: '8,500 ',
              icon: FontAwesomeIcons.wallet,
              color: DesignSystem.primary,
              isDark: isDark,
              showCurrencyIcon: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsBreakdown(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفضيلات الأرباح',
              style: DesignSystem.titleMedium.copyWith(
                color: DesignSystem.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: EarningsCard(
                    title: 'الأرباح النقدية',
                    amount: '3,250 ',
                    icon: FontAwesomeIcons.moneyBill,
                    color: DesignSystem.success,
                    isDark: isDark,
                    showCurrencyIcon: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: EarningsCard(
                    title: 'الأرباح الإلكترونية',
                    amount: '5,250 ',
                    icon: FontAwesomeIcons.creditCard,
                    color: DesignSystem.info,
                    isDark: isDark,
                    showCurrencyIcon: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'آخر المعاملات',
              style: DesignSystem.titleMedium.copyWith(
                color: DesignSystem.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTransactionItem(
              'طلب #1234',
              '45 ',
              'نقدي',
              'قبل ساعتين',
              DesignSystem.success,
              isDark,
            ),
            const SizedBox(height: 12),
            _buildTransactionItem(
              'طلب #1235',
              '30 ',
              'فيزا',
              'قبل 3 ساعات',
              DesignSystem.info,
              isDark,
            ),
            const SizedBox(height: 12),
            _buildTransactionItem(
              'طلب #1236',
              '75 ',
              'نقدي',
              'قبل 5 ساعات',
              DesignSystem.success,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? DesignSystem.darkSurface : DesignSystem.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          FaIcon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: DesignSystem.bodySmall.copyWith(
              color: DesignSystem.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: DesignSystem.titleMedium.copyWith(
              color: DesignSystem.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    String orderId,
    String amount,
    String paymentMethod,
    String time,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? DesignSystem.darkSurface : DesignSystem.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FaIcon(
              paymentMethod == 'نقدي'
                  ? FontAwesomeIcons.moneyBill
                  : FontAwesomeIcons.creditCard,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderId,
                  style: DesignSystem.bodyMedium.copyWith(
                    color: DesignSystem.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  paymentMethod,
                  style: DesignSystem.bodySmall.copyWith(
                    color: DesignSystem.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: DesignSystem.titleMedium.copyWith(
                  color: DesignSystem.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                time,
                style: DesignSystem.bodySmall.copyWith(
                  color: DesignSystem.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
