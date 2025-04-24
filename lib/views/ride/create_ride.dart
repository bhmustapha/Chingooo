import 'package:flutter/material.dart';

class CreateRidePage extends StatefulWidget {
  const CreateRidePage({super.key});

  @override
  State<CreateRidePage> createState() => _CreateRidePageState();
}

class _CreateRidePageState extends State<CreateRidePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Creer un trajet!'),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.bar_chart))
        ],
        
      ),
      body:Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: TextField(
                              textAlign: TextAlign.start,
                              
                              decoration: InputDecoration(
                                
                                contentPadding: EdgeInsets.symmetric(vertical: 20),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey,
                                  ),
                                hintText: 'win rk ray7',
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w200,
                                  color: Colors.grey
                                ),
                                border: OutlineInputBorder(
                                  
                                )
                                          
                                )
                              
                            ),
          ),
          SizedBox(height: 80,),
          ListView(
            children: [
              Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              height: 100,
              color: Colors.grey,
              child: Center(child: Text('old active ride')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              height: 100,
              color: Colors.grey,
              child: Center(child: Text('old active ride')),
            ),
          ),
            ],
          )
        ],
      )
    );
  }
}