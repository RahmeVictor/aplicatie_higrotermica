import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'calcul.dart';
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
  final listKey = GlobalKey<AnimatedListState>();

  final List<Strat> straturi = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Form(
          key: formKey,
          child: ListView(children: [
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
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                  onPressed: () => addItem(Strat(0, 0, 0)),
                  icon: const Icon(Icons.add),
                  label: const Text('Strat'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
            )
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
        child: Wrap(alignment: WrapAlignment.spaceAround, children: [
          SizedBox(
            width: 100,
            child: ModelTextField(
                title: 'Grosimea d',
                suffixText: 'cm',
                keyboardType: TextInputType.number,
                onSaved: (value) => strat.d = double.parse(value!)),
          ),
          SizedBox(
            width: 230,
            child: ModelTextField(
                title: 'Factorul rezistenței la aburi μ',
                keyboardType: TextInputType.number,
                onSaved: (value) => strat.miu = double.parse(value!)),
          ),
          SizedBox(
            width: 300,
            child: ModelTextField(
                title: 'Coeficientul de conductivitate termică λ',
                suffixText: '%',
                keyboardType: TextInputType.number,
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

class ModelTextField extends StatelessWidget {
  const ModelTextField({
    Key? key,
    this.title,
    this.initialValue,
    this.keyboardType,
    this.inputFormatters,
    this.onSaved,
    this.maxLines = 1,
    this.suffixText,
    this.padding = const EdgeInsets.only(left: 10),
  }) : super(key: key);

  final String? title;
  final String? initialValue;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String?)? onSaved;
  final int? maxLines;
  final String? suffixText;
  final EdgeInsetsGeometry padding;

  String? notEmptyValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Acest câmp este obligatoriu";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          textAlign: TextAlign.end,
          validator: notEmptyValidator,
          onSaved: onSaved,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: title,
            border: InputBorder.none,
            suffixText: suffixText,
            floatingLabelAlignment: FloatingLabelAlignment.center,
          )),
    );
  }
}
