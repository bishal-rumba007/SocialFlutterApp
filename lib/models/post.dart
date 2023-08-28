class Like{
  final int likes;
  final List<String> usernames;
  Like({required this.likes, required this.usernames});

  factory Like.fromJson(Map<String, dynamic> json){
    return Like(
        likes: json['likes'],
        usernames: (json['usernames'] as List).map((e) => e as String).toList()
    );
  }
}

class Comment{
  final String commentText;
  final String username;
  final String userImage;

  Comment({ required this.commentText, required this.userImage, required this.username});

  factory Comment.fromJson(Map<String, dynamic> json){
    return Comment(
        username: json['username'],
        userImage: json['userImage'],
        commentText: json['commentText']
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'username': username,
      'commentText': commentText,
      'userImage': userImage
    };
  }

}


class Post{

  final String id;
  final String title;
  final String detail;
  final String userId;
  final String imageUrl;
  final String imageId;
  final Like like;
  final List<Comment> comments;

  Post({
    required this.like,
    required this.title,
    required this.id,
    required this.imageUrl,
    required this.comments,
    required this.detail,
    required this.imageId,
    required this.userId
  });

}

