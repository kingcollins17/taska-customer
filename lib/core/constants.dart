import 'package:flutter/widgets.dart';
import 'package:queue/queue.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

const naira = '₦';

final appQueue = Queue();