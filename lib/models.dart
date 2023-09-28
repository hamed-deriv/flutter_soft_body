import 'package:flutter/material.dart';

abstract class MassPoint {
  Offset position;
  Offset velocity;
  Offset force;

  final double mass;

  MassPoint(this.mass, {Offset? initialPosition})
      : position = initialPosition ?? Offset.zero,
        velocity = Offset.zero,
        force = Offset.zero;

  void updatePosition({required Size size, required Duration elapsedTime}) {
    velocity = force * (elapsedTime.inMilliseconds / 1000000) / mass;
    position += velocity;
  }

  set setPosition(Offset newPosition) {
    position = newPosition;
  }
}

/// A Goo ball.
class GooBall extends MassPoint {
  GooBall(super.mass, {super.initialPosition});
}

abstract class EdgeBase {
  MassPoint get node1;

  MassPoint get node2;
}

/// A connection between two nodes/particle, joint, which has elastic behaviour.
class ElasticEdge implements EdgeBase {
  double ks = 35;
  double kd = 700;

  @override
  final MassPoint node1;

  @override
  final MassPoint node2;

  final double length = 55;

  ElasticEdge({required this.node1, required this.node2});

  void update(Duration elapsedTime, Size size) {
    double x1 = node1.position.dx;
    double x2 = node2.position.dx;
    double y1 = node1.position.dy;
    double y2 = node2.position.dy;

    // calculate sqr(distance)
    double distanceSquared = (node1.position - node2.position).distance;

    if (distanceSquared > 0) {
      // get velocities of start & end points
      double vx12 = node1.velocity.dx - node2.velocity.dx;
      double vy12 = node1.velocity.dy - node2.velocity.dy;

      // calculate force value
      double f = (distanceSquared - length) * ks +
          (vx12 * (x1 - x2) + vy12 * (y1 - y2)) * kd / distanceSquared;

      // force vector
      double fx = ((x1 - x2) / distanceSquared) * f;
      double fy = ((y1 - y2) / distanceSquared) * f;

      node1.force -= Offset(fx, fy);
      node2.force += Offset(fx, fy);
    }
  }
}
