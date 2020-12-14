# MiCubacel SDK

```dart
import 'package:micubacel_sdk/micubacel_sdk.dart';

void main(List<String> args) async {
  var client = CubacelClient();

  // client.login("phone_number", "password")
  await client.login("55555555", "12345678");

  print('${client.welcomeMessage}\n');

  print('Username: ${client.userName}');
  print('Phone Number: ${client.phoneNumber}\n');

  print('Credit: ${client.credit}');
  print('Expire: ${client.expire}\n');

  var nationalData = client.nationalDataBonus;

  print('National Data Bonus: ' + nationalData['data']);
  print('National Data Bonus Percent: ' + nationalData['percent'] + '%');
  print('National Data Bonus Expire: ' + nationalData['expire'] + '\n');

  var lteData = client.lteDataBonus;

  print('LTE Data Bonus: ' + lteData['data']);
  print('LTE Data Bonus Percent: ' + lteData['percent'] + '%');
  print('LTE Data Bonus Expire: ' + lteData['expire'] + '\n');

  var data = client.data;

  print('Data: ' + data['data']);
  print('Percent: ' + data['percent'] + '%');
  print('Expire: ' + data['expire']);
  print('Only LTE: ' + data['lte']);
  print('All Networks: ' + data['all']);

  var products = client.products;
  Product buyProduct;

  for (var p in products) {
    print('\n');
    print('Product: ${p.title}');
    print(p.description);
    print('Price: ${p.price}');

    if (p.title == 'Paquete 1 GB') {
      buyProduct = p;
    }
  }

  var buyResponse = client.buy(buyProduct);

  print('\nBUY RESPONSE: ');
  print(buyResponse);
}
```

Basado en la lib [selibrary](https://github.com/marilasoft/selibrary) de [marilasoft](https://github.com/marilasoft)