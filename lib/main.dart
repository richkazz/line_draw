import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Draw Line',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const LineDrawer());
  }
}

class LineDrawer extends StatefulWidget {
  const LineDrawer({super.key});

  @override
  State<LineDrawer> createState() => _LineDrawerState();
}

class _LineDrawerState extends State<LineDrawer> {
  late Path _path; // The path to draw lines.
  late Paint _paint; // The paint for drawing.
  late ValueNotifier<(double, double)>
      notifier; // Notifies when the path is updated.
  late List<(Path, Paint)> _actions; // Stores the drawing _actions.
  late CurvedShapePainter _painter;
  Color startColor = Colors.red; // The initial color of the line.
  @override
  void initState() {
    _actions = [];
    notifier = ValueNotifier<(double, double)>((0, 0));
    _painter = CurvedShapePainter(_actions, repaint: notifier);
    _path = Path();
    _paint = Paint()
      ..color = startColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;
    _actions.add((_path, _paint));
    super.initState();
  }

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onVerticalDragStart: _onDragStart,
      onHorizontalDragStart: _onDragStart,
      onVerticalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onVerticalDragEnd: _onDragEnd,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Draw',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: _appBarActionList,
        ),
        body: CustomPaint(
          size: screenSize,
          painter: _painter,
        ),
      ),
    );
  }

  List<Widget> get _appBarActionList {
    return [
      IconButton(
          onPressed: () => _onColorChange(Colors.black),
          icon: const Icon(
            Icons.circle,
            color: Colors.black,
          )),
      IconButton(
          onPressed: () => _onColorChange(Colors.blue),
          icon: const Icon(
            Icons.circle,
            color: Colors.blue,
          )),
      IconButton(
          onPressed: () => _onColorChange(Colors.red),
          icon: const Icon(
            Icons.circle,
            color: Colors.red,
          )),
      IconButton(
          onPressed: () => _onColorChange(Colors.green),
          icon: const Icon(
            Icons.circle,
            color: Colors.green,
          )),
      IconButton(
          onPressed: () => _onColorChange(Colors.orange),
          icon: const Icon(
            Icons.circle,
            color: Colors.orange,
          )),
      IconButton(
          onPressed: () => _onColorChange(Colors.yellow),
          icon: const Icon(
            Icons.circle,
            color: Colors.yellow,
          )),
      IconButton(onPressed: _undo, icon: const Icon(Icons.undo_outlined)),
    ];
  }

  void _onColorChange(Color color) {
    _paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;
    _path = Path();
    _actions.add((_path, _paint));
  }

  void _undo() {
    setState(() {
      // Check if there are fewer than 2 _actions (only one path).
      if (_actions.length <= 2) {
        // Clear the current path.
        _path = Path();
        // Clear the _actions list and add a new empty path with _paint settings.
        _actions = [];
        _actions.add((_path, _paint));
        // Reinitialize the painter with the updated _actions list.
        _painter = CurvedShapePainter(_actions, repaint: notifier);
        return; // Exit the function early.
      }

      // Remove the most recent path (line) from the _actions list.
      _path = _actions[_actions.length - 1].$1;
      _actions.removeAt(_actions.length - 2);
    });
  }

  void _onDragEnd(details) {
    _path = Path();
    _actions.add((_path, _paint));
  }

  void _onDragStart(details) {
    final x = details.globalPosition.dx;
    final y = details.globalPosition.dy;
    _path.moveTo(x, y);
  }

  void _onDragUpdate(details) {
    final x = details.globalPosition.dx;
    final y = details.globalPosition.dy;
    notifier.value = (x, y);
    _path.lineTo(x, y);
  }
}

class CurvedShapePainter extends CustomPainter {
  final List<(Path, Paint)> _actions;

  CurvedShapePainter(
    this._actions, {
    super.repaint,
  });
  @override
  void paint(Canvas canvas, Size size) {
    for (var (path, paint) in _actions) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
