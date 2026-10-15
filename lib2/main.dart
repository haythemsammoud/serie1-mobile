import 'package:flutter/material.dart';

// Point d'entrée de l'application
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // cache la bande "DEBUG"
      title: 'Exercice 2',
      home: BienvenuePage(),
    );
  }
}

class BienvenuePage extends StatelessWidget {
  const BienvenuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Couleur de fond de la fenêtre (propriété background)
      backgroundColor: Colors.red,
      // SafeArea évite que le bouton passe sous la barre de navigation du téléphone
      body: SafeArea(
        child: Column(
          children: [
            // Expanded + Center : le texte occupe tout l'espace disponible
            // et se place au centre de l'écran
            const Expanded(
              child: Center(
                child: Text(
                  'Bienvenue',
                  style: TextStyle(
                    fontSize: 40, // taille du texte
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // couleur du texte
                  ),
                ),
              ),
            ),
            // Le bouton est placé en bas de l'écran, sur toute la largeur
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Rien ne se produit au clic (comme demandé dans l'énoncé)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade700,
                  ),
                  child: const Text('Valider', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
