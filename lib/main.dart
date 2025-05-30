import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper().startBtcPriceLoop();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<Map<String, dynamic>> _btcHistory = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBtcHistory();
  }

  Future<void> _loadBtcHistory() async {
    final history = await DatabaseHelper().getExamples();
    setState(() {
      _btcHistory = history.where((e) => e['name'] == 'BTC').toList();
      _loading = false;
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            const Text('BTC Price History:'),
            _loading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Timestamp')),
                          DataColumn(label: Text('Price (USD)')),
                        ],
                        rows: _btcHistory.reversed
                            .map(
                              (entry) => DataRow(
                                cells: [
                                  DataCell(Text(entry['timestamp'] ?? '-')),
                                  DataCell(Text(entry['price']?.toString() ?? '-')),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
            ElevatedButton(
              onPressed: _loadBtcHistory,
              child: const Text('Refresh BTC History'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
