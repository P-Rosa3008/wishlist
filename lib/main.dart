import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

void main() {
  runApp(const ScrapingApp());
}

class ScrapingApp extends StatelessWidget {
  const ScrapingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web Scraping Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _title = '';
  String? _image = '';
  String? _description = '';
  String? _price = '';
  bool _isLoading = false;

  Future<void> _scrapeUrl(String url) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final document = parse(response.body);

      // Extract title
      final titleElement = document.querySelectorAll('#productTitle').map((e) => e.innerHtml.trim()).toString();
      setState(() {
        _title = titleElement;
      });

      // Extract image
      final imageElement = document.querySelector('img');
      if (imageElement != null) {
        setState(() {
          _image = imageElement.attributes['src'];
        });
      }

      // Extract description
      final descriptionElement = document.querySelector('meta[name="description"]');
      if (descriptionElement != null) {
        setState(() {
          _description = descriptionElement.attributes['content'];
        });
      }

      // Extract price
      final priceElement = document.querySelector('.product-price');
      if (priceElement != null) {
        setState(() {
          _price = priceElement.text;
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Scraping Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Enter URL',
              ),
              onChanged: (value) {
                // Reset the scraped data when the URL changes
                setState(() {
                  _title = '';
                  _image = '';
                  _description = '';
                  _price = '';
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                _scrapeUrl(
                    'https://www.amazon.com/Apple-iPhone-11-64GB-Black/dp/B07ZPKN6YR?ref_=Oct_d_obs_d_7072561011_0&pd_rd_w=xGB5d&content-id=amzn1.sym.68cf20ef-f2f0-42ca-8c87-ad9617594532&pf_rd_p=68cf20ef-f2f0-42ca-8c87-ad9617594532&pf_rd_r=W07BWQKV80WS6BKXB3T2&pd_rd_wg=ky4P1&pd_rd_r=b30c9c6c-0274-43a7-8f82-9e3c7e421aeb&pd_rd_i=B07ZPKN6YR'); // Replace with your desired URL
              },
              child: const Text('Scrape'),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Title: $_title'),
                      Text('Image: $_image'),
                      Text('Description: $_description'),
                      Text('Price: $_price'),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
