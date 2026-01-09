class CategoryImageMapper {
  static String getImageUrl(String name) {
    // Convert to lowercase to avoid matching issues
    final cleanName = name.toLowerCase();

    if (cleanName.contains('men')) {
      return 'https://images.unsplash.com/photo-1488161628813-04466f872be2?w=500';
    } else if (cleanName.contains('women')) {
      return 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=500';
    } else if (cleanName.contains('acces') || cleanName.contains('bag')) {
      return 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500';
    } else if (cleanName.contains('shoe') || cleanName.contains('footwear')) {
      return 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500';
    } else if (cleanName.contains('new')) {
      return 'https://images.unsplash.com/photo-1529133039941-7f269591e703?w=500';
    }
    
    // Default fallback image if no match is found
    return 'https://images.unsplash.com/photo-1523381235212-d73f80380142?w=500';
  }
}