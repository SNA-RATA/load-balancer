class LoadBalancerDto {
  const LoadBalancerDto({
    required this.serverId,
    required this.note,
  });

  factory LoadBalancerDto.fromJson(Map<String, dynamic> json) {
    return LoadBalancerDto(
      serverId: json['server_id'] as String? ?? '',
      note: json['note'] as String? ?? '',
    );
  }

  final String serverId;
  final String note;
}
