import 'package:graphview/GraphView.dart';

class SwitchGraph extends Graph {
  final List<Node> _nodes = [];
  final List<Edge> _edges = [];
  List<GraphObserver> graphObserver = [];

  List<Node> get nodes => _nodes; //  List<Node> nodes = _nodes;
  List<Edge> get edges => _edges;

  var isTree = false;

  int nodeCount() => _nodes.length;
  void clearGraph() {
    _nodes.clear();
    _edges.clear();
    print('After cleaning');
    print('_nodes: $_nodes');
    print('_edges: $_edges');
  }
}
