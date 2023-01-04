import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ajutoare_calcul.dart';
import 'pagina_calcul.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Aplicație Higrotermică',
        theme:
            ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
        home: const MyHomePage(title: 'Aplicație Higrotermică'));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final formKey = GlobalKey<FormState>();
  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  final List<Strat> straturi = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.title),
            systemOverlayStyle: const SystemUiOverlayStyle(
                systemNavigationBarColor: Colors.black)),
        body: Form(
          key: formKey,
          child: ListView(children: [
            Wrap(alignment: WrapAlignment.center, children: [
              DateIntExtCard(dateIntExt: dateInterior, title: 'Interior'),
              DateIntExtCard(dateIntExt: dateExterior, title: 'Exterior')
            ]),
            AnimatedList(
                key: listKey,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                initialItemCount: straturi.length,
                itemBuilder: (context, index, animation) {
                  return SlideTransition(
                      position: animation.drive(Tween(
                          begin: const Offset(0, -1), end: const Offset(0, 0))),
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: CardStrat(
                              strat: straturi[index],
                              deleteCallback: removeItem)));
                }),
            Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton.icon(
                    onPressed: () => addItem(Strat(0, 0, 0)),
                    icon: const Icon(Icons.add),
                    label: const Text('Strat'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green))),
            Row(children: [
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() {
                          // for(final strat in straturi){
                          //   removeItem(strat);
                          // }
                          dateInterior.temperatura = 20;
                          dateInterior.umiditate = 80;
                          dateExterior.temperatura = -10;
                          dateExterior.umiditate = 85;
                          formKey.currentState?.reset();

                          listKey = GlobalKey<AnimatedListState>();
                          straturi.clear();
                          addItem(Strat(0.05, 1.1, 0.04));
                          addItem(Strat(0.25, 6.1, 0.05));
                          addItem(Strat(0.10, 30, 0.04));
                        }),
                        icon: const Icon(Icons.format_list_numbered_sharp),
                        label: const Text('Exemplu'),
                      ))),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton.icon(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState?.save();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PaginaCalcul(straturi: straturi)));
                        }
                      },
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculează')),
                ),
              ),
            ]),
          ]),
        ));
  }

  void addItem(Strat strat) {
    straturi.add(strat);
    listKey.currentState?.insertItem(straturi.length - 1,
        duration: const Duration(milliseconds: 200));
  }

  void removeItem(Strat strat) {
    final removedIndex = straturi.indexOf(strat);
    listKey.currentState?.removeItem(
        duration: const Duration(milliseconds: 200),
        removedIndex, (context, animation) {
      animation.addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          // After the remove animation finished playing we can delete the item
          straturi.remove(strat);
        }
      });
      return SlideTransition(
          position: animation.drive(
              Tween(begin: const Offset(-1, 0), end: const Offset(0, 0))),
          child: CardStrat(
              strat: straturi[removedIndex], deleteCallback: removeItem));
    });
  }
}

class CardStrat extends StatelessWidget {
  const CardStrat({Key? key, required this.strat, required this.deleteCallback})
      : super(key: key);

  final Strat strat;
  final void Function(Strat strat) deleteCallback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      child: Card(
        child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceEvenly,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 200,
                child: ModelTextField(
                    title: 'Grosimea',
                    prefixText: 'd = ',
                    suffixText: 'cm',
                    initialValue:
                        strat.d != 0 ? (strat.d * 100).toString() : null,
                    inputFormatters: defaultFormatter,
                    onSaved: (value) => strat.d = double.parse(value!) / 100),
              ),
              SizedBox(
                width: 250,
                child: ModelTextField(
                    title: 'Factorul rezistenței la aburi',
                    prefixText: 'μ = ',
                    initialValue: strat.miu != 0 ? strat.miu.toString() : null,
                    inputFormatters: defaultFormatter,
                    onSaved: (value) => strat.miu = double.parse(value!)),
              ),
              SizedBox(
                width: 330,
                child: ModelTextField(
                    title: 'Coeficientul de conductivitate termică',
                    prefixText: 'λ = ',
                    suffixText: 'W/m',
                    initialValue:
                        strat.lambda != 0 ? strat.lambda.toString() : null,
                    inputFormatters: defaultFormatter,
                    onSaved: (value) => strat.lambda = double.parse(value!)),
              ),
              IconButton(
                  onPressed: () => deleteCallback(strat),
                  icon: const Icon(Icons.delete, color: Colors.red))
            ]),
      ),
    );
  }
}

/// Allows only 3 decimal digits and replaces ',' with '.'
final defaultFormatter = [
  FilteringTextInputFormatter.deny(',', replacementString: '.'),
  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
];

class ModelTextField extends StatelessWidget {
  const ModelTextField({
    Key? key,
    this.controller,
    this.title,
    this.initialValue,
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
    this.onSaved,
    this.suffixText,
    this.prefixText,
    this.padding = const EdgeInsets.all(10),
  }) : super(key: key);

  final TextEditingController? controller;
  final String? title;
  final String? initialValue;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String?)? onSaved;
  final String? suffixText;
  final String? prefixText;
  final EdgeInsetsGeometry padding;

  static String? notEmptyValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Acest câmp este obligatoriu';
    }
    return null;
  }

  static String? notZeroValidator(String? value) {
    final notEmptyError = notEmptyValidator(value);
    if (notEmptyError != null) return notEmptyError;
    if (value == null || double.parse(value) == 0) {
      return 'Nu introduce valori egale cu 0';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextFormField(
          controller: controller,
          initialValue: initialValue,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textAlign: TextAlign.start,
          validator: notZeroValidator,
          onSaved: onSaved,
          decoration: InputDecoration(
            labelText: title,
            //border: const OutlineInputBorder(),
            suffixText: suffixText,
            prefixText: prefixText,
            floatingLabelAlignment: FloatingLabelAlignment.center,
          )),
    );
  }
}

class DateIntExtCard extends StatelessWidget {
  const DateIntExtCard(
      {Key? key, required this.dateIntExt, required this.title})
      : super(key: key);

  final DateIntExt dateIntExt;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(children: [
      Text(title),
      IntrinsicWidth(
          child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
            SizedBox(
                width: 200,
                child: ModelTextField(
                    key: Key(dateIntExt.temperatura.toString()),
                    title: 'Temperatura',
                    prefixText: 'θ = ',
                    suffixText: '°C',
                    initialValue: dateIntExt.temperatura != 0
                        ? dateIntExt.temperatura.toString()
                        : null,
                    inputFormatters: defaultFormatter,
                    onSaved: (value) =>
                        dateIntExt.temperatura = double.parse(value!))),
            SizedBox(
                width: 200,
                child: ModelTextField(
                    key: Key(dateIntExt.umiditate.toString()),
                    title: 'Umiditatea',
                    prefixText: 'ϕ = ',
                    suffixText: '%',
                    initialValue: dateIntExt.umiditate != 0
                        ? dateIntExt.umiditate.toString()
                        : null,
                    inputFormatters: defaultFormatter,
                    onSaved: (value) =>
                        dateIntExt.umiditate = double.parse(value!))),
          ])),
    ]));
  }
}
