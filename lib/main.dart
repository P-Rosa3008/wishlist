import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as dom;
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'dart:io';

void main() {
  runApp(const ScrapingApp());
}

class ScrapingApp extends StatelessWidget {
  const ScrapingApp({Key? key}) : super(key: key);

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
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

// final cookieJar = CookieJar();

class _HomePageState extends State<HomePage> {
  String? _title = '';
  String? _image = '';
  String? _description = '';
  String? _price = '';
  bool _isLoading = false;

  final _dio = Dio()..options.validateStatus = (status) => status != null && status >= 200 && status < 400;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _scrapeUrl(String url) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _dio.get(
        url,
        options: Options(
          followRedirects: true,
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
            'Accept-Language': 'en-US, en;q=0.5',
          },
        ),
      );

      if (response.statusCode == 302) {
        final cookieJar = CookieJar();
        final dio = Dio()
          ..options.headers = {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
            'Accept-Language': 'en-US, en;q=0.5',
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7'
          }
          ..interceptors.add(CookieManager(cookieJar))
          ..options.followRedirects = false
          ..options.validateStatus = (status) => status != null && status >= 200 && status < 400;

        final responde = await dio.get(
          response.realUri.toString(),
        );

        print(responde.statusCode.toString() + responde.statusMessage!);
        print(responde.data);
      }

      if (response.statusCode == 200) {
        _processScrapedData(response);
      }
    } catch (error) {
      print('Error: $error');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _processScrapedData(Response<dynamic> response) {
    final document = htmlParser.parse(response.data);
    final titleElement = document.querySelector('span#productTitle');
    final imageElement = document.querySelector('img#landingImage');
    final descriptionElement = document.querySelector('meta[name="description"]');
    final priceElement = document.querySelector('span#price_inside_buybox');

    setState(() {
      _title = titleElement?.text.trim();
      _image = imageElement?.attributes['data-old-hires'];
      _description = descriptionElement?.attributes['content'];
      _price = priceElement?.text.trim();
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
              },
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _title = '';
                  _image = '';
                  _description = '';
                  _price = '';
                });
                _scrapeUrl(
                    'https://www.amazon.com/Apple-iPhone-12-64GB-Black/dp/B08PP5MSVB/ref=sr_1_1?keywords=iphone&qid=1689802479&sr=8-1&th=1%2Frobots.txt');
              },
              child: const Text('Scrape Amazon'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _title = '';
                  _image = '';
                  _description = '';
                  _price = '';
                });
                _scrapeUrl('https://www.colchaoemma.pt/emmahybrid/');
              },
              child: const Text('Scrape Emma'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _title = '';
                  _image = '';
                  _description = '';
                  _price = '';
                });
                _scrapeUrl('https://www.bertrand.pt/livro/debaixo-da-onda-em-waimea-paul-theroux/27218518');
              },
              child: const Text('Scrape Bertrand'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _title = '';
                  _image = '';
                  _description = '';
                  _price = '';
                });
                _scrapeUrl(
                    'https://www.pcdiga.com/mobilidade/smartphones-e-telemoveis/smartphones-iphone/smartphone-apple-iphone-13-6-1-128gb-meia-noite-mlpf3ql-a-194252707197');
              },
              child: const Text('Scrape PC Diga'),
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
                      // _image!.isNotEmpty ? Image.network(_image!) : const Text('Image:'),
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
