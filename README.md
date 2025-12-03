# Flux Note

Kişisel not alma deneyimini sade ama güçlü tutmak amacıyla let's start...

## Flux Note – Adım Adım Öğrenme Planı (MVVM → SOLID → Clean Architecture)

Bu dokümanın amacı, **sıfırdan başlayıp** projeyi şu anki haline kadar **adım adım yazarak** getirmeni sağlamak.  
Sadece burayı takip ederek:

- Flutter tarafında **MVVM** yapısını,
- **SOLID prensiplerini**,
- Basit **design pattern** yaklaşımlarını (Dependency Injection, Repository pattern, Use Case),
- Ve bunları **Clean Architecture** ile nasıl organize ettiğini


Her adımda:

- **Ne yapacağın**
- **Hangi dosyayı/klasörü oluşturacağın**
- **Kodu nereye yazacağın**
- **Neden bu şekilde yaptığın**

ayrı ayrı belirtilmiştir.

---

## 0. Hazırlık

### 0.1. Yeni Flutter projesi oluştur

- Komut satırında:

```bash
flutter create flux_note
cd flux_note
```

- IDE’de projeyi aç.

### 0.2. Varsayılan `main.dart`’ı sadeleştir

- `lib/main.dart` dosyasını aç.
- İçeriğini sil ve basit bir `MyApp` + boş bir `Scaffold` ile başla:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Flux Note'),
        ),
      ),
    );
  }
}
```

**Neden?**  
Önce en basit çalışan projeyle başlıyoruz.

---

## 1. Hafta – Basit MVVM ile Not Ekleme & Listeleme

### 1.1. Domain model: `Note` (Henüz Clean Architecture yok)

- `lib/note_model.dart` oluştur.
- İçine minimal bir model yaz:

```dart
class Note {
  final int id;
  final String title;

  Note({
    required this.id,
    required this.title,
  });
}
```

**Neden? (SOLID / SRP)**  
`Note` sınıfı sadece “veriyi” temsil ediyor. Üzerinde UI, veri tabanı, HTTP ayrıntısı yok.  
Bu, **Single Responsibility Principle**’ın en basit hali: “Notu tanımla, gerisini sonra düşün”.

### 1.2. ViewModel: `HomeViewModel` (İlk basit hali)

- `lib/home_view_model.dart` dosyasını oluştur.
- İçerisine basit bir liste ve add fonksiyonu olan `ChangeNotifier` tabanlı ViewModel yaz:

```dart
import 'package:flutter/material.dart';
import 'package:flux_note/note_model.dart';

class HomeViewModel extends ChangeNotifier {
  final List<Note> _notes = [];

  List<Note> get notes => List.unmodifiable(_notes);

  void addNote(String title) {
    final note = Note(
      id: _notes.length + 1,
      title: title,
    );
    _notes.add(note);
    notifyListeners();
  }
}
```

**Neden? (MVVM)**  
- **Model**: `Note`  
- **ViewModel**: `HomeViewModel` – UI’nın ihtiyaç duyduğu veriyi ve iş mantığını (add) yönetiyor.  
- **View** (ekran) henüz gelmedi; birazdan `HomePage` ile bağlayacağız.

### 1.3. View: `HomePage` – Basit liste ve buton

- `lib/home_page.dart` dosyası oluştur.
- İlk versiyon: sadece liste ve “+” butonuyla dialog açıp not ekleyen ekran.

```dart
import 'package:flutter/material.dart';
import 'package:flux_note/home_view_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeViewModel _homeViewModel;

  @override
  void initState() {
    super.initState();
    _homeViewModel = HomeViewModel()
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _homeViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Flux Note App')),
      body: ListView.builder(
        itemCount: _homeViewModel.notes.length,
        itemBuilder: (context, index) {
          final note = _homeViewModel.notes[index];
          return ListTile(
            title: Text(note.title),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = TextEditingController();
          final result = await showDialog<String>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add new note'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Note name',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(controller.text.trim());
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );

          if (result != null && result.isNotEmpty) {
            _homeViewModel.addNote(result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

**Neden? (MVVM + Separation of Concerns)**  
- View (`HomePage`) sadece:
  - Butona basıldığını,
  - Dialogtan dönen metni,
  - Liste çizimini biliyor.
- İş mantığı (`note` ekleme, id atama, listeyi tutma) **ViewModel**’de.

### 1.4. `main.dart`’te `HomePage`’i root yap

- `lib/main.dart` içeriğini şöyle güncelle:

```dart
import 'package:flutter/material.dart';
import 'package:flux_note/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flux Note',
      home: HomePage(),
    );
  }
}
```

**Neden?**  
Artık `HomePage`, MVVM yapısının “View” katmanı olarak kök ekranımız olsun.

> Buraya kadar olan kısım: **1. hafta** – temel MVVM, not ekleme ve listeleme.

---

## 2. Hafta – SRP, Dialog Sınıfı, Edit/Delete, Icon ve Debounce

Bu haftada odak:

- **SRP**’yi güçlendirmek,
- Tekrar eden dialog kodunu ayırmak,
- Edit & Delete eklemek,
- Aramaya **debounce** eklemek,
- UI’de ikon ve küçük review iyileştirmeleri yapmak.

### 2.1. Dialog kodunu ayrı sınıfa taşı (`app_dialog.dart`)

- `lib/app_dialog.dart` oluştur.
- İçine sadece dialog gösterme işiyle ilgilenen bir sınıf yaz:

```dart
import 'package:flutter/material.dart';

class NoteDialogs {
  static void showAddNoteDialog(
    BuildContext context,
    Function(String) onSave,
  ) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Add new note'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Note name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = controller.text.trim();
                if (title.isEmpty) return;
                onSave(title);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  static void showEditNoteDialog(
    BuildContext context,
    String currentTitle, {
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: currentTitle);
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Edit note'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Note name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = controller.text.trim();
                if (title.isEmpty) return;
                onSave(title);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
```

**Neden? (SRP)**  
- `HomePage` artık dialog detaylarını bilmek zorunda değil.
- Dialogla ilgili her şey `NoteDialogs` sınıfında toplandı → **tek sorumluluk**.

### 2.2. ViewModel’e edit & delete ekle

- `home_view_model.dart` içinde:
  - Var olan `addNote`’u koru,
  - `updateNote` ve `deleteNote` metodlarını ekle,
  - Ayrıca ileride filtreleme için `query` ve `filteredNotes` yapısını hazırlayabilirsin.

Örnek geliştirilmiş hali:

```dart
class HomeViewModel extends ChangeNotifier {
  String query = '';
  final List<Note> _notes = [];

  List<Note> get notes => List.unmodifiable(_notes);

  List<Note> get filteredNotes {
    if (query.isEmpty) return notes;
    return notes
        .where(
          (note) => note.title.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  void searchNotes(String value) {
    query = value;
    notifyListeners();
  }

  void addNote(String title) {
    final note = Note(
      id: _notes.length + 1,
      title: title,
    );
    _notes.add(note);
    notifyListeners();
  }

  void updateNote(Note updatedNote) {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();
    }
  }

  void deleteNote(int id) {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }
}
```

**Neden? (SRP + Open/Closed)**  
- ViewModel’in sorumluluğu: “UI’nın ihtiyaç duyduğu not listesini ve arama sonucunu yönetmek.”  
- Bu iş büyüdükçe yeni fonksiyonlar ekliyoruz ama View tarafında mümkün olduğunca az değişiklik yapıyoruz → **Open/Closed Principle**’a zemin.

### 2.3. HomePage: Arama barı, edit & delete ikonları

- `home_page.dart` içinde:
  - Üste bir `TextField` ile arama ekle,
  - ListTile trailing kısmına edit ve delete ikonları koy,
  - Dialogları `NoteDialogs` üzerinden çağır.

Örnek yapı:

```dart
import 'package:flutter/material.dart';
import 'package:flux_note/app_dialog.dart';
import 'package:flux_note/home_view_model.dart';
import 'package:flux_note/note_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeViewModel _homeViewModel;

  @override
  void initState() {
    super.initState();
    _homeViewModel = HomeViewModel()
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _homeViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Flux Note App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search Notes',
              ),
              onChanged: (value) {
                _homeViewModel.searchNotes(value);
              },
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: _homeViewModel.filteredNotes.isEmpty
                  ? const Center(child: Text('No notes available.'))
                  : ListView.builder(
                      itemCount: _homeViewModel.filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = _homeViewModel.filteredNotes[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                          ),
                          title: Text(note.title),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  NoteDialogs.showEditNoteDialog(
                                    context,
                                    note.title,
                                    onSave: (newTitle) {
                                      final updatedNote = Note(
                                        id: note.id,
                                        title: newTitle,
                                      );
                                      _homeViewModel.updateNote(updatedNote);
                                    },
                                  );
                                },
                                child: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              GestureDetector(
                                onTap: () {
                                  _homeViewModel.deleteNote(note.id);
                                },
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NoteDialogs.showAddNoteDialog(context, (title) {
            _homeViewModel.addNote(title);
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

**Neden? (SRP + UI Review)**  
- `HomePage` sadece ViewModel metodlarını çağırıyor, iş mantığını bilmiyor.  
- İkonların rengi, aralarındaki boşluk, padding gibi detaylar **UI review** konusu.

### 2.4. Search debounce ekle

- `home_view_model.dart` içinde:
  - `Timer` kullanarak `searchNotes`’u debounce yap.

Basit örnek:

```dart
Timer? _debounceTimer;

void searchNotes(String value) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(milliseconds: 500), () {
    query = value;
    notifyListeners();
  });
}

@override
void dispose() {
  _debounceTimer?.cancel();
  super.dispose();
}
```

**Neden? (Performance + UX)**  
- Kullanıcı her harf yazdığında filtreleme yapmak yerine,
- Kısa bir bekleme süresi sonunda (`500ms`) filtreleme yaparak:
  - Gereksiz rebuild’leri azaltır,
  - Büyük listelerde performansı iyileştirirsin.

> Buraya kadar: **2. hafta** – SRP, dialog soyutlama, edit/delete, ikonlar, debounce.

---

## 3. Hafta – Clean Architecture Refactor

Bu haftanın amacı: Var olan MVVM yapısını:

- **Domain / Data / Presentation** katmanlarına ayırmak,
- **Repository pattern + Use Case pattern**’i netleştirmek,
- `main.dart`’i **composition root** haline getirmek.

### 3.1. Klasör yapısını hazırla

- `lib/domain/entities/`
- `lib/domain/repositories/`
- `lib/domain/usecases/`
- `lib/data/datasources/`
- `lib/data/repositories/`

**Neden?**  
Fiziksel klasör yapısı, zihinsel modeli güçlendirir. “Hangi katmanda ne var?” sorusunun cevabı klasör isimlerinden okunabilmeli.

#### 🔥 Katmanların Anlamı ve Her Klasörün Görevi

Bu yapıda uygulamayı üç ana katmana bölüyorsun:

- **Domain (iş kuralları katmanı)**
- **Data (veri katmanı)**
- **Presentation (UI + ViewModel katmanı)**

Domain → Data → Presentation akışı NET şekilde ayrılır.

---

### 1️⃣ DOMAIN KATMANI

Uygulamanın beyni. Kuralların ve iş mantığının olduğu katman.  
Flutter’dan, API’den, Database’den bağımsızdır.  
Bu katmandaki hiçbir şey http, sqflite, Firebase gibi dış bağımlılık bilmez.

#### ✔ `lib/domain/entities/`

- **Ne içerir?**  
  Uygulamanın çekirdek veri modelleri.

- **Neden?**  
  - Bu modeller UI’ya ait değildir, API’ye ait değildir.  
  - Sadece uygulamanın “gerçek nesneleridir”.

- **Örnek:**  
  `NoteEntity`, `UserEntity`

- **Açıklama:**  
  Entity, uygulamanın iş anlamındaki nesnesidir. API modeli değildir, DB modeli değildir.

---

#### ✔ `lib/domain/repositories/`

- **Ne içerir?**  
  Repository arayüzleri (abstract class).

- **Neden?**  
  - Domain katmanı, verinin nereden geldiğini bilmez: API mi, SQFlite mı, Cache mi?  
  - Sadece veriyi ister.  
  - “Nasıl geleceğini” belirleyen Data katmanıdır.

- **Örnek:**

```dart
abstract class NoteRepository {
  Future<List<NoteEntity>> getNotes();
}
```

- **Açıklama:**  
  Bu sadece arayüzdür, implementasyonu Data katmanındadır.

---

#### ✔ `lib/domain/usecases/`

- **Ne içerir?**  
  Uygulamanın iş kurallarını çalıştıran sınıflar.

- **Neden?**  
  - “Bir işlem = bir use case”  
  - Örneğin: “Notu kaydet”, “Notu getir”, “Kullanıcıyı giriş yaptır”.

- **Örnek:**

```dart
class GetNotes {
  final NoteRepository repository;

  GetNotes(this.repository);

  Future<List<NoteEntity>> call() {
    return repository.getNotes();
  }
}
```

- **Açıklama:**  
  ViewModel, iş yapmak istediğinde Use Case çağırır, repository ile direkt konuşmaz.

---

### 2️⃣ DATA KATMANI

Domain’in istediği veriyi gerçek kaynaklardan temin eden katman.  
Bu katman:

- API’yi bilir
- Database’i bilir
- Cache’i bilir

#### ✔ `lib/data/datasources/`

- **Ne içerir?**  
  Gerçek veri sağlayıcıları:
  - RemoteDataSource (API)
  - LocalDataSource (cache, database, shared prefs)

- **Örnek:**

```dart
abstract class NoteRemoteDataSource {
  Future<List<NoteModel>> fetchNotes();
}
```

- **Açıklama:**  
  DataSource = veri kaynağına direkt giden yer (repository burayı kullanır).

---

#### ✔ `lib/data/repositories/`

- **Ne içerir?**  
  Domain’deki Repository arayüzlerinin implementasyonları.

- **Neden?**  
  - Domain’deki repository “ne” yapılacağını söyler.  
  - Data’daki repository “nasıl” yapılacağını çözer.

- **Örnek:**

```dart
class NoteRepositoryImpl implements NoteRepository {
  final NoteRemoteDataSource remote;

  NoteRepositoryImpl(this.remote);

  @override
  Future<List<NoteEntity>> getNotes() async {
    final models = await remote.fetchNotes();
    return models.map((m) => m.toEntity()).toList();
  }
}
```

- **Açıklama:**  
  - DataSource’tan aldığı modeli Entity’ye çevirir.  
  - Böylece Domain katmanı API modelini bilmez.

---

### 3️⃣ PRESENTATION KATMANI

MVVM’in olduğu katman. UI + ViewModel + State burada.  
Bu katman:

- Domain’den Use Case çağırır
- Data’yı UI logic’e dönüştürür
- Widget’ları içerir

**Tipik klasör yapısı:** `lib/presentation/...`  
(Bu projede doğrudan `lib/` altında ama mantık aynı.)

---

### 🎯 `main.dart` = Composition Root

- **Neden önemli?**  
  Tüm bağımlılıkların toplandığı, enjeksiyonların yapıldığı yerdir.

- **Örnek olarak:**

```dart
void main() {
  final remote = NoteRemoteDataSourceImpl();
  final repository = NoteRepositoryImpl(remote);
  final getNotes = GetNotes(repository);

  runApp(MyApp(getNotes: getNotes));
}
```

- **Açıklama:**  
  Her şey burada bir araya gelir → app launch edilir.  
  Bu sayede:
  - Dependency Injection temelli,  
  - Test edilebilir,  
  - Katmanları net ayrılmış bir mimari oluşur.

---

### 🔥 Kısaca Özet Tablo

| Klasör / Dosya           | Ne İçindir?                                       |
|--------------------------|---------------------------------------------------|
| `domain/entities`        | Uygulamanın “iş” anlamındaki model sınıfları     |
| `domain/repositories`    | Repository arayüzleri (soyutlama)                |
| `domain/usecases`        | İş kuralları / fonksiyonel işlemler              |
| `data/datasources`       | API / DB / Cache erişimleri                       |
| `data/repositories`      | Domain arayüzlerinin implementasyonları          |
| `presentation/`          | UI katmanı + ViewModel’ler                        |
| `main.dart`              | Dependency injection – composition root           |

### 3.2. `Note` entity’sini domain’e taşı

- `lib/domain/entities/note.dart` oluştur:

```dart
class Note {
  final int id;
  final String title;

  Note({
    required this.id,
    required this.title,
  });

  Note copyWith({
    int? id,
    String? title,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }
}
```

- `lib/note_model.dart`’ı “geçit” haline getir:

```dart
export 'domain/entities/note.dart';
```

**Neden? (Clean Architecture + Geriye Dönük Uyumluluk)**  
- Entity, domain katmanına taşındı → “Not nedir?” sorusunun cevabı artık domain’de.  
- Eski kodda `import 'package:flux_note/note_model.dart';` yazdığın yerler bozulmasın diye `note_model.dart` sadece export eden bir köprü oldu.

### 3.3. Domain Repository arayüzü

- `lib/domain/repositories/note_repository.dart`:

```dart
import 'package:flux_note/domain/entities/note.dart';

abstract class NoteRepository {
  List<Note> getNotes();
  void addNote(Note note);
  void updateNote(Note note);
  void deleteNote(int id);
}
```

**Neden? (Dependency Inversion)**  
- Üst seviye (domain) katman, **somut sınıflara değil** soyutlamalara (interface/abstract class) bağlı.  
- Data katmanı bu arayüzü implemente ederek domain’e uyum sağlıyor.

### 3.4. Use case sınıfları

- `lib/domain/usecases/get_notes.dart`
- `lib/domain/usecases/add_note.dart`
- `lib/domain/usecases/update_note.dart`
- `lib/domain/usecases/delete_note.dart`

Örneğin `get_notes.dart`:

```dart
import 'package:flux_note/domain/entities/note.dart';
import 'package:flux_note/domain/repositories/note_repository.dart';

class GetNotes {
  final NoteRepository repository;

  GetNotes(this.repository);

  List<Note> call() {
    return repository.getNotes();
  }
}
```

Diğerleri benzer şekilde repository çağırıyor.

**Neden? (Use Case pattern)**  
- İş kurallarını fonksiyon fonksiyon ayırdık:
  - “Notları getir” = `GetNotes`
  - “Not ekle” = `AddNote`
  - vb.
- ViewModel bu sınıfları kullanarak işini yapar; data detayını bilmez.

### 3.5. Data Source ve Repository implementasyonu

- `lib/data/datasources/in_memory_note_data_source.dart`:

```dart
import 'package:flux_note/domain/entities/note.dart';

class InMemoryNoteDataSource {
  final List<Note> _notes = [];

  List<Note> getNotes() => List.unmodifiable(_notes);

  void addNote(Note note) {
    _notes.add(note);
  }

  void updateNote(Note note) {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
    }
  }

  void deleteNote(int id) {
    _notes.removeWhere((n) => n.id == id);
  }
}
```

- `lib/data/repositories/note_repository_impl.dart`:

```dart
import 'package:flux_note/data/datasources/in_memory_note_data_source.dart';
import 'package:flux_note/domain/entities/note.dart';
import 'package:flux_note/domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final InMemoryNoteDataSource dataSource;

  NoteRepositoryImpl(this.dataSource);

  @override
  List<Note> getNotes() {
    return dataSource.getNotes();
  }

  @override
  void addNote(Note note) {
    dataSource.addNote(note);
  }

  @override
  void updateNote(Note note) {
    dataSource.updateNote(note);
  }

  @override
  void deleteNote(int id) {
    dataSource.deleteNote(id);
  }
}
```

**Neden? (Repository pattern)**  
- `NoteRepositoryImpl`, domain’in istediği `NoteRepository`’yi, somut `InMemoryNoteDataSource` ile birleştiriyor.  
- Yarın `SqliteNoteDataSource` yazarsan, sadece bu implementasyonu değiştirirsin.

### 3.6. HomeViewModel’i use case’lerle çalışır hale getir

- `lib/home_view_model.dart`’ı domain/usecase’leri kullanacak şekilde refactor et:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flux_note/domain/entities/note.dart';
import 'package:flux_note/domain/usecases/add_note.dart';
import 'package:flux_note/domain/usecases/delete_note.dart';
import 'package:flux_note/domain/usecases/get_notes.dart';
import 'package:flux_note/domain/usecases/update_note.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required GetNotes getNotes,
    required AddNote addNote,
    required UpdateNote updateNote,
    required DeleteNote deleteNote,
  })  : _getNotes = getNotes,
        _addNote = addNote,
        _updateNote = updateNote,
        _deleteNote = deleteNote {
    _loadNotes();
  }

  final GetNotes _getNotes;
  final AddNote _addNote;
  final UpdateNote _updateNote;
  final DeleteNote _deleteNote;

  String query = '';
  Timer? _debounceTimer;
  List<Note> _notes = [];

  List<Note> get notes => List.unmodifiable(_notes);

  List<Note> get filteredNotes {
    if (query.isEmpty) {
      return notes;
    } else {
      return notes
          .where(
            (note) => note.title.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }

  void _loadNotes() {
    _notes = _getNotes();
    notifyListeners();
  }

  void searchNotes(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      query = value;
      notifyListeners();
    });
  }

  void addNote(Note note) {
    _addNote(note);
    _loadNotes();
  }

  void updateNote(Note updatedNote) {
    _updateNote(updatedNote);
    _loadNotes();
  }

  void deleteNote(int id) {
    _deleteNote(id);
    _loadNotes();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
```

**Neden? (MVVM + Clean Architecture)**  
- ViewModel artık:
  - “Notu nasıl saklayacağını” değil,
  - “Hangi use case’i çağıracağını” biliyor.
- Bu sayede domain + data katmanını değiştirmek ViewModel’i etkilemez.

### 3.7. HomePage’i DI ile ViewModel alan hale getir (widget.homeViewModel)

- `lib/home_page.dart`’ı, ViewModel’i dışarıdan alan yapıya çevir:

```dart
import 'package:flutter/material.dart';
import 'package:flux_note/app_dialog.dart';
import 'package:flux_note/home_view_model.dart';
import 'package:flux_note/note_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.homeViewModel,
  });

  final HomeViewModel homeViewModel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeViewModel get _homeViewModel => widget.homeViewModel;

  @override
  Widget build(BuildContext context) {
    // Buradan sonrası önceki UI ile aynı (arama, liste, ikonlar vs.)
    // Sadece _homeViewModel kullanıyorsun.
    // ...
    return Scaffold(
      appBar: AppBar(title: const Text('My Flux Note App')),
      // body, floatingActionButton vs. önceki gibi ama _homeViewModel ile
    );
  }
}
```

**Neden? (Dependency Injection)**  
- `HomePage` kendi ViewModel’ini **oluşturmuyor**; dışarıdan alıyor.  
- Bu, test yazarken veya farklı mock ViewModel vermek istediğinde büyük kolaylık.

`widget` konusu:  
- `_HomePageState` içinde `widget`, bağlı olduğu `HomePage` örneğini temsil eder.  
- `widget.homeViewModel` = `HomePage`’in constructor’dan aldığı ViewModel.  
- Getter ile kısalttık: `HomeViewModel get _homeViewModel => widget.homeViewModel;`

### 3.8. `main.dart`’i composition root yap

- `lib/main.dart`’i tüm bağımlılıkların kurulduğu yer haline getir:

```dart
import 'package:flutter/material.dart';
import 'package:flux_note/data/datasources/in_memory_note_data_source.dart';
import 'package:flux_note/data/repositories/note_repository_impl.dart';
import 'package:flux_note/domain/usecases/add_note.dart';
import 'package:flux_note/domain/usecases/delete_note.dart';
import 'package:flux_note/domain/usecases/get_notes.dart';
import 'package:flux_note/domain/usecases/update_note.dart';
import 'package:flux_note/home_page.dart';
import 'package:flux_note/home_view_model.dart';

void main() {
  // Composition root: Tüm bağımlılıklar burada üretiliyor.
  final dataSource = InMemoryNoteDataSource();
  final repository = NoteRepositoryImpl(dataSource);

  final getNotes = GetNotes(repository);
  final addNote = AddNote(repository);
  final updateNote = UpdateNote(repository);
  final deleteNote = DeleteNote(repository);

  final homeViewModel = HomeViewModel(
    getNotes: getNotes,
    addNote: addNote,
    updateNote: updateNote,
    deleteNote: deleteNote,
  );

  runApp(MyApp(
    homeViewModel: homeViewModel,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.homeViewModel,
  });

  final HomeViewModel homeViewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flux Note',
      home: HomePage(
        homeViewModel: homeViewModel,
      ),
    );
  }
}
```

**Neden? (Composition Root + DI)**  
- Tüm zinciri burada kuruyorsun:
  - DataSource → Repository → Use Case’ler → ViewModel → HomePage  
- Böylece diğer katmanlar sadece kendi işlerini yapıyor; hiçbir ekran içinde “yeni repo yaratma” vs. yok.

---

## Sonuç

Bu `learn.md`’yi ders akışında şöyle kullanabilirsin:

1. **1. Hafta**
   - Projeyi oluştur (`flutter create`),
   - `Note`, `HomeViewModel`, `HomePage`, `main.dart` ile **temel MVVM** kur,
   - Not ekleme + listelemeyi çalışır hale getir.
2. **2. Hafta**
   - `NoteDialogs` ile dialogları ayır (SRP),
   - Edit & delete fonksiyonları,
   - Search + debounce,
   - UI/ikon düzenlemeleri (review).
3. **3. Hafta**
   - Domain/Data klasörlerini oluştur,
   - Entity’yi domain’e taşı, repository arayüzü + use case’leri ekle,
   - DataSource + Repository implementasyonu yaz,
   - `HomeViewModel`’i use case’lere bağla,48
   - `HomePage`’i DI ile ViewModel alan hale getir,
   - `main.dart`’i composition root’a çevir.

Sadece bu dosyayı takip ederek basit bir projeyi **sıfırdan bu son Clean Architecture haline** kadar adım adım oluşturabilir ve her adımda SOLID/MVVM/Clean Architecture bağlantısını görebilirsin.
