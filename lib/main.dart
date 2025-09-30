import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WebView Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  final ImagePicker _imagePicker = ImagePicker();

  // 复制文件到外部公共目录（WebView更容易访问）
  Future<String?> _copyToPublicDir(File sourceFile) async {
    try {
      // 获取应用外部存储目录（公共可访问）
      Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir == null) return null;

      // 创建目标文件路径
      String fileName = sourceFile.path.split('/').last;
      File targetFile = File('${externalDir.path}/$fileName');

      // 复制文件
      await sourceFile.copy(targetFile.path);
      print('文件已复制到公共目录：${targetFile.path}');
      return targetFile.path;
    } catch (e) {
      print('复制文件失败：$e');
      return null;
    }
  }

  // 调用相机拍照
  Future<File?> _takePhoto() async {
    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80, // 调整照片质量
    );

    if (photo != null) {
      return File(photo.path);
    }
    return null;
  }

  Future<List<String>> _openFilePicker(FileSelectorParams params) async {
    // 检查是否是图片选择
    if (params.acceptTypes.contains('image/*')) {
      // 显示选择对话框：从相册选择或拍照
      final result = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
          ],
        ),
      );

      File? selectedFile;

      if (result == 'gallery') {
        // 从相册选择
        FilePickerResult? res = await FilePicker.platform.pickFiles();
        if (res != null && res.files.isNotEmpty) {
          selectedFile = File(res.files.single.path!);
        }
      } else if (result == 'camera') {
        // 拍照
        selectedFile = await _takePhoto();
      }

      if (selectedFile != null) {
        // 检查文件是否存在
        if (!await selectedFile.exists()) {
          print("文件不存在");
          return [];
        }

        // 复制到公共目录
        String? publicPath = await _copyToPublicDir(selectedFile);
        if (publicPath != null) {
          // 生成 file:// 格式的URI
          String fileUri = 'file://$publicPath';
          return [fileUri];
        } else {
          // 复制失败时直接返回原路径
          return ['file://${selectedFile.path}'];
        }
      }
    }
    // 视频处理保持不变
    else if (params.acceptTypes.contains('video/*')) {
      FilePickerResult? res = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );
      if (res != null && res.files.isNotEmpty) {
        File sourceFile = File(res.files.single.path!);

        if (!await sourceFile.exists()) {
          print("文件不存在");
          return [];
        }

        String? publicPath = await _copyToPublicDir(sourceFile);
        if (publicPath != null) {
          return ['file://$publicPath'];
        } else {
          return ['file://${sourceFile.path}'];
        }
      }
    }
    return [];
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      // 请求必要的权限：存储、照片和相机
      await [
        Permission.storage,
        Permission.photos,
        Permission.camera, // 新增相机权限
      ].request();
    }
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() => _isLoading = true),
          onPageFinished: (url) => setState(() => _isLoading = false),
        ),
      );

    // 配置Android WebView允许文件访问
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      final AndroidWebViewController androidController =
          _controller.platform as AndroidWebViewController;
      androidController.setOnShowFileSelector(_openFilePicker);
    }

    _controller.loadRequest(Uri.parse('http://192.168.9.47:9000/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebView Demo')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
