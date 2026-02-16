/// 日期工具类
class DateTimeUtils {
  /// 格式化日期为 YYYY-MM-DD
  static String formatDate(DateTime? date) {
    if (date == null) return '未设置';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 格式化相对时间（如：2小时前、3天前）
  static String formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}周前';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()}个月前';
    } else {
      return '${(diff.inDays / 365).floor()}年前';
    }
  }

  /// 格式化时间为 MM-DD
  static String formatMonthDay(DateTime time) {
    return '${time.month}-${time.day}';
  }

  /// 格式化时间为 HH:mm
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
