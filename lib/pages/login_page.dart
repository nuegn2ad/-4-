import 'package:flutter/material.dart';

import 'home_page.dart';

class _Account {
  const _Account(this.password, this.isAdmin);

  final String password;
  final bool isAdmin;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 테스트용 계정 (Firebase 연동 후에는 서버 로그인으로 교체)
  static const Map<String, _Account> _accounts = {
    'admin': _Account('admin123', true),
    '2026001': _Account('1234', false),
  };

  final idController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordFocus = FocusNode();

  bool hidePassword = true;
  bool loading = false;

  String? idError;
  String? passwordError;
  String? loginError;

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (loading) return;

    final id = idController.text.trim();
    final password = passwordController.text;

    setState(() {
      idError = id.isEmpty ? '학번 또는 관리자 ID를 입력해 주세요.' : null;
      passwordError = password.isEmpty ? '비밀번호를 입력해 주세요.' : null;
      loginError = null;
    });
    if (id.isEmpty || password.isEmpty) return;

    setState(() => loading = true);

    // 서버 로그인에 걸리는 시간을 가정한 짧은 대기 (Firebase 연동 시 실제 요청으로 교체)
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final account = _accounts[id];
    if (account == null || account.password != password) {
      setState(() {
        loading = false;
        loginError = '학번(ID) 또는 비밀번호를 확인해 주세요.';
      });
      passwordController.clear();
      passwordFocus.requestFocus();
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(
          studentId: account.isAdmin ? '관리자' : id,
          isAdmin: account.isAdmin,
        ),
      ),
    );
  }

  /// 테스트 계정을 누르면 아이디와 비밀번호를 자동 입력합니다.
  void fillAccount(String id, String password) {
    setState(() {
      idController.text = id;
      passwordController.text = password;
      idError = null;
      passwordError = null;
      loginError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F9FE),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.school_rounded, size: 72, color: primary),
                  const SizedBox(height: 20),
                  const Text(
                    '대학교 공용물품 대여 서비스',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '학번과 비밀번호로 로그인하세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '학번 또는 관리자 ID',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: idController,
                    enabled: !loading,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => passwordFocus.requestFocus(),
                    onChanged: (_) {
                      if (idError != null || loginError != null) {
                        setState(() {
                          idError = null;
                          loginError = null;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: '학번 입력',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      errorText: idError,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '비밀번호',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    focusNode: passwordFocus,
                    enabled: !loading,
                    obscureText: hidePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => login(),
                    onChanged: (_) {
                      if (passwordError != null || loginError != null) {
                        setState(() {
                          passwordError = null;
                          loginError = null;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: '비밀번호 입력',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      errorText: passwordError,
                      suffixIcon: IconButton(
                        tooltip: hidePassword ? '비밀번호 보기' : '비밀번호 숨기기',
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() => hidePassword = !hidePassword);
                        },
                      ),
                    ),
                  ),
                  if (loginError != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              loginError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: loading ? null : login,
                      child: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              '로그인',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Text(
                              '테스트 계정 (누르면 자동 입력)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          ListTile(
                            dense: true,
                            enabled: !loading,
                            leading: const Icon(Icons.person_outline),
                            title: const Text('학생 · 학번 2026001'),
                            subtitle: const Text('비밀번호 1234'),
                            onTap: () => fillAccount('2026001', '1234'),
                          ),
                          ListTile(
                            dense: true,
                            enabled: !loading,
                            leading:
                                const Icon(Icons.admin_panel_settings_outlined),
                            title: const Text('관리자 · ID admin'),
                            subtitle: const Text('비밀번호 admin123'),
                            onTap: () => fillAccount('admin', 'admin123'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}