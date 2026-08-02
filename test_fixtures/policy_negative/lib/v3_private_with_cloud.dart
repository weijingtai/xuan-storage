// 期望：UNDEFINED_NAMED_PARAMETER —— private 工厂没有 cloud 参数（cloud 结构上不可关闭）
import 'package:persistence_core/persistence_core.dart';

const v3 = StoragePolicy.private(carriers: {Carrier.row}, cloud: false);
