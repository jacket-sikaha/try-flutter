// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:developer' as dev;
// import 'package:webview_flutter_android/webview_flutter_android.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter WebView 权限示例',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const PermissionWrapper(), // 先进行权限检查
//     );
//   }
// }

// // 权限检查包装器
// class PermissionWrapper extends StatefulWidget {
//   const PermissionWrapper({super.key});

//   @override
//   State<PermissionWrapper> createState() => _PermissionWrapperState();
// }

// class _PermissionWrapperState extends State<PermissionWrapper> {
//   bool _hasPermissions = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkPermissions();
//   }

//   // 检查并请求所需权限
//   Future<void> _checkPermissions() async {
//     // 检查相机和存储权限
//     final cameraStatus = await Permission.camera.status;
//     final storageStatus = await Permission.storage.status;

//     // 如果已有权限
//     if (cameraStatus.isGranted && storageStatus.isGranted) {
//       setState(() => _hasPermissions = true);
//       return;
//     }

//     // 请求权限
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.camera,
//       Permission.storage,
//     ].request();

//     // 检查请求结果
//     setState(() {
//       _hasPermissions =
//           statuses[Permission.camera]!.isGranted &&
//           statuses[Permission.storage]!.isGranted;
//     });
//   }

//   // 打开应用设置页面
//   void _openAppSettings() async {
//     await openAppSettings();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_hasPermissions) {
//       return const WebViewPage(); // 权限通过，显示WebView
//     } else {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text('需要相机和文件访问权限', style: TextStyle(fontSize: 18)),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _checkPermissions,
//                 child: const Text('重新请求权限'),
//               ),
//               const SizedBox(height: 10),
//               TextButton(
//                 onPressed: _openAppSettings,
//                 child: const Text('前往设置手动开启'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//   }
// }

// // WebView页面（保持之前的实现）
// class WebViewPage extends StatefulWidget {
//   const WebViewPage({super.key});

//   @override
//   State<WebViewPage> createState() => _WebViewPageState();
// }

// class _WebViewPageState extends State<WebViewPage> {
//   late final WebViewController _controller;
//   final ImagePicker _imagePicker = ImagePicker();
//   Future<List<String>> _androidFilePicker(FileSelectorParams params) async {
//     dev.log(params.toString());
//     //手机上有权限限制，一般我们只支持图片文件选择
//     if (params.acceptTypes.any((type) => type == 'image/*')) {
//       //这里可以显示 拍照、相册 选择弹窗，图片选择完成后，返回图片的 uri 地址
//     }
//     return [];
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initWebView();
//   }

//   void _initWebView() {
//     _controller = WebViewController();
//     if (WebViewPlatform.instance is AndroidWebViewPlatform) {
//       dev.log('AndroidWebViewPlatform');
//       final AndroidWebViewController androidController =
//           _controller.platform as AndroidWebViewController;
//       //处理文件选择，只有 AndroidWebViewController 才暴露出 setOnShowFileSelector 方法，这里才能监听文件选择
//       androidController.setOnShowFileSelector(_androidFilePicker);
//     }

//     _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
//     _controller.loadRequest(Uri.parse('http://192.168.9.47:9000/'));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('WebView 上传')),
//       body: WebViewWidget(
//         controller: _controller,

//         // 4.7.0版本中onFileSelected的返回值为FileSelectionResult?
//       ),
//     );
//   }
// }
