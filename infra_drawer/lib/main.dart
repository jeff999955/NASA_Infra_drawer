import 'package:flutter/material.dart';
import 'dart:async';

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
    var algorithm = FruchtermanReingoldAlgorithm();

    

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
  int _counter = 1;
  void _updateGraph() {
    setState(() {
      String postfix = _counter == 1
          ? '-st'
          : _counter == 2
              ? '-nd'
              : _counter == 3
                  ? '-rd'
                  : '-th';
      // ignore: avoid_print
      print("Added $_counter$postfix node.");
      widget.graph.addNode(Node.Id('$_counter$postfix node'));
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _updateGraph,
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
          // TODO: check if paint can be null
          // paint: widget?.paint,
          animated: animated,
          builder: (Node node) => createNode(node.key?.value),
        ),
      ),
    );
  }

  Widget createNode(String? str) {
    String title = str?.toString() ?? "Unknown Switch";
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
