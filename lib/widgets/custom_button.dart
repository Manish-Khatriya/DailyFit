import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TabButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final Color buttonColor; // Added for more control over color

  const TabButton({required this.title, this.isActive = false, required this.buttonColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4A8989) : buttonColor, // Use buttonColor for inactive
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.8), // Adjusted text color
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class GradientCircularProgressPainter extends CustomPainter {
  final double value;

  GradientCircularProgressPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 14.0;
    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Gradient arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -3.14 / 2,
      endAngle: 3 * 3.14 / 2,
      colors: const [Colors.deepPurple, Colors.deepPurpleAccent, Colors.deepPurple],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -3.14 / 2, 2 * 3.14 * value, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AnimatedInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double maxValue;
  final Color color;

  const AnimatedInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(seconds: 1),
      builder: (context, animatedValue, _) {
        final progress = animatedValue / maxValue;
        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 5,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Icon(icon, color: color),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "${animatedValue.toStringAsFixed(label == 'km' ? 1 : 0)} $label",
              style: const TextStyle(fontSize: 13),
            ),
          ],
        );
      },
    );
  }
}
class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Icon(icon, color: Colors.deepPurple, size: 26),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

