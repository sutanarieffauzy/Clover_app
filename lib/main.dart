import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const CloverApp());
}

class CloverApp extends StatelessWidget {
  const CloverApp({super.key});

  static const Color bgDark = Color(0xFF14191D);
  static const Color surfaceDark = Color(0xFF1E252B);
  static const Color primaryMint = Color(0xFF38EF7D);
  static const Color myBubbleBg = Color(0xFF1B4D3E);
  static const Color amberSoft = Color(0xFFE6A23C);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clover',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgDark,
        primaryColor: primaryMint,
        appBarTheme: const AppBarTheme(
          backgroundColor: surfaceDark,
          elevation: 0,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        colorScheme: const ColorScheme.dark(
          primary: primaryMint,
          surface: surfaceDark,
        ),
      ),
      home: const AuthCheckScreen(),
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('is_logged_in') ?? false;
    setState(() {
      _isLoggedIn = loggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: CloverApp.primaryMint)),
      );
    }
    return _isLoggedIn ? const MainHomeScreen() : const LoginScreen();
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isRegisterMode = false;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  Future<void> _submitAuth() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty || (_isRegisterMode && name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua kolom!')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    if (_isRegisterMode) {
      await prefs.setString('user_email', email);
      await prefs.setString('user_pass', pass);
      await prefs.setString('user_name', name);
      await prefs.setString('user_bio', 'Pengguna Baru Clover');
      await prefs.setBool('is_logged_in', true);
    } else {
      final savedEmail = prefs.getString('user_email');
      final savedPass = prefs.getString('user_pass');

      if (savedEmail != null && email == savedEmail && pass == savedPass) {
        await prefs.setBool('is_logged_in', true);
      } else if (savedEmail == null) {
        await prefs.setString('user_email', email);
        await prefs.setString('user_pass', pass);
        await prefs.setString('user_name', email.split('@')[0]);
        await prefs.setString('user_bio', 'Member Clover');
        await prefs.setBool('is_logged_in', true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email atau kata sandi salah!')),
          );
        }
        return;
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainHomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble, size: 70, color: CloverApp.primaryMint),
                  const SizedBox(height: 12),
                  Text(
                    _isRegisterMode ? 'Buat Akun Clover' : 'Selamat Datang',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isRegisterMode ? 'Daftar untuk mulai berkirim pesan' : 'Masuk ke akun Clover kamu',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 30),
                  if (_isRegisterMode) ...[
                    TextField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: const Icon(Icons.person, color: CloverApp.primaryMint),
                        filled: true,
                        fillColor: CloverApp.surfaceDark,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email / Username',
                      prefixIcon: const Icon(Icons.email, color: CloverApp.primaryMint),
                      filled: true,
                      fillColor: CloverApp.surfaceDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passCtrl,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi',
                      prefixIcon: const Icon(Icons.lock, color: CloverApp.primaryMint),
                      filled: true,
                      fillColor: CloverApp.surfaceDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CloverApp.primaryMint,
                        foregroundColor: CloverApp.bgDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _submitAuth,
                      child: Text(
                        _isRegisterMode ? 'Daftar Sekarang' : 'Masuk',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isRegisterMode = !_isRegisterMode;
                      });
                    },
                    child: Text(
                      _isRegisterMode ? 'Sudah punya akun? Masuk' : 'Belum punya akun? Daftar di sini',
                      style: const TextStyle(color: CloverApp.primaryMint),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ChatListTab(),
    NearbyTab(),
    RequestsTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: CloverApp.primaryMint,
        unselectedItemColor: Colors.white38,
        backgroundColor: CloverApp.surfaceDark,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Nearby'),
          BottomNavigationBarItem(icon: Icon(Icons.person_add_outlined), activeIcon: Icon(Icons.person_add), label: 'Permintaan'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class ChatListTab extends StatefulWidget {
  const ChatListTab({super.key});

  @override
  State<ChatListTab> createState() => _ChatListTabState();
}

class _ChatListTabState extends State<ChatListTab> {
  List<String> _chatUsers = [];
  List<String> _filteredUsers = [];
  Map<String, String> _lastMessages = {};
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChatList();
  }

  Future<void> _loadChatList() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsers = prefs.getStringList('active_chat_users') ?? ['Alex (Developer)'];

    Map<String, String> tempLastMsg = {};
    for (String user in savedUsers) {
      final msgs = prefs.getStringList('messages_$user') ?? [];
      if (msgs.isNotEmpty) {
        final last = msgs.last;
        if (last.startsWith('📷 [VIEW_ONCE_IMG]:')) {
          tempLastMsg[user] = '📷 Foto 1x Lihat';
        } else if (last.startsWith('📍 [LOCATION]:')) {
          tempLastMsg[user] = '📍 Berbagi Lokasi';
        } else {
          tempLastMsg[user] = last;
        }
      } else {
        tempLastMsg[user] = 'Belum ada pesan';
      }
    }

    setState(() {
      _chatUsers = savedUsers;
      _lastMessages = tempLastMsg;
      _filterList(_searchCtrl.text);
    });
  }

  void _filterList(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_chatUsers);
      } else {
        _filteredUsers = _chatUsers
            .where((u) => u.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clover Messages'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _filterList,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari obrolan...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: CloverApp.primaryMint),
                filled: true,
                fillColor: CloverApp.surfaceDark,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadChatList,
              child: _filteredUsers.isEmpty
                  ? const Center(
                      child: Text('Tidak ada obrolan ditemukan.', style: TextStyle(color: Colors.white38)),
                    )
                  : ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final userName = _filteredUsers[index];
                        final lastMsg = _lastMessages[userName] ?? 'Ketuk untuk membuka obrolan';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: CloverApp.primaryMint.withValues(alpha: 0.2),
                            child: Text(
                              userName[0].toUpperCase(),
                              style: const TextStyle(color: CloverApp.primaryMint, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(userName, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                          subtitle: Text(
                            lastMsg,
                            style: const TextStyle(color: Colors.white38, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChatDetailScreen(userName: userName)),
                            );
                            _loadChatList();
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  final String userName;
  const ChatDetailScreen({super.key, required this.userName});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<String> _savedMessages = [];
  bool _isBlocked = false;

  @override
  void initState() {
    super.initState();
    _loadChatData();
  }

  Future<void> _loadChatData() async {
    final prefs = await SharedPreferences.getInstance();
    final blockedList = prefs.getStringList('blocked_users') ?? [];

    setState(() {
      _isBlocked = blockedList.contains(widget.userName);
      _savedMessages = prefs.getStringList('messages_${widget.userName}') ?? [
        'Halo, selamat datang di Clover!'
      ];
    });
  }

  Future<void> _sendMessage({String? customText}) async {
    if (_isBlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda memblokir pengguna ini. Buka blokir untuk mengirim pesan.')),
      );
      return;
    }

    final text = customText ?? _msgController.text.trim();
    if (text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    _savedMessages.add(text);
    await prefs.setStringList('messages_${widget.userName}', _savedMessages);

    List<String> activeUsers = prefs.getStringList('active_chat_users') ?? ['Alex (Developer)'];
    if (!activeUsers.contains(widget.userName)) {
      activeUsers.add(widget.userName);
      await prefs.setStringList('active_chat_users', activeUsers);
    }

    setState(() {
      if (customText == null) _msgController.clear();
    });
  }

  Future<void> _pickAndSendImage() async {
    if (_isBlocked) return;
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _sendMessage(customText: '📷 [VIEW_ONCE_IMG]:${image.path}');
    }
  }

  Future<void> _shareLocation() async {
    if (_isBlocked) return;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        await _sendMessage(customText: '📍 [LOCATION]:${pos.latitude},${pos.longitude}');
      } else {
        await _sendMessage(customText: '📍 [LOCATION]:-6.2088,106.8456');
      }
    } catch (_) {
      await _sendMessage(customText: '📍 [LOCATION]:-6.2088,106.8456');
    }
  }

  Future<void> _openLocationUrl(String coords) async {
    final url = Uri.parse('https://maps.google.com/?q=$coords');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _deleteMessage(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedMessages.removeAt(index);
    });
    await prefs.setStringList('messages_${widget.userName}', _savedMessages);
  }

  void _openViewOnceImage(String imagePath, int index) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('Foto 1x Lihat', style: TextStyle(color: CloverApp.amberSoft, fontWeight: FontWeight.bold)),
            ),
            Image.file(File(imagePath), fit: BoxFit.contain),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _deleteMessage(index);
              },
              child: const Text('Tutup & Hapus', style: TextStyle(color: Colors.redAccent)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfileDetailScreen(
                  userName: widget.userName,
                  bio: 'Pengguna Clover',
                  status: 'Online',
                  distance: 'Di dekatmu',
                ),
              ),
            );
            _loadChatData();
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: CloverApp.primaryMint.withValues(alpha: 0.2),
                child: Text(widget.userName[0], style: const TextStyle(color: CloverApp.primaryMint, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(widget.userName, style: const TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileDetailScreen(
                    userName: widget.userName,
                    bio: 'Pengguna Clover',
                    status: 'Online',
                    distance: 'Di dekatmu',
                  ),
                ),
              );
              _loadChatData();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isBlocked)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.redAccent.withValues(alpha: 0.2),
                child: const Text(
                  'Pengguna ini telah Anda blokir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                itemCount: _savedMessages.length,
                itemBuilder: (context, index) {
                  final msgText = _savedMessages[index];
                  final isViewOnceImg = msgText.startsWith('📷 [VIEW_ONCE_IMG]:');
                  final isLocation = msgText.startsWith('📍 [LOCATION]:');

                  final imgPath = isViewOnceImg ? msgText.replaceFirst('📷 [VIEW_ONCE_IMG]:', '') : '';
                  final coords = isLocation ? msgText.replaceFirst('📍 [LOCATION]:', '') : '';

                  return Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        if (isViewOnceImg) {
                          _openViewOnceImage(imgPath, index);
                        } else if (isLocation) {
                          _openLocationUrl(coords);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isViewOnceImg
                              ? CloverApp.amberSoft.withValues(alpha: 0.15)
                              : isLocation
                                  ? Colors.blueAccent.withValues(alpha: 0.2)
                                  : CloverApp.myBubbleBg,
                          borderRadius: BorderRadius.circular(14),
                          border: isViewOnceImg
                              ? Border.all(color: CloverApp.amberSoft)
                              : isLocation
                                  ? Border.all(color: Colors.blueAccent)
                                  : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isViewOnceImg) ...[
                              const Icon(Icons.filter_1_rounded, size: 18, color: CloverApp.amberSoft),
                              const SizedBox(width: 6),
                              const Text(
                                'Foto 1x Lihat (Ketuk untuk buka)',
                                style: TextStyle(color: CloverApp.amberSoft, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ] else if (isLocation) ...[
                              const Icon(Icons.location_on, size: 18, color: Colors.blueAccent),
                              const SizedBox(width: 6),
                              Text(
                                'Lokasi Terbagikan ($coords)',
                                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ] else
                              Text(
                                msgText,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              color: CloverApp.surfaceDark,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_1_rounded, color: CloverApp.amberSoft),
                    onPressed: _pickAndSendImage,
                    tooltip: 'Foto 1x Lihat',
                  ),
                  IconButton(
                    icon: const Icon(Icons.location_on, color: Colors.blueAccent),
                    onPressed: _shareLocation,
                    tooltip: 'Bagikan Lokasi Saya',
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: CloverApp.bgDark,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _msgController,
                        enabled: !_isBlocked,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: _isBlocked ? 'Pengguna diblokir...' : 'Ketik pesan...',
                          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: CloverApp.primaryMint),
                    onPressed: _isBlocked ? null : () => _sendMessage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NearbyTab extends StatefulWidget {
  const NearbyTab({super.key});

  @override
  State<NearbyTab> createState() => _NearbyTabState();
}

class _NearbyTabState extends State<NearbyTab> {
  final List<Map<String, String>> _allNearbyUsers = const [
    {'name': 'Rian Utama', 'distance': '350 m dari kamu', 'status': 'Online', 'bio': 'Suka ngopi dan koding'},
    {'name': 'Dina Melati', 'distance': '800 m dari kamu', 'status': 'Aktif 5j lalu', 'bio': 'Kulineran & Traveling'},
    {'name': 'Budi Santoso', 'distance': '1.2 km dari kamu', 'status': 'Online', 'bio': 'Gamer & Mobile Legends'},
    {'name': 'Siti Rahma', 'distance': '2.1 km dari kamu', 'status': 'Online', 'bio': 'Desainer Grafis & Ilustrator'},
  ];

  List<Map<String, String>> _filteredUsers = [];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredUsers = List.from(_allNearbyUsers);
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_allNearbyUsers);
      } else {
        _filteredUsers = _allNearbyUsers
            .where((u) => u['name']!.toLowerCase().contains(query.toLowerCase()) ||
                          u['bio']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _sendFriendRequest(String targetName, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> pendingRequests = prefs.getStringList('pending_requests_$targetName') ?? [];

    if (!pendingRequests.contains('Sutan Arief Fauzy')) {
      pendingRequests.add('Sutan Arief Fauzy');
      await prefs.setStringList('pending_requests_$targetName', pendingRequests);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permintaan pertemanan dikirim ke $targetName!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teman Sekitar')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _filterUsers,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari teman sekitar...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: CloverApp.primaryMint),
                filled: true,
                fillColor: CloverApp.surfaceDark,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return Card(
                  color: CloverApp.surfaceDark,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: CloverApp.primaryMint.withValues(alpha: 0.2),
                      child: Text(user['name']![0], style: const TextStyle(color: CloverApp.primaryMint, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(user['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('${user['distance']} • ${user['bio']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfileDetailScreen(
                            userName: user['name']!,
                            bio: user['bio']!,
                            status: user['status']!,
                            distance: user['distance']!,
                          ),
                        ),
                      );
                    },
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CloverApp.myBubbleBg,
                        foregroundColor: CloverApp.primaryMint,
                      ),
                      onPressed: () => _sendFriendRequest(user['name']!, context),
                      child: const Text('Tambah'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RequestsTab extends StatefulWidget {
  const RequestsTab({super.key});

  @override
  State<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab> {
  List<String> _requests = ['Lia Permata', 'Doni Setiawan'];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final currentName = prefs.getString('user_name') ?? 'Sutan Arief Fauzy';
    final savedReqs = prefs.getStringList('pending_requests_$currentName');

    if (savedReqs != null) {
      setState(() {
        _requests = savedReqs;
      });
    }
  }

  Future<void> _acceptRequest(String name) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> activeUsers = prefs.getStringList('active_chat_users') ?? ['Alex (Developer)'];

    if (!activeUsers.contains(name)) {
      activeUsers.add(name);
      await prefs.setStringList('active_chat_users', activeUsers);
    }

    _removeRequest(name);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name sekarang menjadi teman kamu!')),
      );
    }
  }

  Future<void> _rejectRequest(String name) async {
    _removeRequest(name);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permintaan pertemanan dari $name ditolak.')),
      );
    }
  }

  Future<void> _removeRequest(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final currentName = prefs.getString('user_name') ?? 'Sutan Arief Fauzy';

    setState(() {
      _requests.remove(name);
    });
    await prefs.setStringList('pending_requests_$currentName', _requests);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permintaan Pertemanan')),
      body: _requests.isEmpty
          ? const Center(
              child: Text('Tidak ada permintaan pertemanan.', style: TextStyle(color: Colors.white38)),
            )
          : ListView.builder(
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final reqName = _requests[index];
                return Card(
                  color: CloverApp.surfaceDark,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: CloverApp.primaryMint.withValues(alpha: 0.2),
                      child: Text(reqName[0], style: const TextStyle(color: CloverApp.primaryMint, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(reqName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Ingin menambahkan kamu sebagai teman', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: CloverApp.primaryMint),
                          onPressed: () => _acceptRequest(reqName),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.redAccent),
                          onPressed: () => _rejectRequest(reqName),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class UserProfileDetailScreen extends StatefulWidget {
  final String userName;
  final String bio;
  final String status;
  final String distance;

  const UserProfileDetailScreen({
    super.key,
    required this.userName,
    required this.bio,
    required this.status,
    required this.distance,
  });

  @override
  State<UserProfileDetailScreen> createState() => _UserProfileDetailScreenState();
}

class _UserProfileDetailScreenState extends State<UserProfileDetailScreen> {
  bool _isBlocked = false;
  bool _isFriend = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final blockedList = prefs.getStringList('blocked_users') ?? [];
    final activeUsers = prefs.getStringList('active_chat_users') ?? ['Alex (Developer)'];

    setState(() {
      _isBlocked = blockedList.contains(widget.userName);
      _isFriend = activeUsers.contains(widget.userName);
    });
  }

  Future<void> _toggleBlock() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> blockedList = prefs.getStringList('blocked_users') ?? [];

    if (_isBlocked) {
      blockedList.remove(widget.userName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.userName} telah dibuka dari pemblokiran.')),
      );
    } else {
      blockedList.add(widget.userName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.userName} telah diblokir.')),
      );
    }

    await prefs.setStringList('blocked_users', blockedList);
    setState(() {
      _isBlocked = !_isBlocked;
    });
  }

  Future<void> _removeFriend() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> activeUsers = prefs.getStringList('active_chat_users') ?? ['Alex (Developer)'];

    if (activeUsers.contains(widget.userName)) {
      activeUsers.remove(widget.userName);
      await prefs.setStringList('active_chat_users', activeUsers);
      setState(() {
        _isFriend = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.userName} telah dihapus dari pertemanan.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: CloverApp.primaryMint.withValues(alpha: 0.2),
                  child: Text(
                    widget.userName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 40, color: CloverApp.primaryMint, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.userName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: CloverApp.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.status} • ${widget.distance}',
                    style: const TextStyle(color: CloverApp.primaryMint, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.bio,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CloverApp.primaryMint,
                      foregroundColor: CloverApp.bgDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      List<String> activeUsers = prefs.getStringList('active_chat_users') ?? ['Alex (Developer)'];
                      if (!activeUsers.contains(widget.userName)) {
                        activeUsers.add(widget.userName);
                        await prefs.setStringList('active_chat_users', activeUsers);
                      }

                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ChatDetailScreen(userName: widget.userName)),
                        );
                      }
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Kirim Pesan', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                if (_isFriend)
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orangeAccent,
                        side: const BorderSide(color: Colors.orangeAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _removeFriend,
                      icon: const Icon(Icons.person_remove),
                      label: const Text('Hapus Pertemanan'),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isBlocked ? Colors.grey[800] : Colors.redAccent.withValues(alpha: 0.2),
                      foregroundColor: _isBlocked ? Colors.white : Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _toggleBlock,
                    icon: Icon(_isBlocked ? Icons.check_circle_outline : Icons.block),
                    label: Text(_isBlocked ? 'Buka Pemblokiran' : 'Blokir Pengguna'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _name = 'Sutan Arief Fauzy';
  String _bio = 'Driver BangKurir | Flutter Dev';
  String _email = '';
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? 'Sutan Arief Fauzy';
      _bio = prefs.getString('user_bio') ?? 'Driver BangKurir | Flutter Dev';
      _email = prefs.getString('user_email') ?? 'sutan@clover.app';
      _profileImagePath = prefs.getString('user_profile_img');
    });
  }

  Future<void> _pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile_img', image.path);
      setState(() {
        _profileImagePath = image.path;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _editProfileDialog() async {
    final nameCtrl = TextEditingController(text: _name);
    final bioCtrl = TextEditingController(text: _bio);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CloverApp.surfaceDark,
        title: const Text('Edit Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bioCtrl,
              decoration: const InputDecoration(labelText: 'Bio / Status'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: CloverApp.primaryMint, foregroundColor: CloverApp.bgDark),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_name', nameCtrl.text);
              await prefs.setString('user_bio', bioCtrl.text);
              setState(() {
                _name = nameCtrl.text;
                _bio = bioCtrl.text;
              });
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: CloverApp.primaryMint,
                      backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null,
                      child: _profileImagePath == null
                          ? const Icon(Icons.person, size: 60, color: CloverApp.bgDark)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: CloverApp.primaryMint,
                        child: const Icon(Icons.camera_alt, size: 16, color: CloverApp.bgDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(_name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(_email, style: const TextStyle(color: CloverApp.primaryMint, fontSize: 13)),
              const SizedBox(height: 6),
              Text(_bio, style: const TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CloverApp.surfaceDark,
                      foregroundColor: CloverApp.primaryMint,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: _editProfileDialog,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Profil'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Keluar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
