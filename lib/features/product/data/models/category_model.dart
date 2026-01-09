import '../../../../core/utils/category_image_mapper.dart';

class CategoryItem {
  final String id;
  final String title;
  final String image;

  CategoryItem({required this.id, required this.title, required this.image});

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    //  First, extract the name from JSON and store it in a variable
    final String categoryName = json['name'] ?? 'General';

    return CategoryItem(
      id: json['_id'] ?? '',
      title: categoryName, // Use the variable here
      // Pass that same variable into your Mapper
      image: CategoryImageMapper.getImageUrl(categoryName),
    );
  }
}