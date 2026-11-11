import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import '../validators/login_validator.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      duration: Durations.medium4,
      reverseDuration: Durations.medium4,
      overlayColor: AppColors.white,
      overlayWidgetBuilder: (_) =>
          Center(child: Lottie.asset(AppAssets.loader)),
      child: BlocProvider(
        create: (_) => sl<LoginCubit>(),
        child: const _LoginView(),
      ),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<LoginCubit>().login(_idController.text);
  }

  void _onStateChanged(BuildContext context, LoginState state) {
    if (state is LoginLoading) {
      if (!context.loaderOverlay.visible) context.loaderOverlay.show();
      return;
    }
    context.loaderOverlay.hide();

    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    switch (state) {
      case LoginSuccess():
        // TODO: Navigate to the dashboard once it is implemented.
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Login successful'),
            backgroundColor: AppColors.success,
          ),
        );
      case LoginError(:final message):
        messenger.showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
      case LoginInitial():
      case LoginLoading():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.white,
      body: BlocListener<LoginCubit, LoginState>(
        listener: _onStateChanged,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Top banner logo (full width).
                  SizedBox(
                    width: double.infinity,
                    height: 140.h,
                    child: Image.asset(AppAssets.topLogo, fit: BoxFit.fill),
                  ),

                  // "22nd" circle logo.
                  Image.asset(
                    AppAssets.middleLogo,
                    height: 140.h,
                    fit: BoxFit.contain,
                  ),

                  Text(
                    'Annual Global\nInvestor Conference',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tinos(
                      color: AppColors.darkBlue,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),

                  // "India Ahead" logo.
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48.w),
                    child: Image.asset(
                      AppAssets.indiaAhead,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50.w),
                    child: _ClientIdField(
                      controller: _idController,
                      onSubmitted: _onLoginPressed,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50.w),
                    child: _LoginButton(onPressed: _onLoginPressed),
                  ),

                  SizedBox(height: 14.h),

                  Text(
                    'Access permitted to registered\nusers only',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.darkBlue,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClientIdField extends StatelessWidget {
  const _ClientIdField({required this.controller, required this.onSubmitted});

  final TextEditingController controller;
  final VoidCallback onSubmitted;

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(30.r),
    borderSide: BorderSide(color: color, width: width),
  );

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: AppColors.textHint, fontSize: 16.sp);

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      maxLength: LoginValidator.clientIdLength,
      textAlign: TextAlign.center,
      style: textStyle,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: LoginValidator.clientId,
      onFieldSubmitted: (_) => onSubmitted(),
      decoration: InputDecoration(
        hintText: '${LoginValidator.clientIdLength} Digit ID',
        hintStyle: textStyle,
        counterText: '',
        errorMaxLines: 2,
        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        enabledBorder: _border(AppColors.textHint, 1.2),
        focusedBorder: _border(AppColors.darkBlue, 1.5),
        errorBorder: _border(AppColors.error, 1.2),
        focusedErrorBorder: _border(AppColors.error, 1.5),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<LoginCubit, bool>(
      (cubit) => cubit.state is LoginLoading,
    );

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkBlue,
          disabledBackgroundColor: AppColors.darkBlue.withValues(alpha: 0.6),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'Login',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
