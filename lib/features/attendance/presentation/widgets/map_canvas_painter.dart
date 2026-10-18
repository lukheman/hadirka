import 'dart:math';
import 'package:flutter/material.dart';


class MapCanvasPainter extends CustomPainter {
  final bool dalamJangkauan;
  final double kantorLat;
  final double kantorLng;
  final double? userLat;
  final double? userLng;
  final double? jarak;
  final double radius;
  final String targetName;
  final double pulseVal;

  MapCanvasPainter({
    required this.dalamJangkauan,
    required this.kantorLat,
    required this.kantorLng,
    this.userLat,
    this.userLng,
    this.jarak,
    this.radius = 80.0,
    this.targetName = 'Lokasi Absensi',
    required this.pulseVal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    
    final targetPoint = _projectedPoints(size).target;
    final userPoint = _projectedPoints(size).user;
    final geofenceRadiusPixels = _projectedPoints(size).radiusPixels;

    final geofenceFillPaint = Paint()
      ..color = (dalamJangkauan
              ? const Color(0xFF10B981)
              : const Color(0xFFEF4444))
          .withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final geofenceBorderPaint = Paint()
      ..color = (dalamJangkauan
              ? const Color(0xFF10B981)
              : const Color(0xFFEF4444))
          .withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(targetPoint, geofenceRadiusPixels, geofenceFillPaint);
    canvas.drawCircle(targetPoint, geofenceRadiusPixels, geofenceBorderPaint);

    
    final linePaint = Paint()
      ..color = dalamJangkauan
          ? const Color(0xFF34D399)
          : const Color(0xFFFCA5A5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (userPoint != null) {
      canvas.drawLine(targetPoint, userPoint, linePaint);
    }

    
    final userPulsePaint = Paint()
      ..color = (dalamJangkauan
              ? const Color(0xFF10B981)
              : const Color(0xFF3B82F6))
          .withOpacity((1.4 - pulseVal).clamp(0.0, 0.6))
      ..style = PaintingStyle.fill;
    if (userPoint != null) {
      canvas.drawCircle(userPoint, 12 * pulseVal, userPulsePaint);
    }

    
    final userPinPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;
    if (userPoint != null) {
      canvas.drawCircle(userPoint, 7, userPinPaint);
    }
    final userPinInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    if (userPoint != null) {
      canvas.drawCircle(userPoint, 3, userPinInnerPaint);
    }

    
    final officePinPaint = Paint()
      ..color =
          dalamJangkauan ? const Color(0xFF10B981) : const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(targetPoint, 8, officePinPaint);
    final officePinInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(targetPoint, 3.5, officePinInnerPaint);

    
    _drawTextLabel(canvas, '$targetName (${radius.toStringAsFixed(0)}m)',
        Offset(targetPoint.dx, targetPoint.dy - 18), const Color(0xFF10B981));
    if (userPoint != null) {
      _drawTextLabel(canvas, 'Anda',
          Offset(userPoint.dx, userPoint.dy + 14), const Color(0xFF3B82F6));
    }
  }

  ({Offset target, Offset? user, double radiusPixels}) _projectedPoints(Size size) {
    final hasUser = userLat != null && userLng != null;
    final centerLat = hasUser ? (kantorLat + userLat!) / 2 : kantorLat;
    final centerLng = hasUser ? (kantorLng + userLng!) / 2 : kantorLng;
    final metersPerDegreeLat = 111320.0;
    final metersPerDegreeLng =
        111320.0 * cos(centerLat * 3.141592653589793 / 180).abs();

    Offset toMeters(double lat, double lng) {
      return Offset(
        (lng - centerLng) * metersPerDegreeLng,
        -(lat - centerLat) * metersPerDegreeLat,
      );
    }

    final targetMeters = toMeters(kantorLat, kantorLng);
    final userMeters = hasUser ? toMeters(userLat!, userLng!) : null;
    final minX = userMeters == null
        ? targetMeters.dx
        : min(targetMeters.dx, userMeters.dx);
    final maxX = userMeters == null
        ? targetMeters.dx
        : max(targetMeters.dx, userMeters.dx);
    final minY = userMeters == null
        ? targetMeters.dy
        : min(targetMeters.dy, userMeters.dy);
    final maxY = userMeters == null
        ? targetMeters.dy
        : max(targetMeters.dy, userMeters.dy);
    final spanX = max(maxX - minX, radius * 4);
    final spanY = max(maxY - minY, radius * 4);
    final scale = min((size.width - 64) / spanX, (size.height - 64) / spanY);
    final centerMeters = Offset((minX + maxX) / 2, (minY + maxY) / 2);

    Offset project(Offset point) {
      return Offset(
        size.width / 2 + (point.dx - centerMeters.dx) * scale,
        size.height / 2 + (point.dy - centerMeters.dy) * scale,
      );
    }

    return (
      target: project(targetMeters),
      user: userMeters == null ? null : project(userMeters),
      radiusPixels: (radius * scale).clamp(18.0, size.shortestSide * 0.42),
    );
  }

  void _drawTextLabel(Canvas canvas, String text, Offset offset, Color color) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        shadows: [
          Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4),
        ],
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(offset.dx - (textPainter.width / 2), offset.dy),
    );
  }

  @override
  bool shouldRepaint(covariant MapCanvasPainter oldDelegate) =>
      oldDelegate.dalamJangkauan != dalamJangkauan ||
      oldDelegate.userLat != userLat ||
      oldDelegate.userLng != userLng ||
      oldDelegate.kantorLat != kantorLat ||
      oldDelegate.kantorLng != kantorLng ||
      oldDelegate.jarak != jarak ||
      oldDelegate.radius != radius ||
      oldDelegate.targetName != targetName ||
      oldDelegate.pulseVal != pulseVal;
}
