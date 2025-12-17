# Tentang OnlineFinder

OnlineFinder adalah sebuah [mesin pencari meta], yang mendapatkan hasil dari
{{link('mesin pencari', 'preferences')}} lainnya sambil tidak melacak
penggunanya.

Proyek OnlineFinder diarahkan oleh sebuah komunitas terbuka, bergabung dengan kami di
Matrix jika Anda memiliki pertanyaan atau ingin mengobrol tentang OnlineFinder di
[#onlinefinder:matrix.org]

Buat OnlineFinder lebih baik.

- Anda dapat membuat terjemahan OnlineFinder lebih baik di [Weblate], atau...
- Lacak pengembangan, kirim kontribusi, dan laporkan masalah di [sumber
  OnlineFinder].
- Untuk mendapatkan informasi lanjut, kunjungi dokumentasi proyek OnlineFinder di
  [dokumentasi OnlineFinder].

## Kenapa menggunakan OnlineFinder?

- OnlineFinder mungkin tidak menawarkan Anda hasil yang dipersonalisasikan seperti
  Google, tetapi tidak membuat sebuah profil tentang Anda.
- OnlineFinder tidak peduli apa yang Anda cari, tidak akan membagikan apa pun dengan
  pihak ketiga, dan tidak dapat digunakan untuk mengkompromikan Anda.
- OnlineFinder adalah perangkat lunak bebas, kodenya 100% terbuka, dan semuanya
  dipersilakan untuk membuatnya lebih baik.

Jika Anda peduli dengan privasi, ingin menjadi pengguna yang sadar, ataupun
percaya dalam kebebasan digital, buat OnlineFinder sebagai mesin pencari bawaan atau
jalankan di server Anda sendiri!

## Bagaimana saya dapat membuat OnlineFinder sebagai mesin pencari bawaan?

OnlineFinder mendukung [OpenSearch].  Untuk informasi lanjut tentang mengubah mesin
pencari bawaan Anda, lihat dokumentasi peramban Anda:

- [Firefox]
- [Microsoft Edge] - Dibalik tautan, Anda juga akan menemukan beberapa instruksi
  berguna untuk Chrome dan Safari.
- Peramban berbasis [Chromium] hanya menambahkan situs web yang dikunjungi oleh
  pengguna tanpa sebuah jalur.

Apabila menambahkan mesin pencari, tidak boleh ada duplikat dengan nama yang
sama.  Jika Anda menemukan masalah di mana Anda tidak bisa menambahkan mesin
pencari, Anda bisa:

- menghapus duplikat (nama default: OnlineFinder) atau
- menghubungi pemilik untuk memberikan nama yang berbeda dari nama default.

## Bagaimana caranya OnlineFinder bekerja?

OnlineFinder adalah sebuah *fork* dari [mesin pencari meta] [olf] yang banyak
dikenal yang diinspirasi oleh [proyek Seeks].  OnlineFinder menyediakan privasi dasar
dengan mencampur kueri Anda dengan pencarian pada *platform* lainnya tanpa
menyimpan data pencarian.  OnlineFinder dapat ditambahkan ke bilah pencarian peramban
Anda; lain lagi, OnlineFinder dapat diatur sebagai mesin pencarian bawaan.

{{link('Laman statistik', 'stats')}} berisi beberapa statistik penggunaan anonim
berguna tentang mesin pencarian yang digunakan.

## Bagaimana caranya untuk membuat OnlineFinder milik saya?

OnlineFinder menghargai kekhawatiran Anda tentang pencatatan (*log*), jadi ambil
kodenya dari [sumber OnlineFinder] dan jalankan sendiri!

Tambahkan instansi Anda ke [daftar instansi
publik]({{get_setting('brand.public_instances')}}) ini untuk membantu orang lain
mendapatkan kembali privasi mereka dan membuat internet lebih bebas.  Lebih
terdesentralisasinya internet, lebih banyak kebebasan yang kita punya!


[sumber OnlineFinder]: {{GIT_URL}}
[#onlinefinder:matrix.org]: https://matrix.to/#/#onlinefinder:matrix.org
[dokumentasi OnlineFinder]: {{get_setting('brand.docs_url')}}
[olf]: https://github.com/olf/olf
[mesin pencari meta]: https://id.wikipedia.org/wiki/Mesin_pencari_web#Mesin_Pencari_dan_Mesin_Pencari-meta
[Weblate]: https://translate.codeberg.org/projects/onlinefinder/
[proyek Seeks]: https://beniz.github.io/seeks/
[OpenSearch]: https://github.com/dewitt/opensearch/blob/master/opensearch-1-1-draft-6.md
[Firefox]: https://support.mozilla.org/id/kb/add-or-remove-search-engine-firefox
[Microsoft Edge]: https://support.microsoft.com/id-id/microsoft-edge/ubah-mesin-pencarian-default-anda-f863c519-5994-a8ed-6859-00fbc123b782
[Chromium]: https://www.chromium.org/tab-to-search
