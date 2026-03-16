import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cografist/core/theme/app_colors.dart';
import 'package:cografist/services/firebase_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin  = true;
  bool _loading  = false;
  bool _obscure  = true;

  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _nameCtrl  = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_isLogin) {
        await FirebaseService.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
      } else {
        await FirebaseService.registerWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
      }
      if (mounted) context.go('/exam-select');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    try {
      final cred = await FirebaseService.signInWithGoogle();
      if (cred != null && mounted) context.go('/exam-select');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google girişi başarısız'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _errorMessage(String e) {
    if (e.contains('user-not-found'))  return 'Bu e-posta adresiyle kayıtlı hesap bulunamadı';
    if (e.contains('wrong-password'))  return 'Şifre hatalı';
    if (e.contains('email-already'))   return 'Bu e-posta zaten kayıtlı';
    if (e.contains('weak-password'))   return 'Şifre en az 6 karakter olmalı';
    if (e.contains('invalid-email'))   return 'Geçersiz e-posta adresi';
    return 'Bir hata oluştu, tekrar dene';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: Text('🗺️', style: TextStyle(fontSize: 32))),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

              const SizedBox(height: 24),

              Text(
                _isLogin ? 'Tekrar hoş geldin' : 'Hesap oluştur',
                style: Theme.of(context).textTheme.displayMedium,
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 8),
              Text(
                _isLogin ? 'Coğrafist hesabına giriş yap' : 'Ücretsiz başla',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Adın'),
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.isEmpty) ? 'Ad gerekli' : null,
                      ),
                      const SizedBox(height: 12),
                    ],

                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'E-posta'),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'E-posta gerekli';
                        if (!v.contains('@')) return 'Geçerli e-posta gir';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _passCtrl,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Şifre gerekli';
                        if (!_isLogin && v.length < 6) return 'En az 6 karakter';
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Ana buton
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
              ),

              const SizedBox(height: 16),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('veya', style: Theme.of(context).textTheme.bodySmall),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 16),

              // Google
              OutlinedButton.icon(
                onPressed: _loading ? null : _googleSignIn,
                icon: const Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF4285F4))),
                label: const Text('Google ile devam et'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: AppColors.border),
                ),
              ),

              const SizedBox(height: 24),

              // Toggle login/register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin ? 'Hesabın yok mu?' : 'Zaten hesabın var mı?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(_isLogin ? 'Kayıt ol' : 'Giriş yap'),
                  ),
                ],
              ),

              // Skip
              Center(
                child: TextButton(
                  onPressed: () => context.go('/exam-select'),
                  child: const Text(
                    'Şimdilik atla',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
