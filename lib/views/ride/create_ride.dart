import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../widgets/map.dart';

final TextEditingController createSearchController = TextEditingController();
final GlobalKey<MapPageState> _mapKey = GlobalKey<MapPageState>();

class CreateRidePage extends StatefulWidget {
  const CreateRidePage({super.key});

  @override
  State<CreateRidePage> createState() => _CreateRidePageState();
}

class _CreateRidePageState extends State<CreateRidePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  iconSize: 30,
                  onPressed: () {
                    Navigator.pushNamed(context, '/mainnav');
                  },
                  icon: Icon(LucideIcons.arrowLeft, color: Colors.blue),
                ),
                OutlinedButton.icon(
                  label: Text('Statistiques'),
                  icon: Icon(LucideIcons.chartNoAxesCombined),
                  onPressed: () {},
                 style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    side: BorderSide(
                      color: Colors.blue,
                    ),
                  ), 
                  ),
              ],
            ),
          ),
          
          Text(
                  'Créer un trajet',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue
                  ),
                ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: createSearchController,
              onChanged: (value) async{
                await _mapKey.currentState?.fetchSuggestions(value);
                setState(() {});
              },
              onSubmitted: (value) {
                _mapKey.currentState?.fetchSuggestions(value);
                
                setState(
                  () {},
                ); // this line refreshes and hides the suggestion container
              },
            
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                hintText: 'Votre destination',
                contentPadding: EdgeInsets.symmetric(vertical: 20),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(LucideIcons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
           Visibility(
            visible: _mapKey.currentState?.currentSuggestions.isEmpty ?? false,
             child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true, // take space only to fit it content
                    itemCount:
                        _mapKey.currentState?.currentSuggestions.length ?? 0,
                    itemBuilder: (context, index) {
                      final suggestion =
                          _mapKey.currentState!.currentSuggestions[index];
                      return ListTile(
                        title: Text(
                          suggestion['name'],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onTap: ()  {
                          _mapKey.currentState?.onSuggestionTap(suggestion);
                          _mapKey.currentState
                                ?.clearSuggestions(); // clear the list
                           setState((){});
                          // refresh the ui
                        },
                      );
                    },
                  ),
             ),
           ),
            

          SizedBox(height: 60),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    height: 100,
                    color: Colors.grey[300],
                    child: Center(child: Text('old active ride')),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    height: 100,
                    color: Colors.grey[300],
                    child: Center(child: Text('old active ride')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
