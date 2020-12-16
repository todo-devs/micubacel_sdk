import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:micubacel_sdk/src/constants.dart';
import 'package:micubacel_sdk/src/models/Product.dart';

class CubacelClient {
  var cookieJar = CookieJar();
  var httpClient = Dio();

  var urlsMCP = Map<String, String>();

  var currentPage = Document();
  var homePage = Document();
  var myAccountPage = Document();
  var productsPage = Document();

  String get welcomeMessage {
    return homePage
        .querySelector('div[class="banner_bg_color mBottom20"]')
        .querySelector('h2')
        .text;
  }

  String get userName {
    var username = welcomeMessage.replaceFirst('Bienvenido ', '');
    return username.replaceFirst('a MiCubacel', '');
  }

  String get phoneNumber {
    for (var div in myAccountDetailsBlock) {
      if (div
          .querySelector('div[class="mad_row_header"]')
          .querySelector('div[class="col1"]')
          .text
          .startsWith('Mi Cuenta')) {
        return div
            .querySelector('div[class="mad_row_footer"]')
            .querySelector('div[class="col1"]')
            .querySelector('span[class="cvalue"]')
            .text;
      }
    }
    return null;
  }

  String get credit {
    for (var div in myAccountDetailsBlock) {
      if (div
          .querySelector('div[class="mad_row_header"]')
          .querySelector('div[class="col1"]')
          .text
          .startsWith('Mi Cuenta')) {
        return div
            .querySelector('div[class="mad_row_header"]')
            .querySelector('div[class="col2"]')
            .querySelector('span[class="cvalue bold cuc-font"]')
            .text;
      }
    }
    return null;
  }

  String get expire {
    for (var div in myAccountDetailsBlock) {
      if (div
          .querySelector('div[class="mad_row_header"]')
          .querySelector('div[class="col1"]')
          .text
          .startsWith('Mi Cuenta')) {
        return div
            .querySelector('div[class="mad_row_footer"]')
            .querySelector('div[class="col2"]')
            .querySelector('span[class="cvalue"]')
            .text;
      }
    }
    return null;
  }

  Map<String, String> get nationalDataBonus {
    var data = Map<String, String>();

    var accordion =
        myAccountPage.querySelectorAll('.mad_accordion_container').first;

    var col1 = accordion.querySelectorAll('.col1').first;
    var col2 = accordion.querySelectorAll('.col2').first;

    var chart_data = col1.querySelector('.charts_data').querySelector('div');

    data['data'] = chart_data.attributes['data-text'] +
        ' ' +
        chart_data.attributes['data-info'];

    data['percent'] = chart_data.attributes['data-percent'];

    data['expire'] = col2.querySelector('.expires_date').text +
        ' ' +
        col2.querySelector('.expires_hours').text;

    return data;
  }

  Map<String, String> get lteDataBonus {
    var data = Map<String, String>();

    var accordion =
        myAccountPage.querySelectorAll('.mad_accordion_container').first;

    var col1 = accordion.querySelectorAll('.col1').last;
    var col2 = accordion.querySelectorAll('.col2').last;

    var chart_data = col1.querySelector('.charts_data').querySelector('div');

    data['data'] = chart_data.attributes['data-text'] +
        ' ' +
        chart_data.attributes['data-info'];

    data['percent'] = chart_data.attributes['data-percent'];

    data['expire'] = col2.querySelector('.expires_date').text +
        ' ' +
        col2.querySelector('.expires_hours').text;

    return data;
  }

  Map<String, String> get data {
    var data = Map<String, String>();

    var accordion =
        myAccountPage.querySelectorAll('.mad_accordion_container').last;

    var col1 = accordion.querySelectorAll('.col1').first;
    var col2 = accordion.querySelectorAll('.col2').first;

    var chart_data = col1.querySelector('.charts_data').querySelector('div');

    data['data'] = chart_data.attributes['data-text'] +
        ' ' +
        chart_data.attributes['data-info'];

    data['percent'] = chart_data.attributes['data-percent'];

    data['expire'] = col2.querySelector('.expires_date').text +
        ' ' +
        col2.querySelector('.expires_hours').text;

    var network_all = col1.querySelectorAll('.network_all');

    if (network_all.length == 2) {
      data['lte'] = network_all.first.text.split(':').last.trim();

      data['all'] = network_all.last.text.split(':').last.trim();
    } else if (network_all.length == 1) {
      var e = network_all.first;

      if (e.text.split(':').first.trim() == 'Para todas las redes:') {
        data['all'] = e.text.split(':').last.trim();
        data['lte'] = '0 B';
      } else {
        data['lte'] = e.text.split(':').last.trim();
        data['all'] = '0 B';
      }
    } else {
      data['all'] = data['lte'] = '0 B';
    }

    return data;
  }

  String get creditBonus {
    for (var div in myAccountDetailsBlock) {
      if (div
              .querySelector('div[class="mad_row_header"]')
              .querySelectorAll('div[class="col1"]')
              .isNotEmpty &&
          div
              .querySelector('div[class="mad_row_header"]')
              .querySelector('div[class="col1"]')
              .text
              .startsWith('Bono')) {
        return div
            .querySelector('div[class="mad_row_header"]')
            .querySelector('div[class="col2"]')
            .querySelector('span[class="cvalue bold cuc-font"]')
            .text;
      }
    }
    return null;
  }

  String get expireBonus {
    for (var div in myAccountDetailsBlock) {
      if (div
              .querySelector('div[class="mad_row_header"]')
              .querySelectorAll('div[class="col1"]')
              .isNotEmpty &&
          div
              .querySelector('div[class="mad_row_header"]')
              .querySelector('div[class="col1"]')
              .text
              .startsWith('Bono')) {
        return div
            .querySelector('div[class="mad_row_footer"]')
            .querySelector('div[class="col2"]')
            .querySelector('span[class="cvalue"]')
            .text;
      }
    }
    return null;
  }

  String get dateBonus {
    for (var div in divsCol1a) {
      if (div.text.startsWith('Fecha del Adelanto: ')) {
        return div.querySelector('span[class="cvalue bold"]').text;
      }
    }
    return null;
  }

  // MyAccount Scrapping Helpers
  List<Element> get myAccountDetailsBlock {
    return myAccountPage
        .querySelectorAll('div[class="myaccount_details_block"]');
  }

  List<Element> get divsCol1a {
    return myAccountPage.querySelectorAll('div[class="col1a"]');
  }

  List<Element> get divsCol2a {
    return myAccountPage.querySelectorAll('div[class="col2a"]');
  }
  // End MyAccount Scrapping Helpers

  // Products
  List<Product> get products {
    var list = List<Product>();

    for (var e
        in productsPage.querySelectorAll('div[class="product_inner_block"]')) {
      list.add(Product(element: e));
    }

    return list;
  }

  CubacelClient() {
    // No verificar certificado https
    (httpClient.httpClientAdapter as DefaultHttpClientAdapter)
        .onHttpClientCreate = (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    // Almacenar cookies en ram
    httpClient.interceptors.add(CookieManager(cookieJar));
  }

  Future login(String phoneNumber, String password) async {
    await httpClient.get(WELCOME_LOGIN_ES_URL);

    var formData = {
      'language': 'es_ES',
      'username': phoneNumber,
      'password': password,
      'uword': 'amount'
    };

    var res = await httpClient.post(
      LOGIN_URL,
      queryParameters: formData,
      options: Options(validateStatus: (status) {
        return status < 500;
      }),
    );

    res = await httpClient.get(res.headers['location'].first);
    currentPage = parse(res.data);

    if (currentPage
        .querySelectorAll('div[class="body_wrapper error_page"]')
        .isNotEmpty) {
      var msg = currentPage
          .querySelector('div[class="body_wrapper error_page"]')
          .querySelector('div[class="welcome_login error_Block"]')
          .querySelector('div[class="container"]')
          .querySelector('b')
          .text;

      print(msg);
    } else {
      await loadHomePage();
      await loadMyAccount();
      await loadProducts();
    }
  }

  Future loadHomePage() async {
    var urlSpanish = '';
    var urls = currentPage.querySelectorAll('a[class="link_msdp langChange"]');

    for (var url in urls) {
      if (url.id == 'spanishLanguage') {
        urlSpanish = url.attributes['href'];
      }
    }

    if (urlsMCP.isNotEmpty) urlsMCP.clear();

    urlsMCP['home'] = BASE_URL + urlSpanish;

    var res = await httpClient.get(urlsMCP['home']);
    currentPage = parse(res.data);
    homePage = parse(res.data);

    var div = currentPage.querySelector(
        'div[class="collapse navbar-collapse navbar-main-collapse"]');
    var lis = div.querySelectorAll('li');

    for (var li in lis) {
      switch (li.text.trim()) {
        case 'Ofertas':
          urlsMCP['offers'] =
              BASE_URL + li.querySelector('a').attributes['href'];
          break;
        case 'Productos':
          urlsMCP['products'] =
              BASE_URL + li.querySelector('a').attributes['href'];
          break;
        case 'Mi Cuenta':
          urlsMCP['myAccount'] =
              BASE_URL + li.querySelector('a').attributes['href'];
          break;
        case 'Soporte':
          urlsMCP['support'] =
              BASE_URL + li.querySelector('a').attributes['href'];
          break;
      }
    }
  }

  Future loadMyAccount() async {
    if (urlsMCP['myAccount'] != null) {
      final res = await httpClient.get(urlsMCP['myAccount']);
      myAccountPage = parse(res.data);

      urlsMCP['changeBonusServices'] = BASE_URL +
          myAccountPage
              .querySelector('form[id="toogle-internet"]')
              .attributes['action'];
    }
  }

  Future loadProducts() async {
    if (urlsMCP['products'] != null) {
      final res = await httpClient.get(urlsMCP['products']);
      productsPage = parse(res.data);
    }
  }

  Future<String> buy(Product product) async {
    var res = await httpClient.get(BASE_URL + product.urlBuyAction);
    var page = parse(res.data);

    var urlBuy = page
        .querySelector(
            'a[class="offerPresentationProductBuyLink_msdp button_style link_button"]')
        .attributes['href'];

    res = await httpClient.get(BASE_URL + urlBuy);
    page = parse(res.data);

    return page
        .querySelector('div[class="products_purchase_details_block"]')
        .querySelectorAll('p')
        .last
        .text;
  }
}
