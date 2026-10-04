import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/paper_background.dart';
import '../../providers/database_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  final bool isSettingPin;

  const LockScreen({super.key, this.isSettingPin = false});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _enteredPin = '';
  String _errorMessage = '';

  void _onDigitPress(String digit) async {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
        _errorMessage = '';
      });

      if (_enteredPin.length == 4) {
        final sec = ref.read(securityServiceProvider);
        if (widget.isSettingPin) {
          await sec.savePin(_enteredPin);
          if (mounted) context.pop();
        } else {
          final valid = await sec.verifyPin(_enteredPin);
          if (valid) {
            if (mounted) context.go('/');
          } else {
            setState(() {
              _enteredPin = '';
              _errorMessage = 'Incorrect PIN. Please try again.';
            });
          }
        }
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PaperBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.vintageGold.withAlpha(40),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: AppColors.vintageGold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.isSettingPin ? 'Set 4-Digit PIN' : 'Chronicle is Locked',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.inkPrimaryDark
                      : AppColors.inkPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.isSettingPin
                    ? 'Choose a memorable 4-digit security code'
                    : 'Enter your secret PIN to access memories',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 13,
                  color: isDark
                      ? AppColors.inkSecondaryDark
                      : AppColors.inkSecondaryLight,
                ),
              ),
              const SizedBox(height: 28),

              // PIN Indicator dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _enteredPin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? AppColors.vintageGold
                          : Colors.transparent,
                      border: Border.all(
                        color: isFilled
                            ? AppColors.vintageGold
                            : AppColors.paperCardBorderLight,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),

              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],

              const Spacer(),

              // Keypad
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    _buildKeypadRow(['1', '2', '3']),
                    const SizedBox(height: 16),
                    _buildKeypadRow(['4', '5', '6']),
                    const SizedBox(height: 16),
                    _buildKeypadRow(['7', '8', '9']),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const SizedBox(width: 64, height: 64),
                        _buildKeypadButton('0'),
                        InkWell(
                          onTap: _onBackspace,
                          borderRadius: BorderRadius.circular(32),
                          child: Container(
                            width: 64,
                            height: 64,
                            alignment: Alignment.center,
                            child: const Icon(Icons.backspace_outlined),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: digits.map((d) => _buildKeypadButton(d)).toList(),
    );
  }

  Widget _buildKeypadButton(String digit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => _onDigitPress(digit),
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? AppColors.paperCardDark : AppColors.paperCardLight,
          border: Border.all(
            color: isDark
                ? AppColors.paperCardBorderDark
                : AppColors.paperCardBorderLight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
