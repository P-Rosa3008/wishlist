import 'dart:io';

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
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

  var response;

  final client = HttpClient();
  String? url;

  Future<void> _scrapeUrl(String url) async {
    setState(() {
      _isLoading = true;
    });

    http.Request req = http.Request(
      "Get",
      Uri.parse(url),
    )..followRedirects = false;
    req.headers.addAll({
      'User-Agent':
          'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36',
      'Accept-Language': 'en-US, en;q=0.5',
    });
    http.Client baseClient = http.Client();
    http.StreamedResponse streamedResponse = await baseClient.send(req);
    response = await http.Response.fromStream(streamedResponse);
    Uri redirectUri = Uri.parse(response.headers['location'] ?? "");

    do {
      http.Request req = http.Request(
        "Get",
        Uri.parse(redirectUri.toString()),
      )..followRedirects = false;
      req.headers.addAll({
        'User-Agent':
            'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36',
        'Accept-Language': 'en-US, en;q=0.5',
      });
      http.Client baseClient = http.Client();
      http.StreamedResponse streamedResponse = await baseClient.send(req);
      response = await http.Response.fromStream(streamedResponse);
    } while (redirectUri.toString() != "" && !redirectUri.toString().startsWith('https://www.'));

    print("REDIRECT: $redirectUri");

    if (response.statusCode == 200) {
      dom.Document html = dom.Document.html(response.body);
      html.body?.attributes.forEach((key, value) {
        print(value);
      });
      // Extract title
      final titleElement = html.querySelectorAll('h1 > span').map((e) => e.innerHtml.trim()).toList();
      setState(() {
        _title = titleElement[0];
      });

      // Extract image
      final imageElement = html.querySelector('span > span > div > img');
      if (imageElement != null) {
        setState(() {
          _image = imageElement.attributes['src'];
        });
      }

      // Extract description
      final descriptionElement = html.querySelector('meta[name="description"]');
      if (descriptionElement != null) {
        setState(() {
          _description = descriptionElement.attributes['content'];
        });
      }

      // Extract price
      final priceElement = html.querySelector(
          '#corePrice_desktop > div > table > tbody > tr:nth-child(2) > td.a-span12 > span.a-price.a-text-price.a-size-medium.apexPriceToPay > span.a-offscreen');
      if (priceElement != null) {
        setState(() {
          _price = priceElement.text;
        });
      }
    } else {
      print(response.statusCode);
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
                  url = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                _scrapeUrl(url!); // Replace with your desired URL
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
                      // Text('Image: $_image'),
                      _image!.isNotEmpty ? Image.network(_image!) : const Text('Image:'),
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
