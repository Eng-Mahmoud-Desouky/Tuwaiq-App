class AppInterest {
  final String id;
  final String name;
  final String icon;

  const AppInterest({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class AppInterests {
  static const List<AppInterest> list = [
    AppInterest(id: 'festivals', name: 'مواسم ومهرجانات', icon: 'campaign'),
    AppInterest(id: 'music', name: 'حفلات ومهرجانات', icon: 'music_note'),
    AppInterest(id: 'sports', name: 'رياضة ومغامرات', icon: 'sports_soccer'),
    AppInterest(id: 'arts', name: 'فنون وثقافة', icon: 'palette'),
    AppInterest(id: 'workshops', name: 'محاضرات وورش عمل', icon: 'lightbulb'),
    AppInterest(id: 'dining', name: 'طعام وترفيه', icon: 'restaurant'),
    AppInterest(id: 'gaming', name: 'ترفيه وألعاب', icon: 'sports_esports'),
    AppInterest(id: 'literature', name: 'أدب وصالونات ثقافية', icon: 'menu_book'),
    AppInterest(id: 'heritage', name: 'تراث ورحلات برية', icon: 'terrain'),
    AppInterest(id: 'business', name: 'معارض ومؤتمرات', icon: 'business_center'),
    AppInterest(id: 'community', name: 'فعاليات مجتمعية', icon: 'groups'),
    AppInterest(id: 'theater', name: 'عروض حية ومسرح', icon: 'theater_comedy'),
  ];
}
