class Node {
  final bool redirects;

  Node({this.redirects: false});

  String toString() {
    return redirects.toString();
  }
}
