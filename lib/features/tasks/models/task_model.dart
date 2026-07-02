class TechTask {
  final String taskId;
  final String clientName;
  final String clientEmail;
  final String category;
  final String issueDescription;
  final String location;

  TechTask({
    required this.taskId,
    required this.clientName,
    required this.clientEmail,
    required this.category,
    required this.issueDescription,
    required this.location,
  });

  factory TechTask.fromJson(Map<String, dynamic> json) {
    return TechTask(
      taskId: json['taskId'] ?? json['ticketId']?.toString() ?? '',
      clientName: json['clientName'] ?? 'Cliente Desconocido',
      clientEmail: json['clientEmail'] ?? 'Sin correo',
      category: json['category'] ?? 'General',
      issueDescription: json['issueDescription'] ?? 'Sin descripción',
      location: json['location'] ?? "Dispositivo: ${json['deviceId'] ?? 'N/A'}",
    );
  }
}
