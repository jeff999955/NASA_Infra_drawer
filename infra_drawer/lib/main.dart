import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:graphview/GraphView.dart';

void main() {
  runApp(const DrawerApp());
}

class DrawerApp extends StatelessWidget {
  const DrawerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var json = {
      "edge": [
        {"from": "A", "to": "B"},
        {"from": "B", "to": "D"},
        {"from": "B", "to": "D"}
      ]
    };

    Graph graph = Graph()..isTree = true;
    var edges = json['edge'] as List<Map<String, String>>;
    for (var edge in edges) {
      graph.addEdge(Node.Id(edge['from']), Node.Id(edge['to']),
          paint: Paint()..color = Colors.red);
    }

    var builder = SugiyamaConfiguration()
      ..nodeSeparation = (15)
      ..levelSeparation = (100)
      ..orientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM;
    var algorithm = SugiyamaAlgorithm(builder);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(graph, algorithm, title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  final Graph graph;
  final Algorithm algorithm;
  final Paint? paint;

  final String title;

  const HomePage(this.graph, this.algorithm,
      {Key? key, this.title = "Test", this.paint})
      : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const bool animated = true;
  Map<String, dynamic>? name_mapping;
  void _updateGraph(http.Response response, http.Response name_response) {
    setState(() {
      if (response.statusCode == 200 && name_response.statusCode == 200) {
        // ignore: avoid_print
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        print(json);
        var oldNodes = [...widget.graph.nodes];
        for (var node in oldNodes) {
          widget.graph.removeNode(node);
        }

        var edges = json['edges']; // TODO: type casting would fail
        for (var edge in edges) {
          widget.graph.addEdge(Node.Id(edge['from']), Node.Id(edge['to']),
              paint: Paint()..color = Colors.black);
        }
        print(widget.graph.nodes);
        name_mapping = jsonDecode(name_response.body) as Map<String, dynamic>;
      } else {
        // ignore: avoid_print
        print('error: ${response.statusCode}');
      }
    });
    return;
  }

  Future<http.Response> getGraph() async {
    return await http.get(Uri.parse('http://127.0.0.1:5920/json'));
  }

  Future<http.Response> getNameMapping() async {
    return await http.get(Uri.parse('http://127.0.0.1:5920/name'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              var responde = await getGraph();
              var namae_reponde = await getNameMapping();
              _updateGraph(responde, namae_reponde);
            },
          ),
        ],
      ),
      body: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(100),
        minScale: 0.01,
        maxScale: 16,
        child: GraphView(
          graph: widget.graph,
          algorithm: widget.algorithm,
          animated: animated,
          builder: (Node node) => createNode(node.key?.value),
        ),
      ),
    );
  }

  Widget createNode(String str) {
    String title = name_mapping?[str] ?? "Unknown Switch";
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.lightBlue, spreadRadius: 1),
        ],
      ),
      child: Center(child: Text(title)),
    );
  }
}
