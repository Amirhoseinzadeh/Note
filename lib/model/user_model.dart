import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId:0)
class UserModel extends HiveObject{
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String description;
  UserModel({required this.title,required this.description});

}