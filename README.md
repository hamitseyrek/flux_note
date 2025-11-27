# Flux Note

Kişisel not alma deneyimini sade ama güçlü tutmak amacıyla Flutter ile geliştirilen bir MVVM örnek projesi.

## 1. Hafta – MVVM ve Not İşlevleri

1. **MVVM mantığında kod yapısı**  
   `HomePage` yalnızca UI render ediyor, `HomeViewModel` arama sorgusu ve note listesini yönetiyor, `Note` modeli ise veriyi temsil ediyor. UI ve durum yönetimi basitçe ayrılmış durumda.

2. **Not oluşturma**  
   Kullanıcılar sadece başlık girerek not ekleyebiliyor. Dialogdan gelen metin `HomeViewModel.addNote` metodu ile bellekte tutulan diziye ekleniyor; henüz kalıcı depolama bulunmuyor.

3. **Not arama**  
   Arama kutusu `HomeViewModel.searchNotes` metodunu çağırıyor ve sorgu yalnızca başlık alanını `contains` ile filtreliyor. Sonuç, `filteredNotes` getter’ı üzerinden anında UI’a yansıyor.

4. **Not listeleme**  
   `ListView.builder`, ViewModel’in tuttuğu not dizisini gösteriyor; boş durumda kullanıcıya bilgi veriliyor. Stream/async yapı henüz yok, tamamen in-memory veri üzerinden ilerliyor.

5. **Note modeli**  
   `lib/note_model.dart` içinde `id` ve `title` alanlarına sahip minimal bir sınıf var. İçerik/zaman damgası gibi alanlar ve JSON serileştirme bu aşamada eklenmedi.

6. **Create note dialog**  
   `NoteDialogs.showAddNoteDialog`, yalnızca başlık alanı olan bir `AlertDialog` açıyor. Boş değerler engellenip ViewModel’e paslanıyor; kaydın ardından liste yeniden çiziliyor.


