import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'ajutoare_calcul.dart';
import 'grafic.dart';

class PaginaCalcul extends StatefulWidget {
  const PaginaCalcul({Key? key, required this.straturi}) : super(key: key);

  final List<Strat> straturi;

  @override
  State<PaginaCalcul> createState() => _PaginaCalculState();
}

class _PaginaCalculState extends State<PaginaCalcul> {
  final dateInterior = DateIntExt(20, 80);
  final dateExterior = DateIntExt(-10, 85);

  late final double r;
  late final double rt;
  late final double tetaSI;
  late final double tetaSE;
  late final List<double> temperaturi;
  late final List<double> presiuniVapori;
  late final Map<double, double> presiuniDeSaturatie;

  @override
  void initState() {
    super.initState();
    presiuniVapori = calculeazaPresiuniPartiale();
    r = calculeazaR();
    rt = calculeazaRT();
    temperaturi = calculeazaTemperaturi();
    presiuniDeSaturatie = calculeazaPresiuniDeSaturatie();
  }

  @override
  Widget build(BuildContext context) {
    final presiuniSaturatieGraf = presiuniDeSaturatie.entries
        .map((e) => e.value)
        .toList()
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.roundToDouble()))
        .toList();

    final presiuniVaporiComplet = [
      dateInterior.p,
      ...presiuniVapori,
      dateExterior.p
    ];

    final presiuniVaporiGraf = presiuniVaporiComplet
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.roundToDouble()))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Rezultat 🎉')),
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(children: [
            LineChartSample1(
                data1: presiuniSaturatieGraf, data2: presiuniVaporiGraf),
            const Divider(),
            const SizedBox(height: 30),
            Wrap(runSpacing: 10, children: [
              Text('Straturi introduse (${widget.straturi.length}) :'),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.straturi.length,
                  itemBuilder: (context, index) =>
                      widget.straturi[index].toStringIndex(index + 1)),
              const Divider(),
              Text('Presiunea interioara: ${dateInterior.p.round()} Pa\n'
                  'Presiunea exterioara: ${dateExterior.p.round()} Pa'),
              const Divider(),
              const Text('Nus cum se numesc astea ceva Rv-uri'),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.straturi.length,
                  itemBuilder: (context, index) =>
                      widget.straturi[index].rvToString(index + 1)),
              const Divider(),
              const Text('Presiunea parțială a vaporilor:'),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: presiuniVapori.length,
                  itemBuilder: (context, index) => simplifiedText([
                        'P',
                        Subscript('${index + 1}'),
                        ' = ${presiuniVapori[index].round()} Pa'
                      ])),
              const Divider(),
              const Text('Nus ce mai sunt si astea nu mai vreau'),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.straturi.length,
                  itemBuilder: (context, index) => simplifiedText([
                        'R',
                        Subscript('${index + 1}'),
                        ' = ${widget.straturi[index].r.toStringAsFixed(2)} m',
                        Superscript('2 '),
                        'K/W'
                      ])),
              simplifiedText([
                'R',
                Subscript('T'),
                ' = ${calculeazaRT().toStringAsFixed(3)}',
                ' = m',
                Superscript('2 '),
                'K/W'
              ]),
              const Divider(),
              const Text('Temperaturi:'),
              ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    simplifiedText([
                      'θ',
                      Subscript('si'),
                      ' = ${tetaSI.toStringAsFixed(1)} °C'
                    ]),
                    simplifiedText([
                      'θ',
                      Subscript('se'),
                      ' = ${tetaSE.toStringAsFixed(1)} °C'
                    ])
                  ]),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: temperaturi.length,
                  itemBuilder: (context, index) => simplifiedText([
                        'θ',
                        Subscript('${index + 1}'),
                        ' = ${temperaturi[index].toStringAsFixed(1)} °C'
                      ])),
              const Divider(),
              const Text('Presiuni de saturație:'),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: presiuniDeSaturatie.keys.length,
                  itemBuilder: (context, index) => simplifiedText([
                        'P',
                        Subscript('s'),
                        Superscript(presiuniDeSaturatie.keys
                            .elementAt(index)
                            .toStringAsFixed(1)),
                        ' = ${presiuniDeSaturatie.values.elementAt(index).round()} Pa'
                      ], const EdgeInsets.all(10))),
            ]),
            const SizedBox(height: 20),
          ])),
    );
  }

  List<double> calculeazaPresiuniPartiale() {
    final rv = widget.straturi.fold(0.0, (total, strat) => total + strat.rv);
    final List<double> presiuniPartiale = [];
    for (var i = 0; i < widget.straturi.length; i++) {
      double rvStraturi = widget.straturi
          .take(i + 1)
          .fold(0.0, (total, strat) => total + strat.rv);
      // TODO întreabă pe Stef daca (rvStraturi / rv) sau fara paranteza
      presiuniPartiale.add(dateInterior.p -
          (rvStraturi / rv) * (dateInterior.p - dateExterior.p));
    }
    return presiuniPartiale;
  }

  double calculeazaRT() => rsi + r + rse;

  double calculeazaR() =>
      widget.straturi.fold(0.0, (total, strat) => total + strat.r);

  List<double> calculeazaTemperaturi() {
    final deltaTemperatura = dateInterior.teta - dateExterior.teta;
    tetaSI = dateInterior.teta - (rsi / rt) * deltaTemperatura;
    tetaSE = dateInterior.teta - ((rsi + r) / rt) * deltaTemperatura;

    final List<double> temperaturi = [];
    for (var i = 0; i < widget.straturi.length - 1; i++) {
      double tetaStraturi = widget.straturi
          .take(i + 1)
          .fold(0.0, (total, strat) => total + strat.r);
      temperaturi.add(
          dateInterior.teta - ((rsi + tetaStraturi) / rt) * deltaTemperatura);
    }
    return temperaturi;
  }

  /// <Temperatura, Presiune de saturație>
  Map<double, double> calculeazaPresiuniDeSaturatie() => {
        tetaSI: calcularePresiune(tetaSI),
        for (var temperatura in temperaturi)
          temperatura: calcularePresiune(temperatura),
        tetaSE: calcularePresiune(tetaSE),
      };
}
