// for http connection
import 'package:http/http.dart' as http;
// for stdin
import 'dart:io';
import 'dart:convert';

// main function
void main() async {
  await login();
}

void search(username) async {
  stdout.write("Item to search: ");
  String? keyword = stdin.readLineSync()?.trim();
  if (keyword == null || keyword.isEmpty) {
    print("No keyword entered.");
    showMenu(username);
    return;
  }

  final url = Uri.parse(
      'http://localhost:3000/searchexpense?username=$username&keyword=$keyword');
  final response = await http.get(url);

  if (response.statusCode != 200) {
    print('Failed to search expenses!');
    showMenu(username);
    return;
  }

  final jsonResult = json.decode(response.body) as List;

  if (jsonResult.isEmpty) {
    print("No item: $keyword");
  } else {
    for (var exp in jsonResult) {
      final dt = DateTime.parse(exp['date']);
      final dtLocal = dt.toLocal();

      print(
          "${exp['id']}. ${exp['item']} : ${exp['paid']}฿ @ ${dtLocal.toString()}");
    }
  }
  showMenu(username);
}

Future<void> add(String username) async {
  // add expense
  print("===== Add new item =====");
  stdout.write("Item: ");
  String? item = stdin.readLineSync()?.trim();
  stdout.write("Paid: ");
  String? paidStr = stdin.readLineSync()?.trim();

  if (item == null || paidStr == null || item.isEmpty || paidStr.isEmpty) {
    print("Incomplete input");
    showMenu(username);
    return;
  }

  final paid = int.tryParse(paidStr);
  if (paid == null) {
    print("Paid must be a number");
    showMenu(username);
    return;
  }

  final body = {"username": username, "item": item, "paid": paid.toString()};
  final url = Uri.parse('http://localhost:3000/addexpense');

  try {
    final response = await http.post(url, body: body);
    if (response.statusCode == 200) {
      print(response.body);
    } else if (response.statusCode == 404) {
      print("User not found.");
    } else if (response.statusCode == 500) {
      print("Database server error");
    } else {
      print("Unknown error");
    }
  } catch (e) {
    print("Request failed: $e");
  }

  // loop the menu
  showMenu(username);
}


void delete(String username) async {
  print("===== Delete an item =====");
  stdout.write("Item id: ");
  String? id = stdin.readLineSync()?.trim();

  if (id == null || id.isEmpty) {
    print("Invalid id.");
    showMenu(username);
    return;
  }

  final url = Uri.parse('http://localhost:3000/deleteexpense/$id?username=$username');
  final response = await http.delete(url);

  if (response.statusCode == 200) {
    print("Deleted!");
  } else {
    print("Failed: ${response.body}");
  }

  showMenu(username);
}

// show all expense and Today's expense function
void showexpense(username, select) async {
  String text;
  if (select == 0) {
    text = "expense";
  } else {
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
