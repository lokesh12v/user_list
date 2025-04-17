// main.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Search App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const UserListScreen(),
    );
  }
}

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Pagination variables
  int currentPage = 1;
  int totalPages = 0;
  int totalUsers = 0;
  int perPage = 0;

  @override
  void initState() {
    super.initState();
    fetchUsers(currentPage);
  }

  Future<void> fetchUsers(int page) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://reqres.in/api/users?page=$page'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          users = data['data'];
          filteredUsers = users;
          isLoading = false;
          
          // Update pagination info
          currentPage = data['page'];
          totalPages = data['total_pages'];
          totalUsers = data['total'];
          perPage = data['per_page'];
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackBar('Failed to load users. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void filterUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredUsers = users;
      });
    } else {
      setState(() {
        filteredUsers = users.where((user) {
          return user['first_name'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  void changePage(int page) {
    if (page != currentPage && page >= 1 && page <= totalPages) {
      setState(() {
        _searchController.clear();
        searchQuery = '';
      });
      fetchUsers(page);
    }
  }

  Widget buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_left),
            onPressed: currentPage > 1 ? () => changePage(currentPage - 1) : null,
            color: currentPage > 1 ? Colors.blue : Colors.grey,
          ),
          ...List.generate(totalPages, (index) {
            final pageNumber = index + 1;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                onPressed: () => changePage(pageNumber),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pageNumber == currentPage
                      ? Colors.blue
                      : Theme.of(context).cardColor,
                  foregroundColor: pageNumber == currentPage
                      ? Colors.white
                      : Colors.grey,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(12),
                  elevation: pageNumber == currentPage ? 4 : 0,
                ),
                child: Text('$pageNumber'),
              ),
            );
          }),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_right),
            onPressed: currentPage < totalPages ? () => changePage(currentPage + 1) : null,
            color: currentPage < totalPages ? Colors.blue : Colors.grey,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Directory'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: currentPage > 0 && totalPages > 0
                  ? Text(
                      'Page $currentPage of $totalPages',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Pagination info
          if (totalUsers > 0 && !isLoading)
            Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text(
                'Showing ${(currentPage - 1) * perPage + 1}-${currentPage * perPage > totalUsers ? totalUsers : currentPage * perPage} of $totalUsers users',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          
          // Search box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by first name',
                labelStyle: TextStyle(color: Colors.grey[800]), // default
                floatingLabelStyle: TextStyle(color: Colors.blue[700]), // when focused
                hintText: 'Enter first name to search',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          filterUsers('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.blue),
                )
                ,
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[200],
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                filterUsers(value);
              },
            ),
          ),
          
          // User list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isEmpty
                                  ? 'No users available'
                                  : 'No users found for "$searchQuery"',
                              style: const TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredUsers.length,
                        padding: const EdgeInsets.all(8.0),
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return UserCard(user: user);
                        },
                      ),
          ),
          
          // Pagination controls
          if (!isLoading && totalPages > 0)
            buildPagination(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Hero(
          tag: 'avatar-${user['id']}',
          child: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(user['avatar']),
          ),
        ),
        title: Text(
          '${user['first_name']} ${user['last_name']}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'ID: ${user['id']}',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${user['email']}',
              style: TextStyle(
                color: Colors.blue[700],
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
        onTap: () {
          showUserDetails(context, user);
        },
      ),
    );
  }

  void showUserDetails(BuildContext context, Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'avatar-${user['id']}',
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(user['avatar']),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${user['first_name']} ${user['last_name']}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'ID: ${user['id']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    '${user['email']}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close', style: TextStyle(fontSize: 16, color: Colors.black)),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }
}