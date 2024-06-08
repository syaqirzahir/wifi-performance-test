class Project {
  int projectId;
  String projectName;
  int userId;

  Project({
    required this.projectId,
    required this.projectName,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'projectName': projectName,
      'userId': userId,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      projectId: map['project_id'] ?? 0, // Use a default value if null
      projectName: map['project_name'] ?? '', // Use an empty string if null
      userId: map['user_id'] ?? 0, // Use a default value if null
    );
  }
}
