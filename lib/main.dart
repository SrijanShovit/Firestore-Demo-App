import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {

  //creating stream to hear  collection
  //creating an instance of it
  //taking data from users collection
  final Stream<QuerySnapshot> users = FirebaseFirestore.instance.collection('users').snapshots();
  //taking snapshots method to return snapshot

  @override

  //Notes:
  //1. FirebaseFirestore : entry point to access Firestore for Flutter App
  //2.  .instance : A getter that returns an instance of a single Firebase App using default Firebase App
  //3.  .collection()  : A method to get a CollectionReference for the specified Firestore path(here it is users
  // collection).It can be used for adding & getting document references , and querying for document
  //4.  .snapshots()  :  A method to generate a stream of QuerySnapshot that notifies of query results at this location
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cloud Firestore Demo'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Read Data from Cloud Firestore',
              style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),
              Container(
                height: 250,
              padding: EdgeInsets.symmetric(vertical: 20),
              //using StreamBuilder to listen to data in our database
              child: StreamBuilder<QuerySnapshot>(
                stream: users,
                builder: (
                    BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot){
                  //checking for error in Snapshot before using data
                  if (snapshot.hasError){
                    return Text('Something went wrong');
                  };
                  //checking connection state of snapshot
                  if (snapshot.connectionState == ConnectionState.waiting){
                        return Text('Loading');
                  }
                  //using data if these 2 conditions get passed
                  final data = snapshot.requireData;   //taking data from Snapshot

                  //returning ListViewBuilder to use data coming from database
                  return ListView.builder(
                  itemCount : data.size,       //size of document is no of items
                    itemBuilder: (context,index){
                    //itemBuilder will return a String
                      return Text('My name is ${data.docs[index]['name']} and I am ${data.docs[index]['age']}');
                    },
                  );
                }
                ),
              ),
              Text(
                'Write data to cloud firestore',
                style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),
              ),
              MyCustomForm()
            ],
          ),
        ),
      ),
    );
  }
}


//NOTES 2
// 1.  StreamBuilder -> A widget that builds itself based on the latest snapshot of interaction with the specified stream
//and whose build strategy is given by its builder

//2.  QuerySnapshot ->  An object that contains the results of a query , which are zero or more DocumentSnapshot objects

//3. AsyncSnapshot  ->  An immutable representation of the most recent interaction with an asynchronous computation

//4.  .requireData()  ->  A getter that returns latest data received. It fails if there is no data.

//5.   .size()  -> A getter that returns the size(number of documents) of this snapshot

//6.  docs[index]  -> '.docs' gets a list of all the documents in this snapshot;
// '[index]' returns one single document

class MyCustomForm extends StatefulWidget {

  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm> {

  final _formKey = GlobalKey<FormState>();

  var name = '';
  var age = 0;

  @override
  Widget build(BuildContext context) {

    //writing data to Firestore

    // creating a variable
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.person),
              hintText: 'What is your name?',
                labelText: 'Name',
            ),
            onChanged: (value) {
              name = value;
            },
              validator: (value){
                if (value == null || value.isEmpty){
                  return 'Please enter some text';
                }
                return null;

            },
          ),

          TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.date_range),
              hintText: 'What is your age?',
                labelText: 'Age',
            ),
            onChanged: (value) {
              age = int.parse(value);
            },
            validator: (value){
              if (value == null || value.isEmpty){
                return 'Please enter some text';
              }
              return null;

            },
          ),


          SizedBox(height: 10,),

          Center(
          child: ElevatedButton(
            onPressed: (){
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Sending data to Cloud Firestore'),
                  ),
                );

                //submitting data when button is pressed
                //using CollectionReference Variable
                users.add(
                    {'name' : name , 'age' : age})
                //waiting user to get added and then taking action
                    .then((value) => print('User Added'))
                .catchError((error) => print('Failed $error'));

              }
            },
            child:Text('Submit'),
          ),
          )

        ],
      ),

    );
  }
}
