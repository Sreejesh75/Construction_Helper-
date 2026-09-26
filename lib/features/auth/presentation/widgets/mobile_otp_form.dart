import 'dart:async';
import 'package:construction_app/core/theme/app_color.dart';
import 'package:construction_app/features/auth/bloc/login_bloc.dart';
import 'package:construction_app/features/auth/bloc/login_event.dart';
import 'package:construction_app/features/auth/bloc/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MobileOtpForm extends StatefulWidget {
  final LoginState state;

  const MobileOtpForm({
    super.key,
    required this.state,
  });

  @override
  State<MobileOtpForm> createState() => _MobileOtpFormState();
}

class _MobileOtpFormState extends State<MobileOtpForm> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _secondsRemaining = 120; // 2 minutes countdown

  @override
  void initState() {
    super.initState();
    if (widget.state.isOtpSent) {
      _startCountdown();
    }
  }

  @override
  void didUpdateWidget(covariant MobileOtpForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart timer when OTP is freshly sent
    if (widget.state.isOtpSent && (!oldWidget.state.isOtpSent || oldWidget.state.phone != widget.state.phone)) {
      _startCountdown();
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 120;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.state.isOtpSent) {
      return _buildRequestOtpStep(context);
    } else {
      return _buildVerifyOtpStep(context);
    }
  }

  /// Step 1: Request OTP Form
  Widget _buildRequestOtpStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          onChanged: (value) =>
              context.read<LoginBloc>().add(LoginPhoneChanged(value)),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: InputDecoration(
            hintText: '9876543210',
            labelText: 'Mobile Number',
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: const Text(
                "+91",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
            hintStyle: TextStyle(color: Colors.grey[400]),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Send OTP Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: widget.state.isLoading
                ? null
                : () {
                    _startCountdown();
                    context.read<LoginBloc>().add(const SendOtpRequested());
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
            ),
            child: widget.state.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    "Send OTP",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  /// Step 2: Verify OTP Form
  Widget _buildVerifyOtpStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phone Info Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.phonelink_ring_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "OTP sent to +91 ${widget.state.phone}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.heading,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                onPressed: () {
                  _timer?.cancel();
                  _otpController.clear();
                  context.read<LoginBloc>().add(ResetOtpStateRequested());
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // OTP Label & Countdown Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Enter 4-digit code",
              style: TextStyle(
                fontSize: 13,
                color: AppColors.subtitle,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _secondsRemaining > 0
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 15,
                    color: _secondsRemaining > 0 ? AppColors.primary : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formattedTime,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _secondsRemaining > 0 ? AppColors.primary : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // OTP Input
        TextFormField(
          controller: _otpController,
          onChanged: (value) =>
              context.read<LoginBloc>().add(LoginOtpChanged(value)),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 12,
          ),
          decoration: InputDecoration(
            hintText: '••••',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              letterSpacing: 12,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Verify OTP Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: widget.state.isLoading
                ? null
                : () {
                    context.read<LoginBloc>().add(VerifyOtpRequested());
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
            ),
            child: widget.state.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    "Verify OTP & Sign In",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 14),

        // Resend OTP Section with Timer
        Center(
          child: _secondsRemaining > 0
              ? Text(
                  "Resend code in $_formattedTime",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : TextButton.icon(
                  onPressed: widget.state.isLoading
                      ? null
                      : () {
                          _startCountdown();
                          context.read<LoginBloc>().add(const SendOtpRequested());
                        },
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    "Resend OTP Code",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
