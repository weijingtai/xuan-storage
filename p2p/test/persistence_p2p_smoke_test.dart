import 'package:flutter_test/flutter_test.dart';
// 走包入口消费：契约交付了但消费不到 = 没交付（纪律第 3 条）。
import 'package:persistence_p2p/persistence_p2p.dart';

/// P4 包成形冒烟测试：barrel 必须能拿到 LocalSignaling。
void main() {
  test('barrel 导出 LocalSignaling', () {
    expect(LocalSignaling, isNotNull,
        reason: '消费方从包入口必须拿得到 LocalSignaling');
    expect(LocalSignaling(), isA<LocalSignaling>());
  });
}
