import 'package:flutter_test/flutter_test.dart';
import 'package:chronicle/domain/usecases/calculate_streak_usecase.dart';

void main() {
  late CalculateStreakUseCase useCase;

  setUp(() {
    useCase = CalculateStreakUseCase();
  });

  test('Empty dates returns streak 0', () {
    final result = useCase.execute([]);
    expect(result.currentStreak, 0);
    expect(result.longestStreak, 0);
  });

  test('Single entry today returns streak 1', () {
    final today = DateTime.now();
    final result = useCase.execute([today]);
    expect(result.currentStreak, 1);
    expect(result.longestStreak, 1);
  });

  test('Consecutive entries across 3 days returns streak 3', () {
    final today = DateTime.now();
    final dates = [
      today,
      today.subtract(const Duration(days: 1)),
      today.subtract(const Duration(days: 2)),
    ];
    final result = useCase.execute(dates);
    expect(result.currentStreak, 3);
    expect(result.longestStreak, 3);
  });

  test('Multiple entries on the same day count as single day', () {
    final today = DateTime.now();
    final dates = [
      today,
      today.subtract(const Duration(hours: 2)),
      today.subtract(const Duration(days: 1)),
    ];
    final result = useCase.execute(dates);
    expect(result.currentStreak, 2);
    expect(result.longestStreak, 2);
  });

  test('Break in streak records correct current and longest streak', () {
    final today = DateTime.now();
    final dates = [
      today, // day 0
      today.subtract(const Duration(days: 1)), // day 1 -> current streak 2
      // Gap at day 2
      today.subtract(const Duration(days: 3)),
      today.subtract(const Duration(days: 4)),
      today.subtract(const Duration(days: 5)),
      today.subtract(const Duration(days: 6)), // 4-day streak in past
    ];
    final result = useCase.execute(dates);
    expect(result.currentStreak, 2);
    expect(result.longestStreak, 4);
  });
}
