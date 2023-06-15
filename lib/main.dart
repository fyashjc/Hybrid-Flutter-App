import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({Key? key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hybrid Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: MyHomePage(
        title: 'Hybrid Flutter App',
        camera: camera,
      ),
      routes: {
        CameraScreen.routeName: (context) => CameraScreen(camera: camera),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.camera});

  final String title;
  final CameraDescription camera;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late PageController _pageController;
  int _currentPageIndex = 0;
  late CameraController _cameraController;
  late Future<void> _initializeCameraControllerFuture;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.low,
    );
    _initializeCameraControllerFuture = _cameraController.initialize();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  void _toggleFlashlight() async {
    try {
      await _initializeCameraControllerFuture;
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      await _cameraController
          .setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    } catch (e) {
      print('Error toggling flashlight: $e');
    }
  }

  void _openCameraScreen() {
    Navigator.pushNamed(context, CameraScreen.routeName);
  }

  void _vibratePhone() {
    HapticFeedback.vibrate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          _buildFlashlightPage(),
          _buildCameraPage(),
          _buildVibrationPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        onTap: (int index) {
          setState(() {
            _currentPageIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.flashlight_on),
            label: 'Flashlight',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_enhance),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.vibration),
            label: 'Vibrations',
          ),
        ],
      ),
    );
  }

  Widget _buildFlashlightPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _toggleFlashlight,
            child:
                Text(_isFlashOn ? 'Turn Off Flashlight' : 'Turn On Flashlight'),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _openCameraScreen,
            child: Text('Open Camera'),
          ),
        ],
      ),
    );
  }

  Widget _buildVibrationPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _vibratePhone,
            child: Text('Vibrate Phone'),
          ),
        ],
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  static const routeName = '/camera';

  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeCameraControllerFuture;

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeCameraControllerFuture = _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera')),
      body: FutureBuilder<void>(
        future: _initializeCameraControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_cameraController);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
