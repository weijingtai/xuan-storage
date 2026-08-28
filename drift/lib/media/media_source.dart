import 'package:repository_interface_media/repository_interface_media.dart';

/// 一次媒体采集的原始数据（采集侧来源，如相机/相册/文件/测试内存）。
///
/// 本对象只存在于采集边界：进入 blob 存储后即被丢弃，业务层只持有稳定
/// [MediaReference]。禁止把 [bytes] 或任何文件路径带进业务模型。
class MediaSourceData {
  final List<int> bytes;
  final String mimeType;
  final int? width;
  final int? height;
  final int? durationMs;
  final int? fileSizeBytes;

  const MediaSourceData({
    required this.bytes,
    required this.mimeType,
    this.width,
    this.height,
    this.durationMs,
    this.fileSizeBytes,
  });

  int get sizeBytes => fileSizeBytes ?? bytes.length;
}

/// 平台采集回调：由 Shell 组合根注入真实采集器（image_picker 等），
/// 测试注入内存字节。适配器负责把原始数据交给 xuan-storage blob 生命周期。
typedef MediaSourcePicker =
    Future<MediaSourceData> Function(
      MediaRole role, {
      double? maxWidth,
      double? maxHeight,
      int? maxDurationMs,
    });

/// 视频关键帧解码回调：由平台注入（ffmpeg 等解码器），适配器负责持久化。
typedef VideoKeyframeProvider =
    Future<MediaSourceData> Function(
      MediaReference sourceVideo,
      int positionMs, {
      double? maxWidth,
      double? maxHeight,
    });
