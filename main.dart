import 'package:flutter/material.dart';

// Point d'entrée de l'application
void main() => runApp(const CalculatriceApp());

class CalculatriceApp extends StatelessWidget {
  const CalculatriceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculatrice',
      home: CalculatricePage(),
    );
  }
}

class CalculatricePage extends StatefulWidget {
  const CalculatricePage({super.key});

  @override
  State<CalculatricePage> createState() => _CalculatricePageState();
}

class _CalculatricePageState extends State<CalculatricePage> {
  // Opérateurs gérés par la calculatrice.
  // NOTE : le bouton % effectue un MODULO (reste de la division),
  // avec la même priorité que × et ÷. Exemple : 10 % 3 = 1
  static const String _operators = '+-×÷%';

  // Opération en cours (affichée en petit sous le résultat). Ex : "12+3×4"
  String _expression = '';

  // Résultat affiché en grand (mis à jour en temps réel)
  String _result = '0';

  // Vrai juste après avoir appuyé sur "="
  bool _justEvaluated = false;

  // GESTION DES BOUTONS

  // Point d'entrée : appelée à chaque appui sur un bouton
  void _onPressed(String label) {
    setState(() {
      if (label == 'C') {
        _clear();
      } else if (label == '=') {
        _calculate();
      } else if (_operators.contains(label)) {
        _addOperator(label);
      } else if (label == '.') {
        _addDecimal();
      } else {
        _addDigit(label);
      }
    });
  }

  // Bouton C : remet tout à zéro
  void _clear() {
    _expression = '';
    _result = '0';
    _justEvaluated = false;
  }

  // Chiffres 0 à 9 : ajoutés au fur et à mesure dans l'affichage
  void _addDigit(String digit) {
    // Après un "=", un nouveau chiffre démarre un nouveau calcul
    if (_justEvaluated) {
      _expression = '';
      _justEvaluated = false;
    }
    // Évite les zéros inutiles au début d'un nombre (ex : 05)
    if (_currentNumber() == '0') {
      _expression = _expression.substring(0, _expression.length - 1) + digit;
    } else {
      _expression += digit;
    }
    _updateLiveResult();
  }

  // Bouton . : écrit un nombre décimal (un seul point par nombre)
  void _addDecimal() {
    if (_justEvaluated) {
      _expression = '';
      _justEvaluated = false;
    }
    final number = _currentNumber();
    if (number.contains('.')) return; // déjà un point dans ce nombre
    _expression += number.isEmpty ? '0.' : '.';
    _updateLiveResult();
  }

  // Opérateurs + - × ÷ % : pris en compte pour le calcul
  void _addOperator(String op) {
    if (_result == 'Erreur') return; // rien à continuer après une erreur

    // Après un "=", on continue le calcul à partir du résultat
    if (_justEvaluated) {
      _expression = _result;
      _justEvaluated = false;
    }

    if (_expression.isEmpty) {
      // Début de saisie : "-" sert de signe négatif, sinon on part de 0
      _expression = op == '-' ? '-' : '0$op';
      return;
    }
    if (_expression == '-') return;

    // Si le dernier caractère est déjà un opérateur, on le remplace
    if (_operators.contains(_expression[_expression.length - 1])) {
      _expression = _expression.substring(0, _expression.length - 1) + op;
    } else {
      _expression += op;
    }
  }

  // Bouton = : affiche le résultat final
  void _calculate() {
    if (_expression.isEmpty || _expression == '-' || _justEvaluated) return;
    final value = _evaluate(_withoutTrailingOperator(_expression));
    // Division ou modulo par zéro => "Erreur"
    _result = value == null ? 'Erreur' : _format(value);
    _justEvaluated = true;
  }

  // OUTILS DE CALCUL

  // Retourne le nombre en cours de saisie (à la fin de l'expression)
  String _currentNumber() {
    var i = _expression.length;
    while (i > 0 && '0123456789.'.contains(_expression[i - 1])) {
      i--;
    }
    return _expression.substring(i);
  }

  // Retire un opérateur placé à la fin (ex : "12+" devient "12")
  String _withoutTrailingOperator(String expr) {
    if (expr.isNotEmpty && _operators.contains(expr[expr.length - 1])) {
      return expr.substring(0, expr.length - 1);
    }
    return expr;
  }

  // Résultat en temps réel : recalculé à chaque saisie
  void _updateLiveResult() {
    if (_expression.isEmpty) {
      _result = '0';
      return;
    }
    final value = _evaluate(_withoutTrailingOperator(_expression));
    if (value != null) _result = _format(value);
  }

  // Évalue une expression comme "12+3×4" en respectant les priorités :
  // × ÷ % d'abord, puis + -. Retourne null si le calcul est impossible.
  double? _evaluate(String expr) {
    // 1) Découpage en nombres et opérateurs
    final tokens = <String>[];
    var current = '';
    for (var i = 0; i < expr.length; i++) {
      final ch = expr[i];
      // Un opérateur sépare deux nombres (sauf le "-" du début = signe négatif)
      if (_operators.contains(ch) && i != 0) {
        if (current.isEmpty) return null;
        tokens.add(current);
        tokens.add(ch);
        current = '';
      } else {
        current += ch;
      }
    }
    if (current.isEmpty) return null;
    tokens.add(current);

    // 2) Séparation en liste de valeurs et liste d'opérateurs
    final values = <double>[];
    final ops = <String>[];
    for (var i = 0; i < tokens.length; i++) {
      if (i.isEven) {
        final v = double.tryParse(tokens[i]);
        if (v == null) return null;
        values.add(v);
      } else {
        ops.add(tokens[i]);
      }
    }

    // 3) Première passe : × ÷ % (prioritaires)
    var i = 0;
    while (i < ops.length) {
      final op = ops[i];
      if (op == '×' || op == '÷' || op == '%') {
        final a = values[i];
        final b = values[i + 1];
        double r;
        if (op == '×') {
          r = a * b;
        } else {
          if (b == 0) return null; // division / modulo par zéro
          r = op == '÷' ? a / b : a % b;
        }
        values[i] = r;
        values.removeAt(i + 1);
        ops.removeAt(i);
      } else {
        i++;
      }
    }

    // 4) Deuxième passe : + et -
    var total = values[0];
    for (var j = 0; j < ops.length; j++) {
      total = ops[j] == '+' ? total + values[j + 1] : total - values[j + 1];
    }
    return total;
  }

  // Affiche 5 au lieu de 5.0 et supprime les décimales inutiles
  String _format(double value) {
    if (value == value.truncateToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    var s = value.toStringAsFixed(8);
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return s == '-0' ? '0' : s;
  }

  // INTERFACE

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // fond noir
      body: SafeArea(
        child: Column(
          children: [
            // Zone d'affichage (1/3 de l'écran) et clavier (2/3) :
            // les proportions s'adaptent à toutes les tailles d'écran
            Expanded(flex: 2, child: _buildDisplay()),
            Expanded(flex: 5, child: _buildKeypad()),
          ],
        ),
      ),
    );
  }

  // Zone d'affichage : résultat en grand, opération en plus petit en dessous
  Widget _buildDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // FittedBox réduit le texte s'il est trop long pour l'écran
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _result,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _justEvaluated ? '$_expression =' : _expression,
              style: const TextStyle(color: Colors.white60, fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

  // Clavier : 5 lignes de boutons
  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildRow([_button('C', flex: 2), _button('%'), _button('÷')]),
          _buildRow([_button('7'), _button('8'), _button('9'), _button('×')]),
          _buildRow([_button('4'), _button('5'), _button('6'), _button('-')]),
          _buildRow([_button('1'), _button('2'), _button('3'), _button('+')]),
          _buildRow([_button('0', flex: 2), _button('.'), _button('=')]),
        ],
      ),
    );
  }

  // Une ligne de boutons (toutes les lignes ont la même hauteur)
  Widget _buildRow(List<Widget> buttons) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons,
      ),
    );
  }

  // Un bouton : gris foncé avec texte blanc, sauf "=" qui est orange
  Widget _button(String label, {int flex = 1}) {
    final isEquals = label == '=';
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ElevatedButton(
          onPressed: () => _onPressed(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: isEquals ? Colors.orange : const Color(0xFF333333),
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(label, style: const TextStyle(fontSize: 28)),
        ),
      ),
    );
  }
}
