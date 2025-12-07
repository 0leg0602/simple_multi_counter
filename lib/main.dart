// ignore_for_file: non_constant_identifier_names



import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
late SharedPreferences prefs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  prefs = await SharedPreferences.getInstance();
  runApp(MyApp());
}

// void main() {
//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  List<Counter> counters = [];

  final String? prefs_json = prefs.getString("counters");

  void change_counter(Counter counter, int value) {
    setState(() {
      counter.count += value;
    });
    save_data();
  }

  void change_counter_name(Counter counter, String new_name) {
    setState(() {
      counter.name = new_name;
    });
    save_data();
  }

  void change_counter_count(Counter counter, String new_value) {
    setState(() {
      int? int_count = int.tryParse(new_value);
      if (int_count != null) {
        counter.count = int_count;
      }
    });
    save_data();
  }

  void delete_counter(Counter counter){
    setState(() {
      counters.remove(counter);
    });
    save_data();
  }

  void _add_new_counter() {
    setState(() {
      counters.add(Counter());
    });
    save_data();
  }

  void save_data() {
      // Convert the List<Counter> to a List<Map<String, dynamic>>
    List<Map<String, dynamic>> jsonList = counters.map((c) => c.toJson()).toList();
    
    // Encode the List of Maps into a single JSON string
    String counters_json = jsonEncode(jsonList);
    
    prefs.setString("counters", counters_json);
  }

  @override
  Widget build(BuildContext context) {
    if (counters.isEmpty){
      if (prefs_json != null){
        String prefs_json_str = prefs_json!;
        List<dynamic> jsonList = jsonDecode(prefs_json_str);
        
        // Convert the List of Maps into a List of Counter objects
        setState(() {
          counters = jsonList.map((jsonMap) => Counter.fromJson(jsonMap as Map<String, dynamic>)).toList();
        });
      }
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text("Counter"),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: SizedBox(
        width: .maxFinite,
        child: Wrap(
          alignment: .spaceEvenly,
          children: [
            for (Counter counter in counters) Card(
                elevation: 4.0,
                child: Column(
                  children: [
                    Text(counter.name),
                    Row(
                      mainAxisSize: .min,
                      children: [
                        // SizedBox(width: 48,),
                        IconButton.outlined(onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Settings"),
                                content: Column(
                                  mainAxisAlignment: .center,
                                  mainAxisSize: .min,
                                  children: [
                                    Row(
                                      children: [
                                        Text("name: "),
                                        Expanded(child: ExcludeSemantics(child: TextFormField(initialValue: counter.name, onFieldSubmitted: (String new_val) {change_counter_name(counter, new_val);}, cursorOpacityAnimates: false,))), 
                                        // Expanded(child: TextFormField(initialValue: counter.name, onFieldSubmitted: (String new_val) {change_counter_name(counter, new_val);}, cursorOpacityAnimates: false,)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text("count: "),
                                        Expanded(child: ExcludeSemantics(child: TextFormField(initialValue: "${counter.count}", onFieldSubmitted: (String? new_val) {change_counter_count(counter, new_val!);}, cursorOpacityAnimates: false,))),

                                      ],
                                    ),
                                    Divider(),
                                    ElevatedButton(onPressed: () {Navigator.pop(context);}, child: Text("CLOSE")),
                                    Divider(),
                                    ElevatedButton(onPressed: () {delete_counter(counter); Navigator.pop(context);}, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: Text("DELETE"),),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                         icon: Icon(Icons.settings)),
                        Text("${counter.count}", style: TextStyle(fontSize: 60),),
                        Column(
                          children: [
                            IconButton.outlined(onPressed: () {change_counter(counter, 1);}, icon: Icon(Icons.arrow_drop_up)),
                            IconButton.outlined(onPressed: () {change_counter(counter, -1);}, icon: Icon(Icons.arrow_drop_down)),
                          ],
                        )
                      ],
                    )
                  ],
                ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add_new_counter,
        child: Icon(Icons.add),
      ),

    );
  }
}

class Counter {
    int count = 0;
    String name = "counter";

    Counter({this.count = 0, this.name = "counter"});

    Map<String, dynamic> toJson() => {
        'count': count,
        'name': name,
      };

  // 2. Deserialization (from JSON Map)
    factory Counter.fromJson(Map<String, dynamic> json) {
      return Counter(
        count: json['count'] as int,
        name: json['name'] as String,
      );
    }
}
