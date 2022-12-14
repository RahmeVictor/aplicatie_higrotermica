import 'dart:math' show e, pow;

DateIntExt dateIntrare = DateIntExt(0, 0);

class Strat {
  Strat(this.d, this.miu, this.lambda) : rv = 50 * pow(10, 8) * miu * d;

  /// Grosimea straturilor în metri
  double d;

  /// μ factorul rezistenței la aburi
  double miu;

  /// Coeficientul de conductivitate termică
  double lambda;

  /// Rv1...Rvn
  double rv;
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

List<double> calculeaza(List<Strat> straturi) {
  final dateIntrare = DateIntExt(20, 80);
  final dateExterior = DateIntExt(-10, 85);

  // // Citire straturi
  // straturi.add(Strat(5, 1.1, 0.04));
  // straturi.add(Strat(25, 6.1, 0.05));
  // straturi.add(Strat(10, 30, 0.04));

  final rv = straturi.fold(0.0, (total, strat) => total + strat.rv);
  final List<double> presiuniPartiale = [];
  for (var i = 0; i < straturi.length; i++) {
    double rvStraturi =
        straturi.take(i + 1).fold(0.0, (total, strat) => total + strat.rv);
    // TODO intreaba pe Stef daca (rvStraturi / rv) sau fara paranteza
    presiuniPartiale.add(
        dateIntrare.p - (rvStraturi / rv) * (dateIntrare.p - dateExterior.p));
  }
  return presiuniPartiale;
}
