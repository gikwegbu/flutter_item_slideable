import 'package:flutter/material.dart';
import 'package:slideable/slideable.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Slideable Widget',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // This is used to monitor the item index in the list, and later used to closeup or leave open the slide.
  int resetSlideIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Class List"),
      ),
      body: ListView.separated(
        itemCount: _classList.length,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        itemBuilder: (context, index) {
          final Map<String, dynamic> student = _classList[index];
          return GestureDetector(
            onLongPressDown: (val) {
              // This allows you the time taken for a user to slide upon the widget in the list.
              // NB: Using the onTap or onHorizontalDragStart seemed to have caused a seizure in the widget, hence my resulting to onLongPressDown
              setState(() {
                // This updates the widget, and inturn rebuilds it, thereby notifying the Slidable widget to close an already slide item
                resetSlideIndex = index;
              });
            },
            child: _listItem(
              context: context,
              student: student,
              index: index,
              resetSlide: index != resetSlideIndex,
              // Reverse engineering the notion, meaning the Slidable widget will close all slid item, except one with false, i.e the currently slide item
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 10),
      ),
    );
  }

  Slideable _listItem({
    required BuildContext context,
    required Map<String, dynamic> student,
    required int index,
    required bool resetSlide,
  }) {
    return Slideable(
      resetSlide: resetSlide,
      items: <ActionItems>[
        ActionItems(
          icon: const Icon(
            Icons.thumb_up,
            color: Colors.blue,
          ),
          onPress: () => _likeUser(student["name"]),
          backgroudColor: Colors.transparent,
        ),
        ActionItems(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPress: () => _deleteUser(student["name"]),
          backgroudColor: Colors.transparent,
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 214, 214, 214),
          border: Border.all(
            width: 1,
            color: const Color.fromARGB(124, 158, 158, 158),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey[350],
                shape: BoxShape.circle,
                border: Border.all(
                  width: 1,
                  color: Colors.white,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  student["img"],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Name",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    student["name"],
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "#${index + 1}",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteUser(String user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$user, will be deleted."),
        backgroundColor: Colors.grey[450],
      ),
    );
  }

  void _likeUser(String user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You gave $user a thumbs up, pretty cool 🥰"),
        backgroundColor: Colors.grey[450],
      ),
    );
  }

  final List<Map<String, dynamic>> _classList = [
    {
      "name": "Ikwegbu George",
      "img":
          "https://images.pexels.com/photos/2379429/pexels-photo-2379429.jpeg?auto=compress&cs=tinysrgb&w=1600",
    },
    {
      "name": "Phoebe Pelumi",
      "img":
          "https://images.pexels.com/photos/3986672/pexels-photo-3986672.jpeg?auto=compress&cs=tinysrgb&w=1600&lazy=load",
    },
    {
      "name": "James Mike",
      "img":
          "https://images.pexels.com/photos/11828983/pexels-photo-11828983.jpeg?auto=compress&cs=tinysrgb&w=1600&lazy=load",
    },
    {
      "name": "Abigail Ezinne",
      "img":
          "https://images.pexels.com/photos/3030252/pexels-photo-3030252.jpeg?auto=compress&cs=tinysrgb&w=1600&lazy=load",
    },
    {
      "name": "Chioma Chinedu",
      "img":
          "https://images.pexels.com/photos/4491630/pexels-photo-4491630.jpeg?auto=compress&cs=tinysrgb&w=1600",
    },
  ];
}
