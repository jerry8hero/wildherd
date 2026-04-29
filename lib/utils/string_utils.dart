/// 字符串工具类
class StringUtils {
  /// 判断是否为空或仅包含空白
  static bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// 判断是否非空
  static bool isNotEmpty(String? value) {
    return !isEmpty(value);
  }

  /// 截断字符串并添加省略号
  static String truncate(String value, int maxLength, {String suffix = '...'}) {
    if (value.length <= maxLength) return value;
    return '${value.substring(0, maxLength - suffix.length)}$suffix';
  }

  /// 安全获取字符串（为空时返回默认值）
  static String defaultIfEmpty(String? value, String defaultValue) {
    return isEmpty(value) ? defaultValue : value!;
  }

  /// 格式化日期时间（短格式）
  static String formatDateTimeShort(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// 脱敏处理（用于日志）
  static String sanitizeForLog(String value, {int visibleChars = 3}) {
    if (value.length <= visibleChars) return value;
    return '${value.substring(0, visibleChars)}***';
  }
}
