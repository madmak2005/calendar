class StatYear {
  int rok;
  List<StatMonth> _months;

  List<StatMonth> get months => _months;

  set months(List<StatMonth> value) {
    total = 0.0;
    for (var element in _months) {
      total = total + element.razem;
    }
    _months = value;
  }

  double total;
  StatYear.name(this.rok, this._months, this.total) {
    total = 0.0;
    for (var element in _months) {
      total = total + element.razem;
    }
  }
}

class StatMonth {
  int miesiac = 0;
  double razem = 0;
}
