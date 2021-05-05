import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextSelectionControls controls;

  _MyHomePageState() {
    controls = MyTextSelectionControls(setImage);
  }

  setImage(ImageProvider newImg) {
    this.setState(() {
      img = newImg;
    });
  }

  ImageProvider img;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.blue[100],
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(fillColor: Colors.amber[200]),
              selectionControls: controls,
            ),
          ),
          if (img != null) Image(image: img),
          SizedBox(height: 10, width: 10),
          Container(
            height: 40,
            color: Colors.red[300],
          )
        ],
      ),
    );
  }
}

class MyTextSelectionControls extends CupertinoTextSelectionControls {
// https://api.flutter.dev/flutter/widgets/TextSelectionControls/handlePaste.html
// https://flutter.dev/docs/development/platform-integration/platform-channels#step-4-add-an-ios-platform-specific-implementation
  static final channelName = 'clipboard/image';
  final methodChannel = MethodChannel(channelName);

  Function(ImageProvider) callback;
  MyTextSelectionControls(this.callback);

  @override
  Future<void> handlePaste(TextSelectionDelegate delegate) async {
    await getClipboardImage();

    final TextEditingValue value =
        delegate.textEditingValue; // Snapshot the input before using `await`.
    final ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);

    if (data != null) {
      delegate.textEditingValue = TextEditingValue(
        text: value.selection.textBefore(value.text) +
            data.text +
            value.selection.textAfter(value.text),
        selection: TextSelection.collapsed(
            offset: value.selection.start + data.text.length),
      );
    }
    delegate.bringIntoView(delegate.textEditingValue.selection.extent);
    delegate.hideToolbar();
  }

  getClipboardImage() async {
    try {
      final result = await methodChannel.invokeMethod('getClipboardImage');
      ImageProvider prov = Image.memory(result).image;
      callback(prov);
    } on PlatformException catch (e) {
      print("error in getting clipboard image");
      print(e);
    }
  }
}
