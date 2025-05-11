import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/services/room_service.dart';
import '../data/models/room.dart';
import '../data/providers/user_provider.dart';
import '../theme.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  Room? _room;
  String? _error;

  Future<void> _joinRoom() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.currentUser?.id;
      if (userId == null) {
        setState(() {
          _error = 'Bạn cần đăng nhập để tham gia phòng!';
          _isLoading = false;
        });
        return;
      }
      final room = await RoomService().joinRoom(_codeController.text.trim(), userId);
      setState(() {
        _room = room;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tham gia phòng Quiz')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _room != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Đã tham gia phòng thành công!'),
                      Text('Mã phòng: \\${_room!.code}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text('Chờ chủ phòng bắt đầu quiz...'),
                      // TODO: Chuyển sang màn hình chờ phòng
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_error != null) ...[
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: TextField(
                          controller: _codeController,
                          decoration: const InputDecoration(
                            labelText: 'Nhập mã phòng',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _joinRoom,
                        child: const Text('Tham gia phòng'),
                      ),
                    ],
                  ),
      ),
    );
  }
} 