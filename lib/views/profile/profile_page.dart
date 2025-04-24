import 'package:carpooling/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import '../../components/container.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GreyContainer(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/images/OIP.jfif'),
                        
                      ),
                      SizedBox(width: 20),
                  
                      Expanded(
                        child: Text(
                        'Mustapha Himoun',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                       ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(10.0),
              child:  GreyContainer(
                child:  Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(//date de naissance
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date de naissance',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'dd/mm/yyyy',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w200,
                                color: const Color.fromARGB(255, 85, 85, 85)
                              ),
                            ),      
                          ],
                        ),
                      ),

                      SizedBox(height: 15), // spacing between infos elements

                      Container(//Email
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'exemple@gmail.com',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w200,
                                color: const Color.fromARGB(255, 85, 85, 85)
                              ),
                            ),      
                          ],
                        ),                    
                      ),

                      SizedBox(height: 15), // spacing between infos elements

                      Container(// numero tel
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Numero de téléphone',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'xxxx xxx xxx',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w200,
                                color: const Color.fromARGB(255, 85, 85, 85)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ),
              ) 
            ),

            SizedBox(height: 20), // spacing between infos nd logout button

            Container(

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 22,
                    backgroundColor: Colors.red,
                  ),
                  
                )
                ),
            )
          ],
        );
  }}
        /*,
        
      

      
    );
  }
}*/