class Post {
  String id = "";
  String image = "";
  String userImage = "";
  String userName = "";
  DateTime createdAt = DateTime.now();
  String email = "";
  int downloads = 0;
  String postId = "";
  List<String>? likes = List.empty(growable: true);

  Post({
    required this.id,
    required this.image,
    required this.userImage,
    required this.createdAt,
    required this.userName,
    required this.email,
    required this.postId,
    required this.downloads,
    required this.likes
  });

  //Post getPost = Post();
}