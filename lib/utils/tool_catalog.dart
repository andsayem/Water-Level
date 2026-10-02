import 'package:flutter/material.dart';

import '../screens/angle_finder_screen.dart';
import '../screens/camera_level_screen.dart';
import '../screens/caravan_level_screen.dart';
import '../screens/compass_screen.dart';
import '../screens/height_meter_screen.dart';
import '../screens/metal_detector_screen.dart';
import '../screens/plumb_level_screen.dart';
import '../screens/protractor_screen.dart';
import '../screens/ruler_screen.dart';
import '../screens/slope_screen.dart';
import '../screens/sound_meter_screen.dart';
import '../screens/surface_level_screen.dart';
import '../screens/vibration_meter_screen.dart';

class ToolInfo {
  final IconData icon;
  final String label;
  final String description;
  final String category;
  final WidgetBuilder builder;
  final bool isNew;

  const ToolInfo({
    required this.icon,
    required this.label,
    required this.description,
    required this.category,
    required this.builder,
    this.isNew = false,
  });
}

/// Every measuring tool in the app, grouped by [ToolInfo.category] in the
/// order the Tools tab shows them.
final List<ToolInfo> toolCatalog = [
  ToolInfo(
    icon: Icons.blur_circular_rounded,
    label: 'Surface Level',
    description: 'Big bullseye for tables & floors',
    category: 'Leveling',
    builder: (_) => const SurfaceLevelScreen(),
  ),
  ToolInfo(
    icon: Icons.straighten_rounded,
    label: 'Plumb Level',
    description: 'Walls, poles & door frames',
    category: 'Leveling',
    builder: (_) => const PlumbLevelScreen(),
  ),
  ToolInfo(
    icon: Icons.camera_alt_rounded,
    label: 'Camera Level',
    description: 'Live horizon on the camera',
    category: 'Leveling',
    builder: (_) => const CameraLevelScreen(),
  ),
  ToolInfo(
    icon: Icons.rv_hookup_rounded,
    label: 'Caravan Leveler',
    description: 'How high to lift each wheel',
    category: 'Leveling',
    builder: (_) => const CaravanLevelScreen(),
    isNew: true,
  ),
  ToolInfo(
    icon: Icons.architecture_rounded,
    label: 'Protractor',
    description: 'Measure any angle',
    category: 'Angles',
    builder: (_) => const ProtractorScreen(),
  ),
  ToolInfo(
    icon: Icons.track_changes_rounded,
    label: 'Angle Finder',
    description: 'Beeps at your target angle',
    category: 'Angles',
    builder: (_) => const AngleFinderScreen(),
    isNew: true,
  ),
  ToolInfo(
    icon: Icons.roofing_rounded,
    label: 'Slope / Roof Pitch',
    description: 'Grade %, pitch & ratio',
    category: 'Angles',
    builder: (_) => const SlopeScreen(),
  ),
  ToolInfo(
    icon: Icons.explore_rounded,
    label: 'Compass',
    description: 'Heading & direction',
    category: 'Angles',
    builder: (_) => const CompassScreen(),
  ),
  ToolInfo(
    icon: Icons.square_foot_rounded,
    label: 'Ruler',
    description: 'cm & inch on screen',
    category: 'Measure',
    builder: (_) => const RulerScreen(),
  ),
  ToolInfo(
    icon: Icons.height_rounded,
    label: 'Height Meter',
    description: 'Trees & buildings',
    category: 'Measure',
    builder: (_) => const HeightMeterScreen(),
  ),
  ToolInfo(
    icon: Icons.graphic_eq_rounded,
    label: 'Sound Meter',
    description: 'Noise level in dB',
    category: 'Detect',
    builder: (_) => const SoundMeterScreen(),
  ),
  ToolInfo(
    icon: Icons.sensors_rounded,
    label: 'Metal Detector',
    description: 'Find pipes & nails',
    category: 'Detect',
    builder: (_) => const MetalDetectorScreen(),
  ),
  ToolInfo(
    icon: Icons.ssid_chart_rounded,
    label: 'Vibration Meter',
    description: 'Live seismograph',
    category: 'Detect',
    builder: (_) => const VibrationMeterScreen(),
    isNew: true,
  ),
];

const toolCategories = ['Leveling', 'Angles', 'Measure', 'Detect'];
