import 'package:html/dom.dart';

class Product {
  final Element element;
  Product({this.element});

  String get title {
    return element.querySelector('h4').text;
  }

  String get description {
    return element
        .querySelector(
            'div[class="offerPresentationProductDescription_msdp product_desc"]')
        .querySelector('span')
        .text;
  }

  String get price {
    return element
        .querySelector(
            'div[class="offerPresentationProductDescription_msdp product_desc"]')
        .querySelector('span[class="bold"]')
        .text;
  }

  String get urlBuyAction {
    return element
        .querySelector(
            'div[class="offerPresentationProductBuyAction_msdp ptype"]')
        .querySelector(
            'a[class="offerPresentationProductBuyLink_msdp button_style link_button"]')
        .attributes['href'];
  }
}
