class Student {
  int? id;
  String name;
  int age;
  int score;
  DateTime birthday;
  String studentClass;
  String? phone;
  String imagePath;

  Student({
    this.id,
    required this.name,
    required this.age,
    required this.score,
    required this.birthday,
    required this.studentClass,
    required this.phone,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'score': score,
      'birthday': birthday.toIso8601String(),
      'studentClass': studentClass,
      'phone': phone!,
      'imagePath': imagePath,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      score: map['score'],
      birthday: DateTime.parse(map['birthday']),
      studentClass: map['studentClass'],
      phone: map['phone'],
      imagePath: map['imagePath'],
    );
  }
}