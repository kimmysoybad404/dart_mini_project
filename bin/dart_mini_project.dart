// for http connection
import 'package:http/http.dart' as http;
// for stdin
import 'dart:io';
import 'dart:convert';

// main function
void main() async {
  await login();
}

void search(username){
  // search expense

  // loop the menu
  showMenu(username);
}

void add(username){
  // add expense

  // loop the menu
  showMenu(username);
}

void delete(username){
  // delete an expense

  // loop the menu
  showMenu(username);
}

// show all expense and Today's expense function 
void showexpense(username, select) async {
  String text;
  if(select == 0){
    text = "expense";
  }else{
    text = "todayexpense";
  }

  final url = Uri.parse('http://localhost:3000/$text?username=$username');
        final response = await http.get(url);
        if (response.statusCode != 200) {
          print('Failed to retrieve the http package!');
          return;
        }
        // the body is JSON string
        final jsonResult = json.decode(response.body) as List;

        int total = 0;
        List topics = ["All expenses", "Today's expenses"];
        final topic = topics[select];
        print("------------- $topic ----------");
        for (var exp in jsonResult) {
          final dt = DateTime.parse(exp['date']);
          final dtLocal = dt.toLocal();

          print(
            "${exp['id']}. ${exp['item']} : ${exp['paid']}฿ @ ${dtLocal.toString()}",
          );

          total += exp['paid'] as int;
        }
        print("Total expenses = $total฿");
        showMenu(username);
}

// menu function
void showMenu(username) {
  print(
    "========== Expense Tracking App ==========\n"
    "Welcome $username\n"
    "1. All expenses\n"
    "2. Today's expense\n"
    "3. Search expense\n"
    "4. Add new expense\n"
    "5. Delete an expense\n"
    "6. Exit",
  );

  stdout.write("Choose... ");
  String? choice = stdin.readLineSync()?.trim();

  if (choice != null) {
    switch (choice) {
      case '1':
        showexpense(username, 0);
        break;
      case '2':
        showexpense(username, 1);
        break;
      case '3':
        search(username);
        break;
      case '4':
        add(username);
        break;
      case '5':
        delete(username);
        break;
      case '6':
        print("----- Bye -----");
        break;
      default:
        print("Invalid choice.");
        showMenu(username);
        break;
    }
  } else {
    print("No input received.");
    showMenu(username);
  }
}

//login function
Future<void> login() async {
  print("===== Login =====");
  // Get username and password
  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();
  if (username == null || password == null) {
    print("Incomplete input");
    return;
  }

  final body = {"username": username, "password": password};
  final url = Uri.parse('http://localhost:3000/login');
  final response = await http.post(url, body: body);
  // note: if body is Map, it is encoded by "application/x-www-form-urlencoded" not JSON
  if (response.statusCode == 200) {
    showMenu(username);
  } else if (response.statusCode == 401 || response.statusCode == 500) {
    final result = response.body;
    print(result);
  } else {
    print("Unknown error");
  }
}

Future<void> register() async {
  print("===== Registration =====");
  // Get username and password
  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();
  if (username == null || password == null) {
    print("Incomplete input");
    return;
  }

  final body = {"username": username, "password": password};
  final url = Uri.parse('http://localhost:3000/register');
  final response = await http.post(url, body: body);
  // note: if body is Map, it is encoded by "application/x-www-form-urlencoded" not JSON
  if (response.statusCode == 201) {
    // the response.body is String
    final result = response.body;
    print(result);
  } else if (response.statusCode == 409 || response.statusCode == 500) {
    final result = response.body;
    print(result);
  } else {
    print("Unknown error");
  }
}
