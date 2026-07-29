import 'package:hugeicons/hugeicons.dart';

class ServiceIconRule {
  final List<String> keywords;
  final dynamic icon;

  const ServiceIconRule({required this.keywords, required this.icon});
}

final List<ServiceIconRule> _serviceIconRules = [
  const ServiceIconRule(
    keywords: [
      'deliver',
      'courier',
      'parcel',
      'ship',
      'dispatch',
      'logistics',
      'errand',
      'drop off',
      'pick up',
    ],
    icon: HugeIcons.strokeRoundedDeliveryTruck01,
  ),
  const ServiceIconRule(
    keywords: [
      'clean',
      'housekeep',
      'laundry',
      'maid',
      'sanitize',
      'wash',
      'mop',
      'tidy',
      'vacuum',
      'deep clean',
      'window',
    ],
    icon: HugeIcons.strokeRoundedClean,
  ),
  const ServiceIconRule(
    keywords: [
      'plumb',
      'pipe',
      'drain',
      'leak',
      'tap',
      'water',
      'sink',
      'toilet',
      'sewer',
      'faucet',
    ],
    icon: HugeIcons.strokeRoundedWrench01,
  ),
  const ServiceIconRule(
    keywords: [
      'mov',
      'haul',
      'relocat',
      'pack',
      'shift',
      'transport',
      'cargo',
      'lift',
    ],
    icon: HugeIcons.strokeRoundedTruckDelivery,
  ),
  const ServiceIconRule(
    keywords: [
      'electr',
      'power',
      'wire',
      'light',
      'generator',
      'solar',
      'socket',
      'plug',
      'circuit',
      'installation',
      'mount',
    ],
    icon: HugeIcons.strokeRoundedZap,
  ),
  const ServiceIconRule(
    keywords: [
      'paint',
      'decorat',
      'wall',
      'coat',
      'brush',
      'interior',
      'exterior',
    ],
    icon: HugeIcons.strokeRoundedPaintBrush01,
  ),
  const ServiceIconRule(
    keywords: [
      'garden',
      'lawn',
      'yard',
      'plant',
      'tree',
      'landscape',
      'grass',
      'mow',
      'trim',
      'weed',
    ],
    icon: HugeIcons.strokeRoundedPlant01,
  ),
  const ServiceIconRule(
    keywords: [
      'carpent',
      'furnitur',
      'assembl',
      'wood',
      'cabinet',
      'table',
      'chair',
      'bed',
      'handyman',
    ],
    icon: HugeIcons.strokeRoundedTools,
  ),
  const ServiceIconRule(
    keywords: [
      'mechanic',
      'auto',
      'car ',
      'vehicle',
      'repair',
      'fix',
      'engine',
      'brake',
      'tire',
      'oil',
    ],
    icon: HugeIcons.strokeRoundedWrench01,
  ),
  const ServiceIconRule(
    keywords: [
      'beaut',
      'hair',
      'salon',
      'barber',
      'makeup',
      'nail',
      'spa',
      'massage',
      'skin',
      'styling',
    ],
    icon: HugeIcons.strokeRoundedScissor,
  ),
  const ServiceIconRule(
    keywords: [
      'tech',
      'comput',
      'it ',
      'laptop',
      'phone',
      'device',
      'software',
      'screen',
      'network',
      'wifi',
    ],
    icon: HugeIcons.strokeRoundedComputer,
  ),
  const ServiceIconRule(
    keywords: [
      'cook',
      'cater',
      'chef',
      'food',
      'bake',
      'meal',
      'dish',
      'kitchen',
    ],
    icon: HugeIcons.strokeRoundedRestaurant01,
  ),
  const ServiceIconRule(
    keywords: [
      'tutor',
      'teach',
      'lesson',
      'educat',
      'class',
      'study',
      'school',
    ],
    icon: HugeIcons.strokeRoundedBookOpen01,
  ),
  const ServiceIconRule(
    keywords: [
      'secur',
      'lock',
      'guard',
      'safety',
      'cctv',
      'camera',
      'alarm',
      'locksmith',
    ],
    icon: HugeIcons.strokeRoundedShield01,
  ),
  const ServiceIconRule(
    keywords: ['ac ', 'air con', 'hvac', 'refrigerat', 'appliance', 'fridge'],
    icon: HugeIcons.strokeRoundedTools,
  ),
];

dynamic getServiceIcon(String? serviceName) {
  if (serviceName == null || serviceName.trim().isEmpty) {
    return HugeIcons.strokeRoundedTools;
  }

  final name = serviceName.toLowerCase().trim();

  for (final rule in _serviceIconRules) {
    if (rule.keywords.any((keyword) => name.contains(keyword))) {
      return rule.icon;
    }
  }

  return HugeIcons.strokeRoundedTools;
}
