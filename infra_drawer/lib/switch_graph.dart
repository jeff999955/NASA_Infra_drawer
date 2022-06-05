import 'package:graphview/GraphView.dart';

class SwitchGraph extends Graph {
  final List<Node> _nodes = [];
  final List<Edge> _edges = [];


  void clearGraph() {
    _nodes.clear();
    _edges.clear();
    print('After cleaning');
    print('_nodes: $_nodes');
    print('_edges: $_edges');
  }
}
