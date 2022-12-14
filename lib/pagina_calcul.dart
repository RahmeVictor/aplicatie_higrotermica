import 'package:flutter/material.dart';

import 'calcul.dart';

class PaginaCalcul extends StatefulWidget {
  const PaginaCalcul({Key? key, required this.straturi}) : super(key: key);

  final List<Strat> straturi;

  @override
  State<PaginaCalcul> createState() => _PaginaCalculState();
}

class _PaginaCalculState extends State<PaginaCalcul> {
  final dateInterior = DateIntExt(20, 80);
  final dateExterior = DateIntExt(-10, 85);

  late final List<double> presiuniPartiale;

  @override
  void initState() {
    super.initState();
    presiuniPartiale = calculeazaPresiuniPartiale();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rezultat 🎉')),
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(children: [
            Wrap(runSpacing: 10, children: [
              Text('Straturi introduse (${widget.straturi.length}) :'),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.straturi.length,
                  itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(top: 5, left: 10),
                        child: widget.straturi[index].toStringIndex(index + 1),
                      )),
              const Divider(),
              Text('Presiunea interioara: ${dateInterior.p.round()} Pa\n'
                  'Presiunea exterioara: ${dateExterior.p.round()} Pa'),
              const Divider(),
              const Text('Nus cum se numesc astea ceva Rv-uri'),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.straturi.length,
                  itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(top: 5, left: 10),
                        child: widget.straturi[index].rvToString(index + 1),
                      )),
              const Divider(),
              const Text('Presiuni parțiale a vaporilor:'),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: presiuniPartiale.length,
                  itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(top: 5, left: 10),
                      child: simplifiedText([
                        'P',
                        Subscript('${index + 1}'),
                        ' = ${presiuniPartiale[index].round()} Pa'
                      ]))),
              const Divider(),
              const Text('Nus ce mai sunt si astea nu mai vreau'),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.straturi.length,
                  itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(top: 5, left: 10),
                      child: simplifiedText([
                        'R',
                        Subscript('${index + 1}'),
                        ' = ${widget.straturi[index].r.toStringAsFixed(2)} m',
                        Superscript('2 '),
                        'K/W'
                      ]))),
            ]),
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
}
