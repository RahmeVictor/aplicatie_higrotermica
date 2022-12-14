import 'dart:math' show e, pow;

import 'package:flutter/cupertino.dart';

abstract class SubSuperScript {
  SubSuperScript(this.text);

  final String text;

  Offset get offset;

  WidgetSpan get span => WidgetSpan(
          child: Transform.translate(
        offset: offset,
        child: Text(text, textScaleFactor: 0.7),
      ));
}

class Subscript extends SubSuperScript {
  Subscript(super.text);

  @override
  Offset get offset => const Offset(1, 4);
}

class Superscript extends SubSuperScript {
  Superscript(super.text);

  @override
  Offset get offset => const Offset(1, -10);
}

RichText simplifiedText(List<dynamic> text) {
  final List<InlineSpan> children = [];
  for (final element in text) {
    if (element is String) {
      children.add(TextSpan(text: element));
    } else if (element is SubSuperScript) {
      children.add(element.span);
    }
  }
  return RichText(text: TextSpan(children: children));
}

class Strat {
  Strat(this.d, this.miu, this.lambda);

  /// Grosimea straturilor în metri
  double d;

  /// μ factorul rezistenței la aburi
  double miu;

  /// λ Coeficientul de conductivitate termică
  double lambda;

  /// Rv1...Rvn
  double get rv => 50 * pow(10, 8) * rvSimplu;

  /// Pentru afișare simplificată
  double get rvSimplu => miu * d;

  double get r => d / lambda;

  RichText toStringIndex(int index) => simplifiedText([
        'd',
        Subscript('$index'),
        ' = $d m, μ',
        Subscript('$index'),
        ' = $miu, λ',
        Subscript('$index'),
        ' = $lambda W/m'
      ]);

  RichText rvToString(int index) => simplifiedText([
        'Rv',
        Subscript('$index'),
        ' = 50 ⋅ 10',
        Superscript('8'),
        ' ⋅ ${rvSimplu.toStringAsFixed(3)}'
      ]);
}

class DateIntExt {
  // TODO întreabă pe Stef daca teta >= 0
  DateIntExt(this.teta, this.ro)
      : ps = teta >= 0
            ? 610.5 * pow(e, (17.269 * teta) / (237.3 + teta))
            : 610.5 * pow(e, (21.875 * teta) / (265.5 + teta)) {
    // TODO întreabă pe Stef daca trebuie -teta la < 0
    p = (ps * ro) / 100.0;
  }

  /// Temperatura θ °C
  final double teta;

  /// Umiditatea ϕ %
  final double ro;

  double ps;

  /// Pi si Pe
  late double p;
}
