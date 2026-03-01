import 'package:flutter/material.dart';
import 'package:flutter_smkit_ui/flutter_smkit_ui.dart';
import 'package:flutter_smkit_ui/models/smkit_ui_config.dart';

// ──────────────────────────────────────────────────────────────
// Color mapping — mirrors SkeletonColorOption.uiColor in the SDK
// ──────────────────────────────────────────────────────────────
const Map<SkeletonColorOption, Color> _skeletonColors = {
  SkeletonColorOption.white: Color(0xFFFFFFFF),
  SkeletonColorOption.black: Color(0xFF000000),
  SkeletonColorOption.red: Color(0xFFFF3B30),
  SkeletonColorOption.blue: Color(0xFF007AFF),
  SkeletonColorOption.green: Color(0xFF34C759),
  SkeletonColorOption.yellow: Color(0xFFFFCC00),
  SkeletonColorOption.orange: Color(0xFFFF9500),
  SkeletonColorOption.purple: Color(0xFFAF52DE),
  SkeletonColorOption.gray: Color(0xFF8E8E93),
  SkeletonColorOption.cyan: Color(0xFF32ADE6),
  SkeletonColorOption.lightGray: Color(0xFFD1D1D6),
  SkeletonColorOption.darkGray: Color(0xFF48484A),
  SkeletonColorOption.offWhite: Color(0xFFF2F2F7),
  SkeletonColorOption.charcoal: Color(0xFF36454F),
  SkeletonColorOption.lightBlue: Color(0xFFADD8E6),
  SkeletonColorOption.darkBlue: Color(0xFF00008B),
  SkeletonColorOption.lightGreen: Color(0xFF90EE90),
  SkeletonColorOption.darkGreen: Color(0xFF006400),
  SkeletonColorOption.lightPurple: Color(0xFFDDA0DD),
  SkeletonColorOption.darkPurple: Color(0xFF4B0082),
  SkeletonColorOption.gold: Color(0xFFFFD700),
  SkeletonColorOption.darkGold: Color(0xFFB8860B),
  SkeletonColorOption.lightPink: Color(0xFFFFB6C1),
  SkeletonColorOption.darkPink: Color(0xFFC71585),
  SkeletonColorOption.mediumGray: Color(0xFF9E9E9E),
  SkeletonColorOption.silver: Color(0xFFC0C0C0),
  SkeletonColorOption.navy: Color(0xFF000080),
  SkeletonColorOption.forestGreen: Color(0xFF228B22),
  SkeletonColorOption.lavender: Color(0xFFE6E6FA),
  SkeletonColorOption.rosePink: Color(0xFFFF66B2),
};

// ──────────────────────────────────────────────────────────────
// Simplified skeleton preview widget
// ──────────────────────────────────────────────────────────────
class _SkeletonPreview extends StatelessWidget {
  final SkeletonPreset preset;
  final SkeletonConnectionStyle connectionStyle;
  final SkeletonJointShape jointShape;
  final SkeletonColorOption? dotsInnerColor;
  final SkeletonColorOption? dotsOuterColor;
  final SkeletonColorOption? connectionsInnerColor;
  final double dotsOpacity;
  final double connectionsOpacity;
  final double dotsGlow;
  final double lineWidthScale;

  const _SkeletonPreview({
    required this.preset,
    required this.connectionStyle,
    required this.jointShape,
    required this.dotsOpacity,
    required this.connectionsOpacity,
    required this.dotsGlow,
    required this.lineWidthScale,
    this.dotsInnerColor,
    this.dotsOuterColor,
    this.connectionsInnerColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SkeletonPreviewPainter(
        preset: preset,
        connectionStyle: connectionStyle,
        jointShape: jointShape,
        dotsOpacity: dotsOpacity,
        connectionsOpacity: connectionsOpacity,
        dotsGlow: dotsGlow,
        lineWidthScale: lineWidthScale,
        dotsInnerColor: dotsInnerColor,
        connectionsInnerColor: connectionsInnerColor,
      ),
    );
  }
}

class _SkeletonPreviewPainter extends CustomPainter {
  final SkeletonPreset preset;
  final SkeletonConnectionStyle connectionStyle;
  final SkeletonJointShape jointShape;
  final double dotsOpacity;
  final double connectionsOpacity;
  final double dotsGlow;
  final double lineWidthScale;
  final SkeletonColorOption? dotsInnerColor;
  final SkeletonColorOption? connectionsInnerColor;

  _SkeletonPreviewPainter({
    required this.preset,
    required this.connectionStyle,
    required this.jointShape,
    required this.dotsOpacity,
    required this.connectionsOpacity,
    required this.dotsGlow,
    required this.lineWidthScale,
    this.dotsInnerColor,
    this.connectionsInnerColor,
  });

  // Resolve the dot color from preset or override
  Color get _dotColor {
    if (dotsInnerColor != null) {
      return (_skeletonColors[dotsInnerColor!] ?? Colors.white).withOpacity(dotsOpacity.clamp(0, 1));
    }
    return _presetDotColor.withOpacity(dotsOpacity.clamp(0, 1));
  }

  Color get _lineColor {
    if (connectionsInnerColor != null) {
      return (_skeletonColors[connectionsInnerColor!] ?? Colors.white).withOpacity(connectionsOpacity.clamp(0, 1));
    }
    return _presetLineColor.withOpacity(connectionsOpacity.clamp(0, 1));
  }

  Color get _presetDotColor {
    switch (preset) {
      case SkeletonPreset.neonGlow:
      case SkeletonPreset.neonPulse:
        return const Color(0xFF00FFFF);
      case SkeletonPreset.hologram:
        return const Color(0xFF00E5FF);
      case SkeletonPreset.darkOutline:
      case SkeletonPreset.monochromeClean:
      case SkeletonPreset.matte:
        return const Color(0xFF222222);
      case SkeletonPreset.pastel:
        return const Color(0xFFFFB3BA);
      case SkeletonPreset.premium:
        return const Color(0xFFFFD700);
      case SkeletonPreset.accessibility:
        return const Color(0xFFFFFF00);
      default:
        return Colors.white;
    }
  }

  Color get _presetLineColor {
    switch (preset) {
      case SkeletonPreset.neonGlow:
      case SkeletonPreset.neonPulse:
        return const Color(0xFF39FF14);
      case SkeletonPreset.hologram:
        return const Color(0xFF00E5FF);
      case SkeletonPreset.darkOutline:
        return const Color(0xFF222222);
      case SkeletonPreset.monochromeClean:
        return const Color(0xFF333333);
      case SkeletonPreset.pastel:
        return const Color(0xFFBAFFB3);
      case SkeletonPreset.premium:
        return const Color(0xFFFFD700);
      case SkeletonPreset.accessibility:
        return const Color(0xFFFFFF00);
      default:
        return const Color(0xFF4CD964);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final jointR = (size.height * 0.22).clamp(3.0, 8.0);
    final lw = (1.5 * lineWidthScale).clamp(0.5, 6.0);

    // Joint positions: left, centre-top, right
    final joints = [
      Offset(cx - size.width * 0.3, cy),
      Offset(cx, cy - size.height * 0.25),
      Offset(cx + size.width * 0.3, cy),
    ];

    // Draw connection lines
    if (connectionStyle != SkeletonConnectionStyle.none) {
      final linePaint = Paint()
        ..color = _lineColor
        ..strokeWidth = lw
        ..strokeCap = StrokeCap.round;

      if (dotsGlow > 0) {
        linePaint.maskFilter = MaskFilter.blur(BlurStyle.normal, dotsGlow * 4);
      }

      final path = Path()
        ..moveTo(joints[0].dx, joints[0].dy)
        ..lineTo(joints[1].dx, joints[1].dy)
        ..lineTo(joints[2].dx, joints[2].dy);

      switch (connectionStyle) {
        case SkeletonConnectionStyle.solid:
        case SkeletonConnectionStyle.rounded:
          canvas.drawPath(path, linePaint);
          break;
        case SkeletonConnectionStyle.dashed:
        case SkeletonConnectionStyle.longDashed:
        case SkeletonConnectionStyle.dotDashed:
          _drawDashedPath(canvas, joints[0], joints[1], linePaint, lw);
          _drawDashedPath(canvas, joints[1], joints[2], linePaint, lw);
          break;
        case SkeletonConnectionStyle.dotted:
        case SkeletonConnectionStyle.thinDots:
          _drawDottedPath(canvas, joints[0], joints[1], linePaint, lw);
          _drawDottedPath(canvas, joints[1], joints[2], linePaint, lw);
          break;
        case SkeletonConnectionStyle.none:
          break;
      }
    }

    // Draw joints
    final dotPaint = Paint()..color = _dotColor;
    if (dotsGlow > 0) {
      dotPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, dotsGlow * 6);
    }

    for (final j in joints) {
      _drawJoint(canvas, j, jointR, dotPaint);
    }
  }

  void _drawJoint(Canvas canvas, Offset center, double r, Paint paint) {
    switch (jointShape) {
      case SkeletonJointShape.circle:
        canvas.drawCircle(center, r, paint);
        break;
      case SkeletonJointShape.square:
        canvas.drawRect(Rect.fromCenter(center: center, width: r * 2, height: r * 2), paint);
        break;
      case SkeletonJointShape.diamond:
        final path = Path()
          ..moveTo(center.dx, center.dy - r)
          ..lineTo(center.dx + r, center.dy)
          ..lineTo(center.dx, center.dy + r)
          ..lineTo(center.dx - r, center.dy)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case SkeletonJointShape.triangle:
        final path = Path()
          ..moveTo(center.dx, center.dy - r)
          ..lineTo(center.dx + r, center.dy + r)
          ..lineTo(center.dx - r, center.dy + r)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case SkeletonJointShape.hexagon:
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (i * 60 - 30) * 3.14159 / 180;
          final x = center.dx + r * 1.0 * (angle == 0 ? 1 : (i % 2 == 0 ? 0.866 : 1.0));
          // simplified hexagon
          if (i == 0) path.moveTo(center.dx + r, center.dy);
          final a = (i * 60) * 3.14159 / 180;
          path.lineTo(center.dx + r * _cos(a), center.dy + r * _sin(a));
        }
        path.close();
        canvas.drawPath(path, paint);
        break;
      case SkeletonJointShape.star:
        // draw as circle for simplicity in small preview
        canvas.drawCircle(center, r, paint);
        break;
    }
  }

  double _cos(double a) => (a < 1.6 ? 1 - a * a / 2 + a * a * a * a / 24 : -1 + (a - 3.14159) * (a - 3.14159) / 2);
  double _sin(double a) => (a - a * a * a / 6 + a * a * a * a * a / 120);

  void _drawDashedPath(Canvas canvas, Offset from, Offset to, Paint paint, double lw) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final len = (dx * dx + dy * dy) < 0.001 ? 0.001 : (dx * dx + dy * dy);
    final total = len < 1 ? 1.0 : len;
    final dashLen = lw * 4;
    final gapLen = lw * 2;
    double t = 0;
    while (t < 1) {
      final t2 = (t + dashLen / total).clamp(0.0, 1.0);
      canvas.drawLine(
        Offset(from.dx + dx * t, from.dy + dy * t),
        Offset(from.dx + dx * t2, from.dy + dy * t2),
        paint,
      );
      t = t2 + gapLen / total;
    }
  }

  void _drawDottedPath(Canvas canvas, Offset from, Offset to, Paint paint, double lw) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final len = (dx * dx + dy * dy) < 0.001 ? 0.001 : (dx * dx + dy * dy);
    final total = len < 1 ? 1.0 : len;
    final step = lw * 3 / total;
    double t = 0;
    while (t < 1) {
      canvas.drawCircle(
        Offset(from.dx + dx * t, from.dy + dy * t),
        lw * 0.7,
        paint,
      );
      t += step;
    }
  }

  @override
  bool shouldRepaint(_SkeletonPreviewPainter old) => true;
}

// ──────────────────────────────────────────────────────────────
// Result returned when the screen is dismissed
// ──────────────────────────────────────────────────────────────
class UISettingsResult {
  final SkeletonConfig skeletonConfig;
  final bool allowAudioMixing;
  final bool showExternalAudioControl;
  final bool enableIntelligenceRest;

  const UISettingsResult({
    required this.skeletonConfig,
    required this.allowAudioMixing,
    required this.showExternalAudioControl,
    required this.enableIntelligenceRest,
  });
}

// ──────────────────────────────────────────────────────────────
// Main settings screen
// ──────────────────────────────────────────────────────────────
class UISettingsScreen extends StatefulWidget {
  final SmkitUiFlutterPlugin plugin;
  final SkeletonConfig? initialConfig;
  final bool initialAllowAudioMixing;
  final bool initialShowExternalAudioControl;
  final bool initialEnableIntelligenceRest;

  const UISettingsScreen({
    super.key,
    required this.plugin,
    this.initialConfig,
    this.initialAllowAudioMixing = false,
    this.initialShowExternalAudioControl = false,
    this.initialEnableIntelligenceRest = false,
  });

  @override
  State<UISettingsScreen> createState() => _UISettingsScreenState();
}

class _UISettingsScreenState extends State<UISettingsScreen> {
  // Session flags
  bool _allowAudioMixing = false;
  bool _showExternalAudioControl = false;
  bool _enableIntelligenceRest = false;

  // Skeleton hidden
  bool _hidden = false;

  // Preset / connection / joint
  SkeletonPreset _preset = SkeletonPreset.defaultPreset;
  SkeletonConnectionStyle _connectionStyle = SkeletonConnectionStyle.solid;
  SkeletonJointShape _jointShape = SkeletonJointShape.circle;

  // Sliders
  double _dotsOpacity = 1.0;
  double _connectionsOpacity = 1.0;
  double _dotsGlow = 0.0;
  double _connectionsGlow = 0.0;
  double _lineWidthScale = 1.0;
  double _outlineScale = 1.0;
  double _softness = 0.0;

  // Color options (null = use preset)
  SkeletonColorOption? _dotsInnerColor;
  SkeletonColorOption? _dotsOuterColor;
  SkeletonColorOption? _connectionsInnerColor;
  SkeletonColorOption? _connectionsOuterColor;

  @override
  void initState() {
    super.initState();
    _allowAudioMixing = widget.initialAllowAudioMixing;
    _showExternalAudioControl = widget.initialShowExternalAudioControl;
    _enableIntelligenceRest = widget.initialEnableIntelligenceRest;
    final c = widget.initialConfig;
    if (c != null) {
      _hidden = c.hidden ?? false;
      _preset = c.preset ?? SkeletonPreset.defaultPreset;
      _connectionStyle = c.connectionStyle ?? SkeletonConnectionStyle.solid;
      _jointShape = c.jointShape ?? SkeletonJointShape.circle;
      _dotsOpacity = c.dotsOpacity ?? 1.0;
      _connectionsOpacity = c.connectionsOpacity ?? 1.0;
      _dotsGlow = c.dotsGlow ?? 0.0;
      _connectionsGlow = c.connectionsGlow ?? 0.0;
      _lineWidthScale = c.lineWidthScale ?? 1.0;
      _outlineScale = c.outlineScale ?? 1.0;
      _softness = c.softness ?? 0.0;
      _dotsInnerColor = c.dotsInnerColor;
      _dotsOuterColor = c.dotsOuterColor;
      _connectionsInnerColor = c.connectionsInnerColor;
      _connectionsOuterColor = c.connectionsOuterColor;
    }
  }

  SkeletonConfig get _currentConfig => SkeletonConfig(
        hidden: _hidden,
        preset: _preset,
        connectionStyle: _connectionStyle,
        jointShape: _jointShape,
        dotsOpacity: _dotsOpacity,
        connectionsOpacity: _connectionsOpacity,
        dotsGlow: _dotsGlow,
        connectionsGlow: _connectionsGlow,
        lineWidthScale: _lineWidthScale,
        outlineScale: _outlineScale,
        softness: _softness,
        dotsInnerColor: _dotsInnerColor,
        dotsOuterColor: _dotsOuterColor,
        connectionsInnerColor: _connectionsInnerColor,
        connectionsOuterColor: _connectionsOuterColor,
      );

  Future<void> _applyAndDone() async {
    await widget.plugin.setConfig(
      config: SMKitConfig(
        allowAudioMixing: _allowAudioMixing,
        showExternalAudioControl: _showExternalAudioControl,
        enableIntelligenceRest: _enableIntelligenceRest,
        skeletonConfig: _currentConfig,
      ),
    );
    if (mounted) Navigator.of(context).pop(UISettingsResult(
      skeletonConfig: _currentConfig,
      allowAudioMixing: _allowAudioMixing,
      showExternalAudioControl: _showExternalAudioControl,
      enableIntelligenceRest: _enableIntelligenceRest,
    ));
  }

  // ── helpers ────────────────────────────────────────────────

  static String _presetName(SkeletonPreset p) {
    const names = {
      SkeletonPreset.defaultPreset: 'Default',
      SkeletonPreset.minimalDots: 'Minimal Dots',
      SkeletonPreset.thinOutline: 'Thin Outline',
      SkeletonPreset.monochromeClean: 'Monochrome Clean',
      SkeletonPreset.neonGlow: 'Neon Glow',
      SkeletonPreset.boldHighlight: 'Bold Highlight',
      SkeletonPreset.softFill: 'Soft Fill',
      SkeletonPreset.wireframe: 'Wireframe',
      SkeletonPreset.highContrast: 'High Contrast',
      SkeletonPreset.pastel: 'Pastel',
      SkeletonPreset.darkOutline: 'Dark Outline',
      SkeletonPreset.minimalLine: 'Minimal Line',
      SkeletonPreset.doubleStroke: 'Double Stroke',
      SkeletonPreset.gradientReady: 'Gradient Ready',
      SkeletonPreset.subtleShadow: 'Subtle Shadow',
      SkeletonPreset.classic: 'Classic',
      SkeletonPreset.athletic: 'Athletic',
      SkeletonPreset.premium: 'Premium',
      SkeletonPreset.hologram: 'Hologram',
      SkeletonPreset.matte: 'Matte',
      SkeletonPreset.neonPulse: 'Neon Pulse',
      SkeletonPreset.outlineOnly: 'Outline Only',
      SkeletonPreset.slim: 'Slim',
      SkeletonPreset.thick: 'Thick',
      SkeletonPreset.studio: 'Studio',
      SkeletonPreset.accessibility: 'Accessibility',
    };
    return names[p] ?? p.name;
  }

  static String _connectionName(SkeletonConnectionStyle s) {
    const names = {
      SkeletonConnectionStyle.none: 'None',
      SkeletonConnectionStyle.dotted: 'Dotted',
      SkeletonConnectionStyle.dashed: 'Dashed',
      SkeletonConnectionStyle.solid: 'Solid',
      SkeletonConnectionStyle.longDashed: 'Long Dashed',
      SkeletonConnectionStyle.thinDots: 'Thin Dots',
      SkeletonConnectionStyle.dotDashed: 'Dot Dashed',
      SkeletonConnectionStyle.rounded: 'Rounded',
    };
    return names[s] ?? s.name;
  }

  static String _jointShapeName(SkeletonJointShape s) {
    const names = {
      SkeletonJointShape.circle: 'Circle',
      SkeletonJointShape.square: 'Square',
      SkeletonJointShape.triangle: 'Triangle',
      SkeletonJointShape.diamond: 'Diamond',
      SkeletonJointShape.star: 'Star',
      SkeletonJointShape.hexagon: 'Hexagon',
    };
    return names[s] ?? s.name;
  }

  // ── build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Settings'),
        actions: [
          TextButton(
            onPressed: _applyAndDone,
            child: const Text('Apply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildSectionHeader('Session'),
          _buildToggleRow(
            label: 'Allow Audio Mixing',
            subtitle: 'Mix workout audio with external apps',
            value: _allowAudioMixing,
            onChanged: (v) => setState(() => _allowAudioMixing = v),
          ),
          _buildToggleRow(
            label: 'Show External Audio Control',
            subtitle: 'Display in-session audio source button',
            value: _showExternalAudioControl,
            onChanged: (v) => setState(() => _showExternalAudioControl = v),
          ),
          _buildToggleRow(
            label: 'Intelligence Rest',
            subtitle: 'Show AI-powered fatigue rest suggestions',
            value: _enableIntelligenceRest,
            onChanged: (v) => setState(() => _enableIntelligenceRest = v),
          ),
          const Divider(height: 24),
          _buildSectionHeader('Skeleton'),
          _buildLivePreview(),
          const SizedBox(height: 16),
          _buildHiddenToggle(),
          const SizedBox(height: 8),
          _buildSectionHeader('Preset'),
          ..._buildPresetRows(),
          _buildSectionHeader('Connection Style'),
          ..._buildConnectionRows(),
          _buildSectionHeader('Joint Shape'),
          ..._buildJointShapeRows(),
          _buildSectionHeader('Dots Glow'),
          _buildSlider(value: _dotsGlow, min: 0, max: 1, label: '0 — 1',
              onChanged: (v) => setState(() => _dotsGlow = v)),
          _buildSectionHeader('Connections Glow'),
          _buildSlider(value: _connectionsGlow, min: 0, max: 1, label: '0 — 1',
              onChanged: (v) => setState(() => _connectionsGlow = v)),
          _buildSectionHeader('Line Width Scale'),
          _buildSlider(value: _lineWidthScale, min: 0.5, max: 2, label: '0.5 — 2',
              onChanged: (v) => setState(() => _lineWidthScale = v)),
          _buildSectionHeader('Outline Scale'),
          _buildSlider(value: _outlineScale, min: 0.5, max: 2, label: '0.5 — 2',
              onChanged: (v) => setState(() => _outlineScale = v)),
          _buildSectionHeader('Softness'),
          _buildSlider(value: _softness, min: 0, max: 1, label: '0 — 1',
              onChanged: (v) => setState(() => _softness = v)),
          _buildSectionHeader('Dots Opacity'),
          _buildSlider(value: _dotsOpacity, min: 0, max: 1, label: '0 — 1',
              onChanged: (v) => setState(() => _dotsOpacity = v)),
          _buildSectionHeader('Dots Inner Color'),
          _buildColorChips(
            selected: _dotsInnerColor,
            onSelected: (c) => setState(() => _dotsInnerColor = c),
          ),
          _buildSectionHeader('Dots Outer Color'),
          _buildColorChips(
            selected: _dotsOuterColor,
            onSelected: (c) => setState(() => _dotsOuterColor = c),
          ),
          _buildSectionHeader('Connections Opacity'),
          _buildSlider(value: _connectionsOpacity, min: 0, max: 1, label: '0 — 1',
              onChanged: (v) => setState(() => _connectionsOpacity = v)),
          _buildSectionHeader('Connections Inner Color'),
          _buildColorChips(
            selected: _connectionsInnerColor,
            onSelected: (c) => setState(() => _connectionsInnerColor = c),
          ),
          _buildSectionHeader('Connections Outer Color'),
          _buildColorChips(
            selected: _connectionsOuterColor,
            onSelected: (c) => setState(() => _connectionsOuterColor = c),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _applyAndDone,
            child: const Text('Apply & Close'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLivePreview() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Text('Preview', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(width: 16),
            Expanded(
              child: _SkeletonPreview(
                preset: _preset,
                connectionStyle: _connectionStyle,
                jointShape: _jointShape,
                dotsOpacity: _dotsOpacity,
                connectionsOpacity: _connectionsOpacity,
                dotsGlow: _dotsGlow,
                lineWidthScale: _lineWidthScale,
                dotsInnerColor: _dotsInnerColor,
                connectionsInnerColor: _connectionsInnerColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildHiddenToggle() {
    return Row(
      children: [
        const Expanded(child: Text('Hide skeleton', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
        Switch(
          value: _hidden,
          onChanged: (v) => setState(() => _hidden = v),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
    );
  }

  List<Widget> _buildPresetRows() {
    return SkeletonPreset.values.map((p) {
      final selected = p == _preset;
      return GestureDetector(
        onTap: () => setState(() => _preset = p),
        child: Container(
          height: 44,
          color: selected ? Colors.blue.withOpacity(0.15) : Colors.transparent,
          child: Row(
            children: [
              SizedBox(
                width: 52,
                height: 28,
                child: _SkeletonPreview(
                  preset: p,
                  connectionStyle: _connectionStyle,
                  jointShape: _jointShape,
                  dotsOpacity: _dotsOpacity,
                  connectionsOpacity: _connectionsOpacity,
                  dotsGlow: _dotsGlow,
                  lineWidthScale: _lineWidthScale,
                  dotsInnerColor: _dotsInnerColor,
                  connectionsInnerColor: _connectionsInnerColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(_presetName(p), style: const TextStyle(fontSize: 15)),
              const Spacer(),
              if (selected) const Icon(Icons.check, color: Colors.blue, size: 18),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildConnectionRows() {
    return SkeletonConnectionStyle.values.map((s) {
      final selected = s == _connectionStyle;
      return GestureDetector(
        onTap: () => setState(() => _connectionStyle = s),
        child: Container(
          height: 44,
          color: selected ? Colors.blue.withOpacity(0.15) : Colors.transparent,
          child: Row(
            children: [
              SizedBox(
                width: 52,
                height: 28,
                child: _SkeletonPreview(
                  preset: _preset,
                  connectionStyle: s,
                  jointShape: _jointShape,
                  dotsOpacity: _dotsOpacity,
                  connectionsOpacity: _connectionsOpacity,
                  dotsGlow: _dotsGlow,
                  lineWidthScale: _lineWidthScale,
                  dotsInnerColor: _dotsInnerColor,
                  connectionsInnerColor: _connectionsInnerColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(_connectionName(s), style: const TextStyle(fontSize: 15)),
              const Spacer(),
              if (selected) const Icon(Icons.check, color: Colors.blue, size: 18),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildJointShapeRows() {
    return SkeletonJointShape.values.map((s) {
      final selected = s == _jointShape;
      return GestureDetector(
        onTap: () => setState(() => _jointShape = s),
        child: Container(
          height: 44,
          color: selected ? Colors.blue.withOpacity(0.15) : Colors.transparent,
          child: Row(
            children: [
              SizedBox(
                width: 52,
                height: 28,
                child: _SkeletonPreview(
                  preset: _preset,
                  connectionStyle: _connectionStyle,
                  jointShape: s,
                  dotsOpacity: _dotsOpacity,
                  connectionsOpacity: _connectionsOpacity,
                  dotsGlow: _dotsGlow,
                  lineWidthScale: _lineWidthScale,
                  dotsInnerColor: _dotsInnerColor,
                  connectionsInnerColor: _connectionsInnerColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(_jointShapeName(s), style: const TextStyle(fontSize: 15)),
              const Spacer(),
              if (selected) const Icon(Icons.check, color: Colors.blue, size: 18),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(value.toStringAsFixed(2),
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildColorChips({
    required SkeletonColorOption? selected,
    required ValueChanged<SkeletonColorOption?> onSelected,
  }) {
    const chipSize = 36.0;
    return SizedBox(
      height: chipSize + 12,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // "P" chip = use preset (nil)
          GestureDetector(
            onTap: () => onSelected(null),
            child: Container(
              width: chipSize,
              height: chipSize,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected == null ? Colors.blue : Colors.grey.shade400,
                  width: selected == null ? 3 : 1.5,
                ),
              ),
              child: const Center(
                child: Text('P', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
              ),
            ),
          ),
          ...SkeletonColorOption.values.map((opt) {
            final isSelected = selected == opt;
            final color = _skeletonColors[opt] ?? Colors.grey;
            return GestureDetector(
              onTap: () => onSelected(opt),
              child: Container(
                width: chipSize,
                height: chipSize,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade400,
                    width: isSelected ? 3 : 1.5,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
