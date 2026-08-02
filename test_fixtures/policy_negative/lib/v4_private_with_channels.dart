// 期望：UNDEFINED_NAMED_PARAMETER —— private 工厂没有 channels 参数
import 'package:persistence_core/persistence_core.dart';

const v4 = StoragePolicy.private(
  carriers: {Carrier.row},
  channels: {Channel.lan},
);
