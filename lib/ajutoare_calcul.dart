import 'dart:math' show e, pow;

import 'package:flutter/material.dart';

const rsi = 0.125;
const rse = 0.042;

final dateInterior = DateIntExt(0, 0);
final dateExterior = DateIntExt(0, 0);

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

Widget simplifiedText(List<dynamic> text,
    [padding = const EdgeInsets.only(top: 10, left: 10)]) {
  final List<InlineSpan> children = [];
  for (final element in text) {
    if (element is String) {
      children.add(TextSpan(text: element));
    } else if (element is SubSuperScript) {
      children.add(element.span);
    }
  }
  return Padding(
    padding: padding,
    child: SelectableText.rich(TextSpan(children: children)),
  );
}

calcularePresiune(double temperatura) => temperatura >= 0
    ? 610.5 * pow(e, (17.269 * temperatura) / (237.3 + temperatura))
    : 610.5 * pow(e, (21.875 * temperatura) / (265.5 + temperatura));

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

  Widget toStringIndex(int index) => simplifiedText([
        'd',
        Subscript('$index'),
        ' = $d m, μ',
        Subscript('$index'),
        ' = $miu, λ',
        Subscript('$index'),
        ' = $lambda W/m'
      ]);

  Widget rvToString(int index) => simplifiedText([
        'Rv',
        Subscript('$index'),
        ' = 50 ⋅ 10',
        Superscript('8'),
        ' ⋅ ${rvSimplu.toStringAsFixed(3)}'
      ]);
}

class DateIntExt {
  DateIntExt(this.temperatura, this.umiditate);

  /// Temperatura θ °C
  double temperatura;

  /// Umiditatea ϕ %
  double umiditate;

  double get ps => calcularePresiune(temperatura);

  /// Pi si Pe, presiunea partiala a vaporilor
  double get p => (ps * umiditate) / 100.0;
}
