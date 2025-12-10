# 🚀 Flutter'da En Çok Kullanılan 10 Design Pattern (Basit ve Detaylı Açıklamalar)

Merhaba! Bu yazıda Flutter geliştirirken karşılaşacağınız en önemli 10 tasarım desenini, günlük hayattan örneklerle ve basit bir dille açıklayacağım. Her pattern'i "nedir, neden kullanılır, nasıl çalışır, ne zaman kullanılır" sorularını cevaplayarak derinlemesine inceleyeceğiz.

---

## 1️⃣ Repository Pattern - Veri Kaynaklarını Soyutlamak

### Nedir?

Repository Pattern, uygulamanızın veri kaynaklarını (API, veritabanı, cache, Firebase, local dosyalar) UI katmanından tamamen ayıran bir desendir. Düşünün ki bir restoranda çalışıyorsunuz. Müşteriler sadece garsonla konuşur, mutfakta ne olduğunu bilmezler. Repository de tam olarak böyle çalışır - UI sadece repository ile konuşur, verinin nereden geldiğini bilmez.

### Neden Kullanılır?

Diyelim ki uygulamanız başlangıçta sadece API'den veri çekiyor. Sonra performans için cache eklemek istiyorsunuz. Eğer UI doğrudan API servisine bağlıysa, her yerde değişiklik yapmanız gerekir. Repository kullanırsanız, sadece repository içinde değişiklik yaparsınız, UI hiç etkilenmez. Ayrıca test yazarken gerçek API yerine sahte (mock) bir repository kullanabilirsiniz, bu da testleri çok daha hızlı ve kolay hale getirir.

### Nasıl Çalışır?

Repository bir arayüz (interface) olarak başlar. Bu arayüz, "notları getir", "notu kaydet" gibi metodlar tanımlar. Sonra bu arayüzü gerçekleştiren (implement eden) bir sınıf yazarsınız. Bu sınıf içinde API çağrıları, veritabanı işlemleri gibi gerçek işlemler yapılır. UI ise sadece repository arayüzünü kullanır, gerçek implementasyonu bilmez.

### Ne Zaman Kullanılır?

- Farklı veri kaynakları kullanıyorsanız (API, database, cache)
- Veri kaynağını değiştirmek istediğinizde UI'yı etkilemek istemiyorsanız
- Test yazmak istiyorsanız
- Temiz mimari (Clean Architecture) kullanıyorsanız

**Basit Örnek:**

```dart
// Önce arayüzü tanımlıyoruz
abstract class NotesRepository {
  Future<List<Note>> getNotes();
  Future<void> saveNote(Note note);
}

// Sonra gerçek implementasyonu yazıyoruz
class NotesRepositoryImpl implements NotesRepository {
  final NotesApiService apiService;
  
  NotesRepositoryImpl(this.apiService);
  
  @override
  Future<List<Note>> getNotes() async {
    // API'den veri çekiyoruz
    final response = await apiService.fetchNotes();
    return response;
  }
  
  @override
  Future<void> saveNote(Note note) async {
    // API'ye kaydediyoruz
    await apiService.postNote(note);
  }
}

// UI'da kullanımı
class HomePage extends StatelessWidget {
  final NotesRepository repository;
  
  HomePage(this.repository);
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Note>>(
      future: repository.getNotes(), // UI sadece repository'yi biliyor
      builder: (context, snapshot) {
        // UI verinin nereden geldiğini bilmiyor
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data![index].title),
              );
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

---

## 2️⃣ Factory Pattern - Nesne Oluşturmayı Merkezileştirmek

### Nedir?

Factory Pattern, nesne oluşturma işlemini tek bir yerde toplayan bir desendir. Düşünün ki bir araba fabrikası var. Müşteri sadece "SUV istiyorum" der, fabrika hangi modeli üreteceğine karar verir. Factory Pattern de böyle çalışır - siz sadece "bu tipte bir nesne istiyorum" dersiniz, factory hangi sınıfı oluşturacağına karar verir.

### Neden Kullanılır?

Bazen bir nesne oluştururken karmaşık kararlar vermeniz gerekir. Örneğin, kullanıcının cihazına göre farklı widget'lar oluşturmak. Ya da API'den gelen veri tipine göre farklı model sınıfları oluşturmak. Bu durumlarda her yerde if-else yazmak yerine, factory'ye "bana uygun nesneyi ver" dersiniz. Kod daha temiz ve yönetilebilir olur.

### Nasıl Çalışır?

Factory genellikle bir sınıf içinde static bir metod olarak yazılır. Bu metod, parametre olarak bir tip alır ve o tipe uygun nesneyi oluşturup döner. Bazen switch-case, bazen if-else kullanılır. Önemli olan, nesne oluşturma mantığının tek bir yerde toplanmasıdır.

### Ne Zaman Kullanılır?

- Farklı tiplerde nesneler oluşturmanız gerektiğinde
- Nesne oluşturma mantığı karmaşık olduğunda
- Runtime'da (çalışma zamanında) hangi nesnenin oluşturulacağına karar verildiğinde
- API response'larını modele dönüştürürken

**Basit Örnek:**

```dart
// Farklı hayvan tipleri
abstract class Animal {
  void makeSound();
}

class Dog implements Animal {
  @override
  void makeSound() {
    print('Hav hav!');
  }
}

class Cat implements Animal {
  @override
  void makeSound() {
    print('Miyav!');
  }
}

class Bird implements Animal {
  @override
  void makeSound() {
    print('Cik cik!');
  }
}

// Factory sınıfı - nesne oluşturmayı yönetiyor
class AnimalFactory {
  static Animal create(String type) {
    switch (type.toLowerCase()) {
      case 'dog':
      case 'köpek':
        return Dog();
      case 'cat':
      case 'kedi':
        return Cat();
      case 'bird':
      case 'kuş':
        return Bird();
      default:
        throw Exception('Bilinmeyen hayvan tipi: $type');
    }
  }
}

// Kullanımı çok basit
void main() {
  // Factory'ye sadece tip söylüyoruz
  Animal myPet = AnimalFactory.create('dog');
  myPet.makeSound(); // Hav hav!
  
  Animal anotherPet = AnimalFactory.create('cat');
  anotherPet.makeSound(); // Miyav!
}
```

---

## 3️⃣ Singleton Pattern - Tek Bir Örnek Garantisi

### Nedir?

Singleton Pattern, bir sınıfın uygulama boyunca sadece bir kez oluşturulmasını ve her yerden aynı örneğe erişilmesini sağlar. Günlük hayattan örnek: Bir şirkette sadece bir CEO vardır. Herkes aynı CEO'ya başvurur. Singleton da böyle çalışır - uygulamanızda sadece bir logger, bir veritabanı bağlantısı, bir ayar yöneticisi olur ve her yerden aynı örneğe erişirsiniz.

### Neden Kullanılır?

Bazı sınıflar için birden fazla örnek oluşturmak mantıksızdır. Örneğin, bir logger sınıfınız var. Her log yazdığınızda yeni bir logger oluşturursanız, hem bellek israfı olur hem de loglar tutarsız olabilir. Singleton kullanarak, uygulama boyunca aynı logger örneğini kullanırsınız. Bu hem performans hem de tutarlılık sağlar.

### Nasıl Çalışır?

Singleton'da sınıfın constructor'ı private (özel) yapılır, yani dışarıdan doğrudan nesne oluşturulamaz. Bunun yerine, static bir metod veya factory constructor kullanılır. Bu metod, eğer örnek daha önce oluşturulmamışsa yeni bir tane oluşturur, varsa mevcut olanı döner. Böylece her zaman aynı örneği alırsınız.

### Ne Zaman Kullanılır?

- Uygulama genelinde tek bir örnek olması gereken servisler için (Logger, Database, Analytics)
- Paylaşılan kaynaklar için (Cache, Configuration)
- Pahalı kaynaklar için (Veritabanı bağlantısı)
- Global state yönetimi için

**Basit Örnek:**

```dart
class Logger {
  // Tek örnek burada saklanıyor
  static Logger? _instance;
  
  // Constructor'ı private yapıyoruz
  Logger._internal() {
    print('Logger oluşturuldu');
  }
  
  // Factory constructor - her zaman aynı örneği döner
  factory Logger() {
    // Eğer örnek yoksa oluştur, varsa mevcut olanı döndür
    _instance ??= Logger._internal();
    return _instance!;
  }
  
  // Log yazma metodu
  void log(String message) {
    print('[LOG] ${DateTime.now()}: $message');
  }
  
  void error(String message) {
    print('[ERROR] ${DateTime.now()}: $message');
  }
}

// Kullanımı
void main() {
  // İlk çağrı - yeni örnek oluşturulur
  Logger logger1 = Logger();
  logger1.log('İlk log mesajı');
  
  // İkinci çağrı - aynı örnek döner (yeni oluşturulmaz)
  Logger logger2 = Logger();
  logger2.log('İkinci log mesajı');
  
  // logger1 ve logger2 aynı örnektir
  print(logger1 == logger2); // true
  
  // Her yerden aynı logger'a erişebilirsiniz
  Logger().error('Bir hata oluştu');
}
```

---

## 4️⃣ Adapter Pattern - Uyumsuz Arayüzleri Uyumlu Hale Getirmek

### Nedir?

Adapter Pattern, bir sınıfın arayüzünü başka bir arayüze dönüştüren bir desendir. Günlük hayattan örnek: Avrupa'da seyahat ediyorsunuz ve telefon şarjınız bitti. Türkiye'den getirdiğiniz şarj aleti Avrupa prizlerine uymuyor. Ne yaparsınız? Bir adaptör alırsınız! Adapter Pattern de tam olarak bunu yapar - uyumsuz iki sistemi birbirine bağlar.

### Neden Kullanılır?

Bazen dış bir kütüphane veya API kullanmanız gerekir ama bu sistemin arayüzü sizin beklediğinizden farklıdır. Ya da eski bir kodunuz var ve yeni sisteme entegre etmek istiyorsunuz. Her iki durumda da adapter kullanarak, mevcut kodunuzu değiştirmeden yeni sistemi kullanabilirsiniz. API'den gelen veri formatı uygulamanızın beklediğinden farklıysa, adapter bu dönüşümü yapar.

### Nasıl Çalışır?

Adapter, uyumsuz iki arayüz arasında köprü görevi görür. Eski sistemin metodlarını çağırır ama yeni sistemin beklediği formatta sonuç döner. Ya da tam tersi - yeni sistemin metodlarını eski sistemin anlayacağı şekilde çağırır. Genellikle bir sınıf olarak yazılır ve her iki arayüzü de implement eder veya composition kullanır.

### Ne Zaman Kullanılır?

- Üçüncü parti kütüphaneleri entegre ederken
- API'den gelen veri formatı uygulamanızın beklediğinden farklıysa
- Eski kodu yeni sisteme entegre ederken
- Farklı veri kaynaklarını aynı arayüzle kullanmak istediğinizde

**Basit Örnek:**

```dart
// API'den gelen veri formatı (kısa isimlerle)
// {
//   "nid": "123",
//   "ttl": "Alışveriş Listesi",
//   "cnt": "Süt, ekmek, yumurta"
// }

// Uygulamamızın beklediği format
class Note {
  final String id;
  final String title;
  final String content;
  
  Note({
    required this.id,
    required this.title,
    required this.content,
  });
}

// Adapter - API formatını uygulama formatına çeviriyor
class NoteAdapter {
  static Note fromJson(Map<String, dynamic> json) {
    return Note(
      id: json["nid"] ?? "", // "nid" -> "id"
      title: json["ttl"] ?? "", // "ttl" -> "title"
      content: json["cnt"] ?? "", // "cnt" -> "content"
    );
  }
  
  // Tersine dönüşüm de yapabilir
  static Map<String, dynamic> toJson(Note note) {
    return {
      "nid": note.id,
      "ttl": note.title,
      "cnt": note.content,
    };
  }
}

// Kullanımı
void main() {
  // API'den gelen ham veri
  Map<String, dynamic> apiResponse = {
    "nid": "123",
    "ttl": "Alışveriş Listesi",
    "cnt": "Süt, ekmek, yumurta"
  };
  
  // Adapter ile dönüştürüyoruz
  Note note = NoteAdapter.fromJson(apiResponse);
  
  print(note.id); // 123
  print(note.title); // Alışveriş Listesi
  print(note.content); // Süt, ekmek, yumurta
  
  // Uygulama formatından API formatına
  Note myNote = Note(
    id: "456",
    title: "Yapılacaklar",
    content: "Kitap oku, spor yap"
  );
  
  Map<String, dynamic> apiFormat = NoteAdapter.toJson(myNote);
  // API'ye gönderebiliriz
}
```

---

## 5️⃣ Observer Pattern - Değişiklikleri Otomatik Bildirmek

### Nedir?

Observer Pattern, bir nesnedeki değişikliğin bağlı tüm nesnelere otomatik olarak bildirilmesini sağlar. Günlük hayattan örnek: Bir YouTube kanalına abone oldunuz. Kanal yeni video yüklediğinde size bildirim gelir. Observer Pattern de böyle çalışır - bir nesne değiştiğinde, ona "abone olan" tüm nesneler otomatik olarak bilgilendirilir.

### Neden Kullanılır?

Flutter'da UI'ınız veri değiştiğinde otomatik olarak güncellenmelidir. Eğer her değişiklikte manuel olarak UI'ı güncellemeye çalışırsanız, hem kod karmaşıklaşır hem de hatalar olur. Observer Pattern sayesinde, veri değiştiğinde UI otomatik olarak güncellenir. Flutter'daki Provider, Bloc, ChangeNotifier gibi yapıların hepsi bu pattern üzerine kuruludur.

### Nasıl Çalışır?

Observer Pattern'de iki tip nesne vardır: Subject (konu) ve Observer (gözlemci). Subject, durumu değişen nesnedir. Observer'lar ise bu değişikliklerden haberdar olmak isteyen nesnelerdir. Subject, observer'ları bir listede tutar ve değişiklik olduğunda hepsine bildirim gönderir. Flutter'da ChangeNotifier bu işi yapar - notifyListeners() çağrıldığında tüm dinleyicilere haber verilir.

### Ne Zaman Kullanılır?

- State management için (Provider, Bloc, Riverpod)
- UI'ın veri değişikliklerine otomatik tepki vermesi gerektiğinde
- Bir nesnenin durumu değiştiğinde birden fazla nesnenin bilgilendirilmesi gerektiğinde
- Event-driven (olay tabanlı) mimarilerde

**Basit Örnek:**

```dart
import 'package:flutter/material.dart';

// ChangeNotifier kullanarak Observer Pattern'i uyguluyoruz
class CounterNotifier extends ChangeNotifier {
  int _count = 0;
  
  // Dışarıdan sadece okunabilir
  int get count => _count;
  
  // Sayıyı artır
  void increment() {
    _count++;
    // Tüm dinleyicilere haber ver
    notifyListeners();
  }
  
  // Sayıyı azalt
  void decrement() {
    _count--;
    // Tüm dinleyicilere haber ver
    notifyListeners();
  }
  
  // Sıfırla
  void reset() {
    _count = 0;
    notifyListeners();
  }
}

// Kullanımı
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CounterNotifier(),
      child: CounterView(),
    );
  }
}

class CounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Consumer, CounterNotifier'daki değişiklikleri dinler
    return Consumer<CounterNotifier>(
      builder: (context, counter, child) {
        return Scaffold(
          appBar: AppBar(title: Text('Sayaç')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Sayı değiştiğinde otomatik güncellenir
                Text(
                  'Sayı: ${counter.count}',
                  style: TextStyle(fontSize: 48),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => counter.decrement(),
                      child: Text('-'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => counter.increment(),
                      child: Text('+'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => counter.reset(),
                  child: Text('Sıfırla'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

---

## 6️⃣ Strategy Pattern - Algoritmaları Değiştirilebilir Yapmak

### Nedir?

Strategy Pattern, bir işi yapmanın farklı yollarını birbirinin yerine kullanılabilir hale getirir. Günlük hayattan örnek: Bir şehre gitmek istiyorsunuz. Uçak, otobüs, tren veya araba ile gidebilirsiniz. Hangi yöntemi seçerseniz seçin, amacınız aynıdır - şehre varmak. Strategy Pattern de böyle çalışır - aynı işi farklı algoritmalarla yapabilirsiniz ve runtime'da (çalışma zamanında) hangi algoritmanın kullanılacağına karar verebilirsiniz.

### Neden Kullanılır?

Bazen bir işi yapmanın birden fazla yolu vardır. Örneğin, bir listeyi sıralamak - artan sırada, azalan sırada, alfabetik, tarihe göre vb. Eğer her sıralama türü için ayrı metod yazarsanız, kod tekrarı olur ve yeni bir sıralama türü eklemek zorlaşır. Strategy Pattern kullanarak, tüm sıralama algoritmalarını bir arayüz altında toplarsınız ve istediğiniz zaman değiştirebilirsiniz.

### Nasıl Çalışır?

Strategy Pattern'de önce bir strateji arayüzü tanımlarsınız. Bu arayüz, yapılacak işi tanımlayan bir metod içerir. Sonra her farklı algoritma için bu arayüzü implement eden bir sınıf yazarsınız. Kullanıcı sınıfı (Context) ise bu stratejilerden birini alır ve onu kullanır. Runtime'da farklı stratejiler arasında geçiş yapabilirsiniz.

### Ne Zaman Kullanılır?

- Farklı algoritmalar arasında seçim yapmanız gerektiğinde
- Kod içinde çok fazla if-else veya switch-case varsa
- Algoritmaları runtime'da değiştirmek istediğinizde
- Ödeme yöntemleri, sıralama algoritmaları, validasyon kuralları gibi durumlarda

**Basit Örnek:**

```dart
// Strateji arayüzü - sıralama algoritmasını tanımlıyor
abstract class SortStrategy {
  List<int> sort(List<int> numbers);
}

// Artan sıralama stratejisi
class AscendingSort implements SortStrategy {
  @override
  List<int> sort(List<int> numbers) {
    List<int> sorted = List.from(numbers);
    sorted.sort(); // Küçükten büyüğe
    return sorted;
  }
}

// Azalan sıralama stratejisi
class DescendingSort implements SortStrategy {
  @override
  List<int> sort(List<int> numbers) {
    List<int> sorted = List.from(numbers);
    sorted.sort((a, b) => b.compareTo(a)); // Büyükten küçüğe
    return sorted;
  }
}

// Context sınıfı - stratejiyi kullanıyor
class NumberSorter {
  SortStrategy _strategy;
  
  NumberSorter(this._strategy);
  
  // Stratejiyi değiştirebiliriz
  void setStrategy(SortStrategy strategy) {
    _strategy = strategy;
  }
  
  // Sıralama yap
  List<int> sortNumbers(List<int> numbers) {
    return _strategy.sort(numbers);
  }
}

// Kullanımı
void main() {
  List<int> numbers = [5, 2, 8, 1, 9, 3];
  
  // İlk olarak artan sıralama kullanıyoruz
  NumberSorter sorter = NumberSorter(AscendingSort());
  List<int> ascending = sorter.sortNumbers(numbers);
  print('Artan: $ascending'); // [1, 2, 3, 5, 8, 9]
  
  // Stratejiyi değiştiriyoruz - runtime'da!
  sorter.setStrategy(DescendingSort());
  List<int> descending = sorter.sortNumbers(numbers);
  print('Azalan: $descending'); // [9, 8, 5, 3, 2, 1]
  
  // Kullanıcı tercihine göre farklı stratejiler kullanabiliriz
  String userPreference = 'ascending'; // UI'dan gelen tercih
  
  if (userPreference == 'ascending') {
    sorter.setStrategy(AscendingSort());
  } else {
    sorter.setStrategy(DescendingSort());
  }
  
  List<int> result = sorter.sortNumbers(numbers);
  print('Kullanıcı tercihi: $result');
}
```

---

## 7️⃣ Decorator Pattern - Nesnelere Dinamik Özellik Eklemek

### Nedir?

Decorator Pattern, bir nesneye kalıtım kullanmadan yeni özellikler eklemenizi sağlar. Günlük hayattan örnek: Bir kahve siparişi veriyorsunuz. Önce basit bir espresso istersiniz. Sonra süt eklemek istersiniz. Sonra şeker, sonra krem şanti. Her ekleme, önceki kahveyi sarmalayarak yeni bir kahve oluşturur. Decorator Pattern de böyle çalışır - nesneleri sarmalayarak (wrap) yeni özellikler eklersiniz.

### Neden Kullanılır?

Bazen bir nesneye farklı kombinasyonlarda özellikler eklemek istersiniz. Eğer her kombinasyon için ayrı sınıf yazarsanız, sınıf sayısı patlar (Espresso, EspressoWithMilk, EspressoWithSugar, EspressoWithMilkAndSugar...). Decorator kullanarak, her özelliği ayrı bir decorator olarak yazarsınız ve istediğiniz kombinasyonu oluşturursunuz. Flutter'da widget'ları sarmalama (Container, Padding, Center) da bu pattern'e benzer.

### Nasıl Çalışır?

Decorator Pattern'de, temel nesne ve decorator'lar aynı arayüzü implement eder. Decorator, temel nesneyi içinde tutar (composition) ve ona yeni özellikler ekler. Her decorator, önceki nesneyi sarmalar ve üzerine kendi özelliğini ekler. Böylece zincirleme bir yapı oluşur.

### Ne Zaman Kullanılır?

- Nesnelere dinamik olarak özellik eklemek istediğinizde
- Kalıtım kullanmak yerine kompozisyon tercih ettiğinizde
- Özellik kombinasyonları çok fazlaysa
- Flutter widget'larını sarmalarken (Padding, Container, Center)

**Basit Örnek:**

```dart
// Temel arayüz
abstract class Coffee {
  String getDescription();
  double getCost();
}

// Basit kahve
class SimpleCoffee implements Coffee {
  @override
  String getDescription() => 'Basit Kahve';
  
  @override
  double getCost() => 10.0;
}

// Decorator temel sınıfı
abstract class CoffeeDecorator implements Coffee {
  Coffee _coffee;
  
  CoffeeDecorator(this._coffee);
  
  @override
  String getDescription() => _coffee.getDescription();
  
  @override
  double getCost() => _coffee.getCost();
}

// Süt ekleyen decorator
class MilkDecorator extends CoffeeDecorator {
  MilkDecorator(Coffee coffee) : super(coffee);
  
  @override
  String getDescription() => '${_coffee.getDescription()}, Süt';
  
  @override
  double getCost() => _coffee.getCost() + 2.0;
}

// Şeker ekleyen decorator
class SugarDecorator extends CoffeeDecorator {
  SugarDecorator(Coffee coffee) : super(coffee);
  
  @override
  String getDescription() => '${_coffee.getDescription()}, Şeker';
  
  @override
  double getCost() => _coffee.getCost() + 0.5;
}

// Krem şanti ekleyen decorator
class WhippedCreamDecorator extends CoffeeDecorator {
  WhippedCreamDecorator(Coffee coffee) : super(coffee);
  
  @override
  String getDescription() => '${_coffee.getDescription()}, Krem Şanti';
  
  @override
  double getCost() => _coffee.getCost() + 3.0;
}

// Kullanımı
void main() {
  // Sade kahve
  Coffee coffee1 = SimpleCoffee();
  print('${coffee1.getDescription()} - ${coffee1.getCost()} TL');
  // Basit Kahve - 10.0 TL
  
  // Sütlü kahve
  Coffee coffee2 = MilkDecorator(SimpleCoffee());
  print('${coffee2.getDescription()} - ${coffee2.getCost()} TL');
  // Basit Kahve, Süt - 12.0 TL
  
  // Sütlü ve şekerli kahve
  Coffee coffee3 = SugarDecorator(MilkDecorator(SimpleCoffee()));
  print('${coffee3.getDescription()} - ${coffee3.getCost()} TL');
  // Basit Kahve, Süt, Şeker - 12.5 TL
  
  // Her şeyli kahve!
  Coffee coffee4 = WhippedCreamDecorator(
    SugarDecorator(
      MilkDecorator(SimpleCoffee())
    )
  );
  print('${coffee4.getDescription()} - ${coffee4.getCost()} TL');
  // Basit Kahve, Süt, Şeker, Krem Şanti - 15.5 TL
}
```

---

## 8️⃣ Command Pattern - İşlemleri Nesne Olarak Temsil Etmek

### Nedir?

Command Pattern, bir işlemi nesne olarak temsil eder. Böylece işlemleri saklayabilir, sıraya koyabilir, geri alabilir (undo) veya tekrar oynatabilirsiniz. Günlük hayattan örnek: Bir restoranda sipariş veriyorsunuz. Garson siparişinizi bir kağıda yazar (komut nesnesi). Bu kağıt mutfağa gider, işlem yapılır. Eğer siparişi iptal etmek isterseniz, aynı kağıdı geri alırsınız. Command Pattern de böyle çalışır - her işlem bir komut nesnesi olur.

### Neden Kullanılır?

Bazen kullanıcı işlemlerini kaydetmek, geri almak veya tekrar yapmak istersiniz. Örneğin bir metin editöründe "Geri Al" (Undo) özelliği. Ya da bir oyunda komutları kaydedip tekrar oynatmak. Eğer işlemleri direkt metod çağrıları olarak yaparsanız, bunları saklayamaz veya geri alamazsınız. Command Pattern ile her işlem bir nesne olduğu için, bunları kolayca yönetebilirsiniz.

### Nasıl Çalışır?

Command Pattern'de bir Command arayüzü vardır. Bu arayüz genellikle `execute()` ve `undo()` metodlarını içerir. Her işlem için bu arayüzü implement eden bir sınıf yazarsınız. Bu sınıf, işlemi yapacak nesneyi (receiver) içerir ve `execute()` çağrıldığında işlemi yapar. İşlemleri bir listede saklayarak undo/redo özelliği ekleyebilirsiniz.

### Ne Zaman Kullanılır?

- Undo/Redo özelliği eklemek istediğinizde
- İşlemleri sıraya koymak (queue) veya loglamak istediğinizde
- İşlemleri zamanlayarak (schedule) yapmak istediğinizde
- UI komutlarını nesne olarak temsil etmek istediğinizde

**Basit Örnek:**

```dart
// Komut arayüzü
abstract class Command {
  void execute();
  void undo();
}

// Işık sınıfı (receiver - işlemi yapan nesne)
class Light {
  bool _isOn = false;
  
  void turnOn() {
    _isOn = true;
    print('💡 Işık açıldı');
  }
  
  void turnOff() {
    _isOn = false;
    print('🌑 Işık kapatıldı');
  }
  
  bool get isOn => _isOn;
}

// Işığı açma komutu
class LightOnCommand implements Command {
  Light _light;
  
  LightOnCommand(this._light);
  
  @override
  void execute() {
    _light.turnOn();
  }
  
  @override
  void undo() {
    _light.turnOff();
  }
}

// Işığı kapatma komutu
class LightOffCommand implements Command {
  Light _light;
  
  LightOffCommand(this._light);
  
  @override
  void execute() {
    _light.turnOff();
  }
  
  @override
  void undo() {
    _light.turnOn();
  }
}

// Komut yöneticisi - undo/redo için
class RemoteControl {
  List<Command> _history = [];
  int _currentIndex = -1;
  
  void executeCommand(Command command) {
    // Gelecekteki komutları temizle (yeni bir yol seçildi)
    _history = _history.sublist(0, _currentIndex + 1);
    
    command.execute();
    _history.add(command);
    _currentIndex++;
  }
  
  void undo() {
    if (_currentIndex >= 0) {
      _history[_currentIndex].undo();
      _currentIndex--;
    } else {
      print('Geri alınacak komut yok');
    }
  }
  
  void redo() {
    if (_currentIndex < _history.length - 1) {
      _currentIndex++;
      _history[_currentIndex].execute();
    } else {
      print('Tekrar yapılacak komut yok');
    }
  }
}

// Kullanımı
void main() {
  Light light = Light();
  RemoteControl remote = RemoteControl();
  
  // Işığı aç
  remote.executeCommand(LightOnCommand(light));
  // 💡 Işık açıldı
  
  // Işığı kapat
  remote.executeCommand(LightOffCommand(light));
  // 🌑 Işık kapatıldı
  
  // Geri al (undo)
  remote.undo();
  // 💡 Işık açıldı
  
  // Tekrar yap (redo)
  remote.redo();
  // 🌑 Işık kapatıldı
  
  // Tekrar geri al
  remote.undo();
  // 💡 Işık açıldı
}
```

---

## 9️⃣ Facade Pattern - Karmaşık Sistemleri Basitleştirmek

### Nedir?

Facade Pattern, karmaşık bir alt sistemi tek bir basit arayüzle kontrol etmenizi sağlar. Günlük hayattan örnek: Bir restorana gittiniz. Menüden yemek seçersiniz, sipariş verirsiniz. Ama mutfakta ne olduğunu bilmezsiniz - aşçı, yardımcı aşçı, bulaşıkçı, tedarikçi... Hepsi karmaşık bir sistem. Siz sadece garsonla (facade) konuşursunuz. Facade Pattern de böyle çalışır - karmaşık sistemleri tek bir basit arayüzle kullanırsınız.

### Neden Kullanılır?

Bazen bir işi yapmak için birden fazla sınıfı, servisi veya API'yi kullanmanız gerekir. Her seferinde hepsini ayrı ayrı çağırmak hem karmaşık hem de hataya açıktır. Facade kullanarak, tüm bu karmaşık işlemleri tek bir sınıfta toplarsınız. Kullanıcı sadece facade'un basit metodlarını çağırır, arka planda tüm karmaşık işlemler otomatik olarak yapılır.

### Nasıl Çalışır?

Facade, karmaşık alt sistemin tüm sınıflarını içerir ve onları koordine eder. Kullanıcı sadece facade'un metodlarını çağırır. Facade, bu çağrıları alt sistemdeki ilgili sınıflara yönlendirir ve gerekli sırayla işlemleri yapar. Böylece kullanıcı alt sistemin karmaşıklığından haberdar olmaz.

### Ne Zaman Kullanılır?

- Karmaşık bir alt sistemin basit bir arayüzle kullanılması gerektiğinde
- Birden fazla servisi veya API'yi koordine etmeniz gerektiğinde
- UI'yı karmaşıklıktan korumak istediğinizde
- Büyük kütüphaneleri veya framework'leri basitleştirmek istediğinizde

**Basit Örnek:**

```dart
// Karmaşık alt sistem - bilgisayar bileşenleri
class CPU {
  void start() {
    print('🖥️ CPU başlatılıyor...');
  }
  
  void execute() {
    print('⚙️ CPU çalışıyor');
  }
}

class Memory {
  void load() {
    print('💾 Bellek yükleniyor...');
  }
  
  void check() {
    print('✅ Bellek kontrol edildi');
  }
}

class HardDrive {
  void read() {
    print('💿 Disk okunuyor...');
  }
  
  void initialize() {
    print('🔧 Disk başlatıldı');
  }
}

class GraphicsCard {
  void initialize() {
    print('🎮 Ekran kartı başlatılıyor...');
  }
  
  void loadDrivers() {
    print('📦 Sürücüler yüklendi');
  }
}

// Facade - karmaşık sistemi basitleştiriyor
class ComputerFacade {
  CPU _cpu = CPU();
  Memory _memory = Memory();
  HardDrive _hardDrive = HardDrive();
  GraphicsCard _graphicsCard = GraphicsCard();
  
  // Basit metod - tüm karmaşık işlemleri yönetiyor
  void startComputer() {
    print('🚀 Bilgisayar başlatılıyor...\n');
    
    _cpu.start();
    _memory.load();
    _hardDrive.initialize();
    _graphicsCard.initialize();
    
    _hardDrive.read();
    _memory.check();
    _graphicsCard.loadDrivers();
    _cpu.execute();
    
    print('\n✅ Bilgisayar hazır!');
  }
  
  // Bilgisayarı kapatma da basit
  void shutdownComputer() {
    print('🛑 Bilgisayar kapatılıyor...');
    print('✅ Tüm işlemler sonlandırıldı');
  }
  
  // Sadece oyun modu için
  void gameMode() {
    print('🎮 Oyun modu etkinleştiriliyor...');
    _graphicsCard.initialize();
    _graphicsCard.loadDrivers();
    print('✅ Oyun modu hazır!');
  }
}

// Kullanımı - çok basit!
void main() {
  ComputerFacade computer = ComputerFacade();
  
  // Kullanıcı sadece tek bir metod çağırıyor
  // Arka planda tüm karmaşık işlemler yapılıyor
  computer.startComputer();
  
  // Çıktı:
  // 🚀 Bilgisayar başlatılıyor...
  // 🖥️ CPU başlatılıyor...
  // 💾 Bellek yükleniyor...
  // 🔧 Disk başlatıldı
  // 🎮 Ekran kartı başlatılıyor...
  // 💿 Disk okunuyor...
  // ✅ Bellek kontrol edildi
  // 📦 Sürücüler yüklendi
  // ⚙️ CPU çalışıyor
  // ✅ Bilgisayar hazır!
  
  // Oyun modu da basit
  computer.gameMode();
  
  // Kapatma da basit
  computer.shutdownComputer();
}
```

---

## 🔟 Builder Pattern - Karmaşık Nesneleri Adım Adım Oluşturmak

### Nedir?

Builder Pattern, karmaşık nesneleri adım adım oluşturmanızı sağlar. Günlük hayattan örnek: Bir ev yapıyorsunuz. Önce temel atarsınız, sonra duvarlar, sonra çatı, sonra boya... Her adımı sırayla yaparsınız. Builder Pattern de böyle çalışır - karmaşık bir nesneyi parça parça, adım adım oluşturursunuz. Her adım bir metod çağrısıdır ve sonunda `build()` çağırarak nesneyi tamamlarsınız.

### Neden Kullanılır?

Bazen bir nesne oluştururken çok fazla parametre girmeniz gerekir. Örneğin bir kullanıcı profili: isim, soyisim, email, telefon, adres, şehir, ülke, doğum tarihi, cinsiyet... Constructor'a hepsini yazmak hem okunaksız hem de hatalı olabilir. Builder kullanarak, her özelliği ayrı bir metodla ekleyebilirsiniz. Kod daha okunabilir ve esnek olur.

### Nasıl Çalışır?

Builder Pattern'de bir Builder sınıfı vardır. Bu sınıf, oluşturulacak nesnenin her özelliği için bir metod içerir. Her metod, builder'ın kendisini döndürür (method chaining), böylece metodları zincirleme çağırabilirsiniz. Son olarak `build()` metodu çağrılarak nesne oluşturulur. Flutter'da widget builder'ları da bu pattern'e benzer.

### Ne Zaman Kullanılır?

- Çok fazla parametreli constructor'lardan kaçınmak istediğinizde
- Nesne oluşturmayı daha okunabilir yapmak istediğinizde
- İsteğe bağlı parametreler çoksa
- API request'leri oluştururken
- Flutter'da dinamik widget'lar oluştururken

**Basit Örnek:**

```dart
// Oluşturulacak nesne
class User {
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final int? age;
  final String? city;
  final bool isActive;
  
  User({
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.age,
    this.city,
    this.isActive = true,
  });
  
  @override
  String toString() {
    return 'User(firstName: $firstName, lastName: $lastName, '
           'email: $email, phone: $phone, age: $age, '
           'city: $city, isActive: $isActive)';
  }
}

// Builder sınıfı
class UserBuilder {
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _phone;
  int? _age;
  String? _city;
  bool _isActive = true;
  
  // Her özellik için bir metod
  UserBuilder firstName(String firstName) {
    _firstName = firstName;
    return this; // Zincirleme çağrı için
  }
  
  UserBuilder lastName(String lastName) {
    _lastName = lastName;
    return this;
  }
  
  UserBuilder email(String email) {
    _email = email;
    return this;
  }
  
  UserBuilder phone(String phone) {
    _phone = phone;
    return this;
  }
  
  UserBuilder age(int age) {
    _age = age;
    return this;
  }
  
  UserBuilder city(String city) {
    _city = city;
    return this;
  }
  
  UserBuilder setActive(bool isActive) {
    _isActive = isActive;
    return this;
  }
  
  // Nesneyi oluştur
  User build() {
    if (_firstName == null || _lastName == null) {
      throw Exception('İsim ve soyisim zorunludur!');
    }
    
    return User(
      firstName: _firstName!,
      lastName: _lastName!,
      email: _email,
      phone: _phone,
      age: _age,
      city: _city,
      isActive: _isActive,
    );
  }
}

// Kullanımı - çok okunabilir!
void main() {
  // Basit kullanım
  User user1 = UserBuilder()
    .firstName('Ahmet')
    .lastName('Yılmaz')
    .build();
  
  print(user1);
  // User(firstName: Ahmet, lastName: Yılmaz, email: null, ...)
  
  // Daha detaylı kullanım
  User user2 = UserBuilder()
    .firstName('Ayşe')
    .lastName('Demir')
    .email('ayse@example.com')
    .phone('555-1234')
    .age(28)
    .city('İstanbul')
    .build();
  
  print(user2);
  // User(firstName: Ayşe, lastName: Demir, email: ayse@example.com, ...)
  
  // İsteğe bağlı alanları atlayabilirsiniz
  User user3 = UserBuilder()
    .firstName('Mehmet')
    .lastName('Kaya')
    .age(35)
    .setActive(false)
    .build();
  
  print(user3);
  // User(firstName: Mehmet, lastName: Kaya, age: 35, isActive: false)
  
  // Okunabilir ve esnek!
}
```

---

## 🎯 Sonuç: Design Patterns Neden Önemli?

Design patterns, yazılım geliştirmede karşılaştığınız yaygın problemlere kanıtlanmış çözümler sunar. Bunları kullanmanın birçok faydası vardır:

### 📚 Kodun Bakımı Kolaylaşır

Pattern'lar kullanıldığında, kod daha organize ve anlaşılır olur. Yeni bir geliştirici projeye katıldığında, pattern'ları tanıyorsa kodu çok daha hızlı anlar. Değişiklik yapmak gerektiğinde, pattern'lar sayesinde hangi dosyada ne yapılacağı bellidir.

### 🧪 Test Edilebilirlik Artar

Repository Pattern sayesinde gerçek API yerine sahte (mock) bir repository kullanabilirsiniz. Bu sayede testleriniz çok daha hızlı çalışır ve internet bağlantısına ihtiyaç duymaz. Observer Pattern sayesinde state değişikliklerini kolayca test edebilirsiniz.

### 🔗 Bağımlılıklar Azalır

Pattern'lar sayesinde sınıflar birbirine gevşek bağlı (loosely coupled) hale gelir. Bir sınıfı değiştirdiğinizde, diğer sınıflar etkilenmez. Bu, kodun daha esnek ve değiştirilebilir olmasını sağlar.

### 🚀 Genişletilebilir Mimari

Yeni özellikler eklemek istediğinizde, pattern'lar sayesinde mevcut kodu bozmadan ekleyebilirsiniz. Örneğin Strategy Pattern kullanıyorsanız, yeni bir strateji eklemek için sadece yeni bir sınıf yazarsınız, mevcut kod değişmez.

### 👥 Ekip İçinde Standartlaşma

Pattern'lar, ekip içinde ortak bir dil oluşturur. "Repository kullanıyoruz" dediğinizde, herkes ne kastedildiğini anlar. Bu, iletişimi kolaylaştırır ve kodun daha tutarlı olmasını sağlar.

### 🎨 Karmaşık İşleri Basitleştirir

Facade Pattern gibi pattern'lar, karmaşık sistemleri basit arayüzlerle kullanmanızı sağlar. Bu sayede kod daha okunabilir ve anlaşılır olur.

---

## 💡 Flutter'da Pratik Kullanım Önerileri

1. **Repository Pattern**: Mutlaka kullanın! Veri katmanını UI'dan ayırın.
2. **Observer Pattern**: Provider, Bloc veya Riverpod kullanıyorsanız zaten kullanıyorsunuz.
3. **Factory Pattern**: API response'larını modele dönüştürürken kullanın.
4. **Adapter Pattern**: API'den gelen veri formatı farklıysa kullanın.
5. **Singleton Pattern**: Logger, Database, Analytics gibi servisler için kullanın.
6. **Strategy Pattern**: Farklı algoritmalar arasında seçim yapmanız gerektiğinde kullanın.
7. **Builder Pattern**: Çok parametreli nesneler oluştururken kullanın.
8. **Decorator Pattern**: Widget'ları sarmalarken zaten kullanıyorsunuz (Padding, Container).
9. **Command Pattern**: Undo/Redo özelliği eklemek istediğinizde kullanın.
10. **Facade Pattern**: Karmaşık servisleri basitleştirmek için kullanın.

---

## 📖 Öğrenme Yolculuğu

Design patterns'i öğrenmek zaman alır ama değer. Başlangıçta karmaşık gelebilir, ama pratik yaptıkça daha anlaşılır hale gelir. Her pattern'i kendi projenizde deneyin, küçük örneklerle başlayın. Zamanla hangi pattern'in ne zaman kullanılacağını sezgisel olarak anlayacaksınız.

Unutmayın: Pattern'lar araçtır, amaç değil. Her zaman en basit çözümü tercih edin. Pattern kullanmak için pattern kullanmayın, gerçekten ihtiyaç olduğunda kullanın.

İyi kodlamalar! 🚀
