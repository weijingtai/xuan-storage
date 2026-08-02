// 期望：UNDEFINED_NAMED_PARAMETER —— control 工厂没有任何参数
import 'package:persistence_core/persistence_core.dart';

const v2 = StoragePolicy.control(publisher: Publisher.user);
