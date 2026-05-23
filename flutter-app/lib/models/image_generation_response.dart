class ImageGenerationResponse {
  final String imageData; // Base64-encoded image
  final String mimeType;
  final String description;
  final int sizeBytes;

  ImageGenerationResponse({
    required this.imageData,
    required this.mimeType,
    required this.description,
    required this.sizeBytes,
  });

  factory ImageGenerationResponse.fromJson(Map<String, dynamic> json) {
    return ImageGenerationResponse(
      imageData: json['image_data'] as String,
      mimeType: json['mime_type'] as String,
      description: json['description'] as String,
      sizeBytes: json['size_bytes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_data': imageData,
      'mime_type': mimeType,
      'description': description,
      'size_bytes': sizeBytes,
    };
  }
}
