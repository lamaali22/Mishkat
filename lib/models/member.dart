class member {
  String name;
  String phoneNumber;
  List<String> listOfFavorites;
  List<String> listOfSavedClasses;

  member({
    required this.name,
    required this.phoneNumber,
    required this.listOfFavorites,
    required this.listOfSavedClasses,
  });

  // from map
  factory member.fromMap(Map<String, dynamic> map) {
    return member(
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      listOfFavorites: map['listOfFavorites'] ?? '',
      listOfSavedClasses: map['listOfSavedClasses'] ?? '',
    );
  }

  //to map

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "phoneNumber": phoneNumber,
      "listOfFavorites": listOfFavorites,
      "listOfSavedClasses": listOfSavedClasses,
    };
  }
}
