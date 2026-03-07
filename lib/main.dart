/*
============================================================
MAIN ENTRY POINT
============================================================

File ini adalah titik awal aplikasi Flutter.

Semua aplikasi Flutter selalu mulai dari function:

main()

Urutan eksekusinya:

Program Start
      ↓
main()
      ↓
Initialize dependencies (SQLite, service, dll)
      ↓
runApp()
      ↓
Flutter membangun Widget Tree
      ↓
UI pertama muncul
*/

import 'package:flutter/material.dart';

/*
sqflite_common_ffi digunakan untuk SQLite di Desktop.

Kenapa perlu ini?

sqflite default hanya untuk:
- Android
- iOS

Sedangkan untuk:
- Windows
- Linux
- Mac

kita harus menggunakan FFI (Foreign Function Interface)

FFI = jembatan antara Dart dan native C library
*/
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'pages/todo_page.dart';

void main() {

  /*
  ============================================================
  INITIALIZE SQLITE FOR DESKTOP
  ============================================================

  sqfliteFfiInit()

  Fungsi ini melakukan:

  1. Load SQLite native library
  2. Menghubungkan SQLite ke Dart runtime
  3. Menyiapkan database engine

  Tanpa ini database tidak bisa dibuat.

  Error yang muncul sebelumnya:
  databaseFactory not initialized
  */
  sqfliteFfiInit();


  /*
  ============================================================
  SET DATABASE FACTORY
  ============================================================

  databaseFactory adalah global variable yang dipakai
  oleh library sqflite.

  Secara default:

      databaseFactory → Android SQLite

  Di desktop kita ganti menjadi:

      databaseFactoryFfi → SQLite Desktop
  */

  databaseFactory = databaseFactoryFfi;


  /*
  ============================================================
  RUN APPLICATION
  ============================================================

  runApp()

  Fungsi ini memulai Flutter framework.

  runApp menerima ROOT WIDGET.
  Root widget kita adalah:

      MyApp()
  */

  runApp(const MyApp());
}

/*
============================================================
ROOT APPLICATION WIDGET
============================================================

Widget ini adalah root dari seluruh UI.

Semua halaman aplikasi berada di bawah widget ini.

Widget tree akan menjadi:

MyApp
   ↓
MaterialApp
   ↓
TodoPage
   ↓
Todo List UI
*/

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    /*
    MaterialApp adalah wrapper utama aplikasi.

    Fungsi utamanya:

    - Theme
    - Navigation
    - Routing
    - Localization
    - Scaffold support
    */

    return MaterialApp(

      /*
      Menghilangkan tulisan DEBUG di pojok kanan atas
      */
      debugShowCheckedModeBanner: false,

      /*
      Judul aplikasi
      */
      title: 'Todo App',

      /*
      Halaman pertama yang dibuka saat aplikasi start
      */
      home: TodoPage(),

    );
  }
}

