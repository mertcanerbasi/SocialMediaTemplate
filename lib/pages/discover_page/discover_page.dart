import 'package:flutter/material.dart';
import 'package:socialmediaapp/models/users.dart';
import 'package:socialmediaapp/pages/profile_page/profile_page.dart';
import 'package:socialmediaapp/services/firestore_service.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  TextEditingController _searchController = TextEditingController();
  Future<List<AppUsers?>>? _searchResult;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _createAppBar(),
      body: _searchResult != null ? getSearchResults() : noSearch(),
    );
  }

  AppBar _createAppBar() {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: Colors.grey[100],
      title: TextFormField(
        controller: _searchController,
        onFieldSubmitted: (value) {
          setState(() {
            _searchResult = FireStoreService().discoverSearchUser(value);
          });
        },
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              size: 30,
              color: Colors.black,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchResult = null;
                });
              },
              icon: Icon(
                Icons.clear,
                color: Colors.black,
              ),
            ),
            border: InputBorder.none,
            fillColor: Colors.white,
            filled: true,
            hintText: "Search...",
            contentPadding: EdgeInsets.only(top: 16)),
      ),
    );
  }

  Widget getSearchResults() {
    return FutureBuilder<List<AppUsers?>?>(
      future: _searchResult,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data?.length == 0) {
          return Text("No results found for that keywords");
        }
        return ListView.builder(
            itemCount: snapshot.data?.length,
            itemBuilder: ((context, index) {
              AppUsers? user = snapshot.data?[index];
              return userLine(user);
            }));
      },
    );
  }

  Widget noSearch() {
    return Center(child: Text("Search Users"));
  }

  Widget userLine(AppUsers? user) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: ((context) => ProfilePage(
                  profileOwnerId: user!.id,
                )),
          ),
        );
      },
      child: ListTile(
        leading: user?.fotoUrl != ""
            ? CircleAvatar(
                backgroundColor: Colors.grey[300],
                backgroundImage: NetworkImage(user?.fotoUrl ?? ""),
              )
            : CircleAvatar(
                backgroundColor: Colors.grey[300],
                backgroundImage: AssetImage("assets/images/default_user.png"),
              ),
        title: Text(
          "${user?.userName}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
