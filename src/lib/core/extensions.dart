import 'package:vocabulary_advancer/core/model.dart';
import 'package:vocabulary_advancer/core/services/rate_calculator.dart';
import 'package:vocabulary_advancer/shared/svc.dart';

extension DurationExt on Duration {
  bool isTargetClose() => isNegative || inMinutes < svc.values.targetMinutesLowThreshold;
  bool isTargetFar() => !isNegative && inHours > svc.values.targetHoursHighThreshold;

  String toStringAsTarget() {
    if (isNegative || inSeconds < 60) return '';

    final sb = StringBuffer();

    if (inDays > 1) {
      sb.write('${inDays}d');
    } else if (inHours > 1) {
      sb.write('${inHours}h');
    } else {
      sb.write('${inMinutes}m');
    }

    return sb.toString();
  }
}

extension DateTimeExt on DateTime {
  Duration differenceNowUtc() => difference(DateTime.now().toUtc());
}

extension IntExt on int {
  bool isRateLow() => this <= svc.values.rateLowThreshold;
  bool isRateHigh() => this > svc.values.rateHighThreshold;

  int asRate(RateFeedback feedback) => calculateNextRate(this, feedback);
  Duration asCooldown(RateFeedback feedback) => calculateCooldown(this, feedback);
}
