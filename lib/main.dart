import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners(); // basically what the ChangeNotifier provides (changing a state by telling the listeners)
  }

  var fav = <WordPair>[];
  void toggleFav() {
    if (fav.contains(current)) {
      fav.remove(current);
    } else {
      fav.add(current);
    }
    notifyListeners();
  }

  void deleteFav(WordPair pair) {
    fav.remove(pair);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;  

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600, // this can be altered when we wanna make the UI responsive (by default flutter use pixels)
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home), 
                      label: Text('Home')
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite), 
                      label: Text('Favorites')
                    )
                  ], 
                  selectedIndex: selectedIndex, // choose the destination
                  onDestinationSelected: (value) { // this is to do the logic changing the selectedIndex
                    setState(() {
                      selectedIndex = value;
                    });
                  }
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                )
              )
            ],
          ),
        );
      }
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favs = appState.fav;
    var len = favs.length;

    if (favs.isEmpty) {
      return Center(
        child: Text("You don't have any favorites yet."),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text("You have $len favorites: "),
        ),  
        for (var pair in favs)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
            trailing: IconButton(
              onPressed: () {
                // Call delete function here, passing the pair or an identifier
                appState.deleteFav(pair);
              },
              icon: Icon(Icons.delete),
            ),
          ),
      ],
    );

    
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current; // make it independent or make sure that the line being extracted only accesses what it needs   

    IconData icon;
    if (appState.fav.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ 
            BigCard(pair: pair),
            SizedBox(height: 10,), // giving visible gaps
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFav();
                  }, 
                  icon: Icon(icon),
                  label: Text('Like'),
                  ),
                SizedBox(width: 20,),
                ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        ),
      );
  }
}

class BigCard extends StatelessWidget {
  // the constructor is used to initialize a widget's properties when it is created
  const BigCard({
    super.key,
    required this.pair,
  });

  // property of the widget, a final field cuz this is a stateless widget
  final WordPair pair;

  // the build method
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium?.copyWith(
      color: theme.colorScheme.onPrimary
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",),
      ),
    );
  }
}