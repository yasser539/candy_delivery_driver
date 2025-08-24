import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/design_system/design_system.dart';
import 'dart:math' as math;
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
    final id = order['id']?.toString() ?? '';
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
    final status = order['status']?.toString() ?? '';

    // customer fields
    final customerName = order['customerName']?.toString() ?? '';
    final customerPhone = order['customerPhone']?.toString() ?? '';

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
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'طلب رقم: $id',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // status chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // products row above timeline: label on the right, product title on the left
              if (items.isNotEmpty) ...[
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      'المنتجات',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
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
                const SizedBox(height: 12),
              ],

              // timeline (use shared OrderTimeline widget)
              Builder(
                builder: (ctx) {
                  final rawStep = (order['step'] as int?) ?? 1;
                  final timelineStep = (rawStep - 1).clamp(0, 3).toInt();
                  return OrderTimeline(step: timelineStep, accent: color);
                },
              ),
              const SizedBox(height: 8),

              // push the user row to the bottom of the card
              const SizedBox.shrink(),

              Expanded(child: Container()),

              // user icon + name on the left, keep customer phone on the right
              Row(
                children: [
                  ShaderMask(
                    shaderCallback: (rect) =>
                        DesignSystem.getBrandGradient('primary').createShader(
                          Rect.fromLTWH(0, 0, rect.width, rect.height),
                        ),
                    blendMode: BlendMode.srcIn,
                    child: FaIcon(
                      FontAwesomeIcons.user,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName.isNotEmpty ? customerName : 'العميل',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      customerPhone.isNotEmpty ? customerPhone : '',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 56,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: DesignSystem.getBrandGradient('primary'),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => onCallDriver?.call(id),
                              borderRadius: BorderRadius.circular(8),
                              child: Center(
                                child: Icon(
                                  FontAwesomeIcons.phone,
                                  size: 14,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 72,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: DesignSystem.getBrandGradient('primary'),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: DesignSystem.getBrandShadow('medium'),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onTrack?.call(id),
                          borderRadius: BorderRadius.circular(10),
                          child: const Center(
                            child: Text(
                              'تتبُّع',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
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

// The timeline classes below are adapted from the MyOrders implementation.
class _OrderTimeline extends StatelessWidget {
  const _OrderTimeline({required this.step, required this.accent});
  final int step;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const labels = [
      'مراجعة\nالطلب',
      'تحضير\nالطلب',
      'جاري\nالتوصيل',
      'تم\nالتوصيل',
    ];
    const double dotSize = 18.0;
    const double stroke = 1.6;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          const double horizontalPadding = 30.0;
          final usable = width - dotSize - (horizontalPadding * 2);
          final segment = usable / 3.0;
          final centers = List.generate(
            4,
            (i) => Offset(
              horizontalPadding + (dotSize / 2) + (segment * i),
              dotSize / 2,
            ),
          );

          return Column(
            children: [
              SizedBox(
                height: dotSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(width, dotSize),
                      painter: _ConnectorPainter(
                        step: step,
                        centers: centers,
                        accent: accent,
                        inactive: scheme.outline.withOpacity(0.3),
                        strokeWidth: stroke,
                        dotRadius: dotSize / 2,
                        shorten: 14.0,
                        underlap: 6.0,
                      ),
                    ),
                    for (int i = 0; i < 4; i++)
                      Positioned(
                        left: centers[i].dx - (dotSize / 2),
                        top: 0,
                        width: dotSize,
                        height: dotSize,
                        child: ShaderMask(
                          shaderCallback: (bounds) =>
                              DesignSystem.getBrandGradient(
                                'primary',
                              ).createShader(bounds),
                          blendMode: BlendMode.srcIn,
                          child: _DotStep(
                            filled: (3 - i) <= step,
                            color: Colors.white,
                            size: dotSize,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: width,
                height: 56,
                child: Stack(
                  children: List.generate(4, (i) {
                    final labelIndex = 3 - i;
                    const double labelWidth = 84.0;
                    var left = centers[i].dx - (labelWidth / 2);
                    left = left.clamp(0.0, width - labelWidth);
                    return Positioned(
                      left: left,
                      top: 0,
                      width: labelWidth,
                      child: Center(
                        child: Text(
                          labels[labelIndex],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: 10,
                                color: scheme.onSurface.withOpacity(0.72),
                                height: 1.05,
                              ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({
    required this.step,
    required this.centers,
    required this.accent,
    required this.inactive,
    required this.strokeWidth,
    this.dotRadius = 0,
    this.shorten = 8.0,
    this.underlap = 2.0,
  });
  final int step;
  final List<Offset> centers;
  final Color accent;
  final Color inactive;
  final double strokeWidth;
  final double dotRadius;
  final double shorten;
  final double underlap;

  @override
  void paint(Canvas canvas, Size size) {
    final paintActive = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..shader = DesignSystem.getBrandGradient(
        'primary',
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final paintInactive = Paint()
      ..color = inactive
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final edgeGap = dotRadius - (strokeWidth / 2);
    final edgeWithUnderlap = (edgeGap - underlap).clamp(0.0, edgeGap);

    for (int i = 0; i < 3; i++) {
      final from = centers[i];
      final to = centers[i + 1];
      final angle = (to - from).direction;
      var p1 =
          from +
          Offset(
            math.cos(angle) * edgeWithUnderlap,
            math.sin(angle) * edgeWithUnderlap,
          );
      var p2 =
          to -
          Offset(
            math.cos(angle) * edgeWithUnderlap,
            math.sin(angle) * edgeWithUnderlap,
          );
      final halfShorten = shorten / 2;
      final midShift = Offset(
        math.cos(angle) * halfShorten,
        math.sin(angle) * halfShorten,
      );
      p1 = p1 + midShift;
      p2 = p2 - midShift;
      final isActive = i >= (3 - step);
      canvas.drawLine(p1, p2, isActive ? paintActive : paintInactive);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectorPainter old) =>
      old.step != step ||
      old.accent != accent ||
      old.strokeWidth != strokeWidth ||
      old.shorten != shorten ||
      old.underlap != underlap;
}

class _DotStep extends StatelessWidget {
  const _DotStep({required this.filled, required this.color, this.size = 12});
  final bool filled;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : Colors.transparent,
        border: filled ? null : Border.all(color: color, width: 2),
      ),
    );
  }
}
