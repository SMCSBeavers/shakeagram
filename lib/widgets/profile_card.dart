import 'package:flutter/material.dart';
import 'package:shakeagram/models/user_object.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({Key? key, required this.profile}) : super(key: key);

  final UserObject profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: SizedBox(
                  width: 100.0,
                  height: 100.0,
                  child: Image.network(
                    profile.avatar,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      profile.getName,
                      style: const TextStyle(fontSize: 20.0),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Posts'),
                            Text(profile.posts.length.toString()),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Followers'),
                            Text(profile.followers.length.toString()),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Following'),
                            Text(profile.following.length.toString()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0),
          child:
              Align(alignment: Alignment.center, child: Text(profile.getBio)),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  onPressed: () {}, child: const Text('Edit Profile')),
              ElevatedButton(onPressed: () {}, child: const Text('Signout'))
            ],
          ),
        ),
      ],
    );
  }
}
