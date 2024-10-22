import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dersler Galerisi',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple,
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> categories = [
    'Türkçe',
    'Matematik',
    'Kimya',
    'Geometri',
    'Fizik',
    'Biyoloji',
    'Tarih'
  ];

  String lastUpdatedDate = '';

  @override
  void initState() {
    super.initState();
    fetchLastUpdatedDate();
  }

  Future<void> fetchLastUpdatedDate() async {
    String url =
        'https://raw.githubusercontent.com/ynskhrmn0/Dophing-Memory/main/yanitlar.json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        lastUpdatedDate = jsonData['Date'];
      });
    } else {
      throw Exception('Tarih yüklenemedi');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dersler'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(categories[index]),
                  onTap: () {
                    if (categories[index] == 'Türkçe' ||
                        categories[index] == 'Tarih' ||
                        categories[index] == 'Geometri') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PhotoGalleryPage(category: categories[index]),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CategoryPage(category: categories[index]),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  'Son değiştirilme tarihi: $lastUpdatedDate',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '~Developed by Yunus',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryPage extends StatelessWidget {
  final String category;

  CategoryPage({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${category} Alt Kategorileri'),
      ),
      body: ListView(
        children: ['12', 'AYT', 'TYT'].map((subCategory) {
          return ListTile(
            title: Text(subCategory),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubCategoryPage(
                      category: category, subCategory: subCategory),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

class SubCategoryPage extends StatelessWidget {
  final String category;
  final String subCategory;

  SubCategoryPage({required this.category, required this.subCategory});

  Future<List<String>> fetchPhotos(String category, String subCategory) async {
    String url =
        'https://raw.githubusercontent.com/ynskhrmn0/Dophing-Memory/main/yanitlar.json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final photos = jsonData[category][subCategory]['photos'];
      return List<String>.from(photos);
    } else {
      throw Exception('Fotoğraflar yüklenemedi');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category - $subCategory'),
      ),
      body: FutureBuilder<List<String>>(
        future: fetchPhotos(category, subCategory),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Fotoğraf bulunamadı'));
          } else {
            final photos = snapshot.data!;
            return LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                    childAspectRatio:
                        1.0, // Kare yapmak için childAspectRatio 1.0 olarak ayarlanır
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: Container(
                                child: Image.network(photos[index]),
                              ),
                            );
                          },
                        );
                      },
                      child: AspectRatio(
                        aspectRatio: 1.0, // Kare kutucuk için aspectRatio 1.0
                        child: Container(
                          margin: EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[900], // Kutunun rengi mor
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              photos[index],
                              fit: BoxFit
                                  .contain, // Resmin kutuyu kırpmadan tamamını göstermesini sağlar
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class PhotoGalleryPage extends StatelessWidget {
  final String category;

  PhotoGalleryPage({required this.category});

  Future<List<String>> fetchPhotos(String category) async {
    String url =
        'https://raw.githubusercontent.com/ynskhrmn0/Dophing-Memory/main/yanitlar.json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final photos = jsonData[category]['photos'];
      return List<String>.from(photos);
    } else {
      throw Exception('Fotoğraflar yüklenemedi');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category Fotoğrafları'),
      ),
      body: FutureBuilder<List<String>>(
        future: fetchPhotos(category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Fotoğraf bulunamadı'));
          } else {
            final photos = snapshot.data!;
            return LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                    childAspectRatio:
                        1.0, // Kare yapmak için childAspectRatio 1.0 olarak ayarlanır
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: Container(
                                child: Image.network(photos[index]),
                              ),
                            );
                          },
                        );
                      },
                      child: AspectRatio(
                        aspectRatio: 1.0, // Kare kutucuk için aspectRatio 1.0
                        child: Container(
                          margin: EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[900], // Kutunun rengi mor
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              photos[index],
                              fit: BoxFit
                                  .contain, // Resmin kutuyu kırpmadan tamamını göstermesini sağlar
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
