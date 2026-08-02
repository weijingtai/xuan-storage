// 期望：CONST_WITH_UNDEFINED_CONSTRUCTOR_DEFAULT —— 子类构造器私有，跨库不可见
import 'package:persistence_core/persistence_core.dart';

const v5 = PrivatePolicy(carriers: {Carrier.row});
