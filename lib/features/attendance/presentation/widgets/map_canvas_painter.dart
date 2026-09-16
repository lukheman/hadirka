import 'package:flutter/material.dart';


class MapCanvasPainter extends CustomPainter {
  final bool dalamJangkauan;
  final double kantorLat;
  final double kantorLng;
  final double? userLat;
  final double? userLng;
  final double? jarak;
  final double radius;
  final double pulseVal;

  MapCanvasPainter({
    required this.dalamJangkauan,
    required this.kantorLat,
    required this.kantorLng,
    this.userLat,
    this.userLng,
    this.jarak,
    this.radius = 80.0,
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

    
    final roadPaint = Paint()
      ..color = const Color(0xFF334155).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    final roadPath = Path()
      ..moveTo(0, size.height * 0.4)
      ..cubicTo(size.width * 0.3, size.height * 0.35, size.width * 0.6,
          size.height * 0.55, size.width, size.height * 0.45);
    canvas.drawPath(roadPath, roadPaint);

    final roadPath2 = Path()
      ..moveTo(size.width * 0.4, 0)
      ..lineTo(size.width * 0.45, size.height);
    canvas.drawPath(roadPath2, roadPaint);

    
    final officeOffset = Offset(size.width * 0.4, size.height * 0.48);

    
    const geofenceRadiusPixels = 55.0; 
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

    canvas.drawCircle(officeOffset, geofenceRadiusPixels, geofenceFillPaint);
    canvas.drawCircle(officeOffset, geofenceRadiusPixels, geofenceBorderPaint);

    
    Offset userOffset;
    if (userLat != null && userLng != null && jarak != null) {
      final deltaLat = userLat! - kantorLat;
      final deltaLng = userLng! - kantorLng;

      
      double dx = deltaLng * 350000;
      double dy = -deltaLat * 350000;

      
      if (dalamJangkauan) {
        dx = dx.clamp(-40.0, 40.0);
        dy = dy.clamp(-40.0, 40.0);
      } else {
        if (dx.abs() < 60 && dy.abs() < 60) {
          dx = dx >= 0 ? 75.0 : -75.0;
          dy = dy >= 0 ? 65.0 : -65.0;
        }
      }

      userOffset = Offset(
        (officeOffset.dx + dx).clamp(30.0, size.width - 30.0),
        (officeOffset.dy + dy).clamp(30.0, size.height - 40.0),
      );
    } else {
      userOffset = Offset(officeOffset.dx + 40, officeOffset.dy + 35);
    }

    
    final linePaint = Paint()
      ..color = dalamJangkauan
          ? const Color(0xFF34D399)
          : const Color(0xFFFCA5A5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(officeOffset, userOffset, linePaint);

    
    final userPulsePaint = Paint()
      ..color = (dalamJangkauan
              ? const Color(0xFF10B981)
              : const Color(0xFF3B82F6))
          .withOpacity((1.4 - pulseVal).clamp(0.0, 0.6))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(userOffset, 12 * pulseVal, userPulsePaint);

    
    final userPinPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(userOffset, 7, userPinPaint);
    final userPinInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(userOffset, 3, userPinInnerPaint);

    
    final officePinPaint = Paint()
      ..color =
          dalamJangkauan ? const Color(0xFF10B981) : const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(officeOffset, 8, officePinPaint);
    final officePinInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(officeOffset, 3.5, officePinInnerPaint);

    
    _drawTextLabel(canvas, '🏢 Kantor TJS (${radius.toStringAsFixed(0)}m)',
        Offset(officeOffset.dx, officeOffset.dy - 18), const Color(0xFF10B981));
    _drawTextLabel(canvas, '👤 Anda',
        Offset(userOffset.dx, userOffset.dy + 14), const Color(0xFF3B82F6));
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
      oldDelegate.jarak != jarak ||
      oldDelegate.radius != radius ||
      oldDelegate.pulseVal != pulseVal;
}
