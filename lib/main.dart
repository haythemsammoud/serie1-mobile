import 'package:flutter/material.dart';

// Point d'entrée de l'application
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Série 01 - Exercice 1',
      home: Exercice1Page(),
    );
  }
}

// Page principale : regroupe les exercices 1.1 à 1.4
class Exercice1Page extends StatelessWidget {
  const Exercice1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Série 01 - Exercice 1'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Titre('Ex 1.1 - Méthode 1 : Align'),
          Ex11Align(),
          Titre('Ex 1.1 - Méthode 2 : Column'),
          Ex11Column(),
          Titre('Ex 1.2 - Compteur de caractères (counterText)'),
          Ex12Compteur(),
          Titre('Ex 1.3 - Somme de deux nombres (controllers + parse)'),
          Ex13Somme(),
          Titre('Ex 1.4 - Décoration d\'un TextField'),
          Ex14Decoration(),
        ],
      ),
    );
  }
}

// Petit widget pour afficher les titres de section
class Titre extends StatelessWidget {
  final String texte;
  const Titre(this.texte, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        texte,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Exercice 1.1 - Méthode 1 : centrer avec le widget Align

class Ex11Align extends StatelessWidget {
  const Ex11Align({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100.0,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2.0),
      ),
      // Align place son enfant au centre du Container
      child: const Align(
        alignment: Alignment.center,
        child: TextField(
          decoration: InputDecoration(hintText: 'Enter text here'),
        ),
      ),
    );
  }
}

// Exercice 1.1 - Méthode 2 : centrer avec Column

class Ex11Column extends StatelessWidget {
  const Ex11Column({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100.0, // hauteur fixe nécessaire pour voir le centrage vertical
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 2.0),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center, // axe vertical
        crossAxisAlignment: CrossAxisAlignment.center, // axe horizontal
        children: [
          TextField(decoration: InputDecoration(hintText: 'Enter some text')),
        ],
      ),
    );
  }
}

// Exercice 1.2 - Compteur de caractères avec counterText

class Ex12Compteur extends StatefulWidget {
  const Ex12Compteur({super.key});

  @override
  State<Ex12Compteur> createState() => _Ex12CompteurState();
}

class _Ex12CompteurState extends State<Ex12Compteur> {
  static const int _maxLength = 20; // longueur maximale autorisée
  int _currentLength = 0; // longueur actuelle du texte saisi

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: _maxLength,
      decoration: InputDecoration(
        hintText: 'Tapez votre texte',
        border: const OutlineInputBorder(),
        // counterText remplace le compteur par défaut
        counterText: '$_currentLength/$_maxLength',
      ),
      // À chaque modification, on met à jour la longueur
      onChanged: (value) {
        setState(() {
          _currentLength = value.length;
        });
      },
    );
  }
}

// Exercice 1.3 - Somme de deux nombres avec TextEditingController
class Ex13Somme extends StatefulWidget {
  const Ex13Somme({super.key});

  @override
  State<Ex13Somme> createState() => _Ex13SommeState();
}

class _Ex13SommeState extends State<Ex13Somme> {
  // 1- Un contrôleur par champ de texte
  final _firstNumberController = TextEditingController();
  final _secondNumberController = TextEditingController();
  String _resultat = '';

  void _calculerSomme() {
    // 3- Conversion en nombres (tryParse évite le plantage si saisie invalide)
    final int? firstNumber = int.tryParse(_firstNumberController.text);
    final int? secondNumber = int.tryParse(_secondNumberController.text);

    setState(() {
      if (firstNumber == null || secondNumber == null) {
        _resultat = 'Veuillez saisir deux nombres valides';
      } else {
        final int sum = firstNumber + secondNumber;
        // 4- Affichage du résultat
        _resultat = 'The sum is : $sum';
      }
    });
  }

  @override
  void dispose() {
    // Libérer la mémoire des contrôleurs
    _firstNumberController.dispose();
    _secondNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 2- Association des contrôleurs aux TextField
        TextField(
          controller: _firstNumberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Premier nombre',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _secondNumberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Deuxième nombre',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _calculerSomme,
          child: const Text('Calculer la somme'),
        ),
        const SizedBox(height: 12),
        Text(_resultat, style: const TextStyle(fontSize: 18)),
      ],
    );
  }
}

// Exercice 1.4 - Décoration d'un TextField (InputDecoration)

class Ex14Decoration extends StatelessWidget {
  const Ex14Decoration({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Enter your email', // texte d'aide
        labelText: 'Email', // libellé
        prefixIcon: const Icon(Icons.email), // icône à gauche
        filled: true, // fond coloré
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0), // bordure arrondie
        ),
      ),
    );
  }
}
