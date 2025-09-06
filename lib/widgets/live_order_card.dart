import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/design_system/design_system.dart';
import 'order_timeline.dart';

/// Public LiveOrderCard widget used across screens. Expects an `order` map with
/// keys: id, items (List<String>), step (int), status (String), statusColor (Color),
/// driver (String), vehicle (String), customerName, customerPhone.
class LiveOrderCard extends StatelessWidget {
  const LiveOrderCard({
    super.key,
    required this.order,
    this.onTrack,
    this.onSupport,
    this.onCallDriver,
    this.onReorder,
  });

  final Map<String, dynamic> order;
  final void Function(String)? onTrack;
  final void Function(String)? onSupport;
  final void Function(String)? onCallDriver;
  final void Function(Map<String, dynamic>)? onReorder;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final color = (order['statusColor'] as Color?) ?? scheme.primary;
    // Cache primary gradient once to reuse
    final primaryGradient = DesignSystem.getBrandGradient('primary');
  final id = order['id']?.toString() ?? '';
  final shortId = order['shortId'];
  final displayId = (shortId != null && shortId.toString().isNotEmpty)
    ? shortId.toString()
    : id;
    final rawItems = order['items'];
    final List<String> items = [];
    if (rawItems is List) {
      for (final e in rawItems) {
        if (e == null) continue;
        if (e is String) {
          items.add(e);
        } else if (e is Map) {
          items.add(
            (e['productName'] ?? e['product_name'] ?? e['name'] ?? e.toString())
                .toString(),
          );
        } else {
          try {
            final dyn = e as dynamic;
            final name = dyn.productName ?? dyn.name;
            items.add((name ?? e.toString()).toString());
          } catch (_) {
            items.add(e.toString());
          }
        }
      }
    }
    // final status = order['status']?.toString() ?? '';

    // customer fields
    final customerName = order['customerName']?.toString() ?? '';
    final customerPhone = order['customerPhone']?.toString() ?? '';

    // Helper to normalize and format to a Saudi local mobile like: 050 123 4567
    String formatSaudiPhone(String input) {
      final digits = input.replaceAll(RegExp(r'[^0-9+]'), '');
      if (digits.isEmpty) return '050 123 4567';

      // Remove leading '+' for processing, keep for detection
      var d = digits.startsWith('+') ? digits.substring(1) : digits;

      String local;
      if (d.startsWith('00966')) {
        final rest = d.substring(5);
        local = rest.isNotEmpty ? '0$rest' : '0501234567';
      } else if (d.startsWith('966')) {
        final rest = d.substring(3);
        local = rest.isNotEmpty ? '0$rest' : '0501234567';
      } else if (d.length == 9 && d.startsWith('5')) {
        local = '0$d';
      } else if (d.length >= 10 && d.startsWith('05')) {
        local = d.substring(0, 10);
      } else {
        // Fallbacks for partial/unknown inputs
        if (d.length >= 9 && d.startsWith('5')) {
          local = '0${d.substring(0, 9)}';
        } else {
          local = '0501234567';
        }
      }

      // Ensure exactly 10 digits starting with 05
      local = local.replaceAll(RegExp(r'[^0-9]'), '');
      if (local.length != 10 || !local.startsWith('05')) {
        local = '0501234567';
      }

      // Format as 050 123 4567
      return '${local.substring(0, 3)} ${local.substring(3, 6)} ${local.substring(6)}';
    }

    final displayPhone = customerPhone.isNotEmpty
        ? formatSaudiPhone(customerPhone)
        : '050 123 4567';

    final cardShadows = isDark
        ? [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 240),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: cardShadows,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Right side (in RTL): customer name with gradient user icon
                  Expanded(
                    child: Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (rect) =>
                              primaryGradient.createShader(
                                Rect.fromLTWH(0, 0, rect.width, rect.height),
                              ),
                          blendMode: BlendMode.srcIn,
                          child: const FaIcon(
                            FontAwesomeIcons.user,
                            size:
                                24, // ensure the user icon is slightly bigger and fully filled by the gradient
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            customerName.isNotEmpty ? customerName : 'العميل',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Left side (in RTL): order number in rounded gradient container
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: DesignSystem.getBrandShadow('light'),
                    ),
                    child: Text(
                      'طلب رقم: $displayId',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // products row above timeline: label on the right, product title on the left
              if (items.isNotEmpty) ...[
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: TextDirection.rtl,
                      children: [
                        ShaderMask(
                          shaderCallback: (rect) =>
                              primaryGradient.createShader(
                                Rect.fromLTWH(0, 0, rect.width, rect.height),
                              ),
                          blendMode: BlendMode.srcIn,
                          child: const FaIcon(
                            FontAwesomeIcons.box,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'المنتجات',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        items.take(2).join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withOpacity(0.75),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
              ],

              // optional customer address (enriched from customers table)
              if ((order['customerAddress']?.toString().isNotEmpty ?? false)) ...[
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (rect) => primaryGradient.createShader(
                        Rect.fromLTWH(0, 0, rect.width, rect.height),
                      ),
                      blendMode: BlendMode.srcIn,
                      child: const FaIcon(
                        FontAwesomeIcons.locationDot,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order['customerAddress'].toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withOpacity(0.75),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Fixed gap before timeline to avoid overflow in tight layouts
              const SizedBox(height: 8),

              // timeline (use shared OrderTimeline widget)
              Builder(
                builder: (ctx) {
                  final rawStep = (order['step'] as int?) ?? 1;
                  final timelineStep = (rawStep - 1).clamp(0, 3).toInt();
                  return OrderTimeline(step: timelineStep, accent: color);
                },
              ),
              const SizedBox(height: 3),
              // Fixed gap after timeline to prevent flex overflow
              const SizedBox(height: 8),

              // phone icon + phone number only (remove duplicate name/phone)
              Row(
                children: [
                  ShaderMask(
                    shaderCallback: (rect) => primaryGradient.createShader(
                      Rect.fromLTWH(0, 0, rect.width, rect.height),
                    ),
                    blendMode: BlendMode.srcIn,
                    child: const FaIcon(
                      FontAwesomeIcons.phone,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      displayPhone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 84,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: DesignSystem.getBrandGradient('success'),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: DesignSystem.getBrandShadow('medium'),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onCallDriver?.call(id),
                          borderRadius: BorderRadius.circular(12),
                          child: const Center(
                            child: FaIcon(
                              FontAwesomeIcons.phone,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 76,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: DesignSystem.getBrandShadow('medium'),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onTrack?.call(id),
                          borderRadius: BorderRadius.circular(12),
                          child: const Center(
                            child: Text(
                              'تتبُّع',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Removed duplicate private timeline classes in favor of shared OrderTimeline to avoid duplication and reduce paint cost
