import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class CategoryIconRule {
  final List<String> keywords;
  final dynamic icon;

  const CategoryIconRule({required this.keywords, required this.icon});
}

final List<CategoryIconRule> _categoryIconRules = [
  const CategoryIconRule(
    keywords: [
      'deliver',
      'courier',
      'parcel',
      'ship',
      'dispatch',
      'logistics',
      'errand',
    ],
    icon: HugeIcons.strokeRoundedDeliveryTruck01,
  ),
  const CategoryIconRule(
    keywords: [
      'clean',
      'housekeep',
      'laundry',
      'maid',
      'sanitize',
      'wash',
      'mop',
      'tidy',
    ],
    icon: HugeIcons.strokeRoundedClean,
  ),
  const CategoryIconRule(
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
    ],
    icon: HugeIcons.strokeRoundedWrench01,
  ),
  const CategoryIconRule(
    keywords: ['mov', 'haul', 'relocat', 'pack', 'shift', 'transport', 'cargo'],
    icon: HugeIcons.strokeRoundedTruckDelivery,
  ),
  const CategoryIconRule(
    keywords: [
      'electr',
      'power',
      'wire',
      'light',
      'generator',
      'solar',
      'socket',
      'plug',
    ],
    icon: HugeIcons.strokeRoundedZap,
  ),
  const CategoryIconRule(
    keywords: ['paint', 'decorat', 'wall', 'coat', 'brush'],
    icon: HugeIcons.strokeRoundedPaintBrush01,
  ),
  const CategoryIconRule(
    keywords: [
      'garden',
      'lawn',
      'yard',
      'plant',
      'tree',
      'landscape',
      'grass',
      'mow',
    ],
    icon: HugeIcons.strokeRoundedPlant01,
  ),
  const CategoryIconRule(
    keywords: [
      'carpent',
      'furnitur',
      'assembl',
      'wood',
      'cabinet',
      'table',
      'chair',
      'bed',
    ],
    icon: HugeIcons.strokeRoundedTools,
  ),
  const CategoryIconRule(
    keywords: [
      'mechanic',
      'auto',
      'car ',
      'vehicle',
      'repair',
      'fix',
      'engine',
      'brake',
    ],
    icon: HugeIcons.strokeRoundedWrench01,
  ),
  const CategoryIconRule(
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
    ],
    icon: HugeIcons.strokeRoundedScissor,
  ),
  const CategoryIconRule(
    keywords: [
      'tech',
      'comput',
      'it ',
      'laptop',
      'phone',
      'device',
      'software',
      'screen',
    ],
    icon: HugeIcons.strokeRoundedComputer,
  ),
  const CategoryIconRule(
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
  const CategoryIconRule(
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
  const CategoryIconRule(
    keywords: ['secur', 'lock', 'guard', 'safety', 'cctv', 'camera', 'alarm'],
    icon: HugeIcons.strokeRoundedShield01,
  ),
  const CategoryIconRule(
    keywords: ['ac ', 'air con', 'hvac', 'refrigerat', 'appliance', 'fridge'],
    icon: HugeIcons.strokeRoundedTools,
  ),
];

dynamic getCategoryIcon(String? categoryName) {
  if (categoryName == null || categoryName.trim().isEmpty) {
    return HugeIcons.strokeRoundedGrid;
  }

  final name = categoryName.toLowerCase().trim();

  for (final rule in _categoryIconRules) {
    if (rule.keywords.any((keyword) => name.contains(keyword))) {
      return rule.icon;
    }
  }

  return HugeIcons.strokeRoundedGrid02;
}
