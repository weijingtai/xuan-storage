// 期望：UNDEFINED_NAMED_PARAMETER —— shared 工厂没有 channels 参数
import 'package:persistence_core/persistence_core.dart';

const v1 = StoragePolicy.shared(
  carriers: {Carrier.row},
  channels: {Channel.lan},
);
