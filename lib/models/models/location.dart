class Location {
  String? session;
  String? transactionToken;
  String? proxyIp;
  int? proxyPort;
  String? location;

  Location({
    this.session,
    this.transactionToken,
    this.proxyIp,
    this.proxyPort,
    this.location,
  });

  @override
  String toString() {
    return 'Location(session: $session, transactionToken: $transactionToken, proxyIp: $proxyIp, proxyPort: $proxyPort, location: $location)';
  }

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        session: json['session'] as String?,
        transactionToken: json['transactionToken'] as String?,
        proxyIp: json['proxyIP'] as String?,
        proxyPort: json['proxyPORT'] as int?,
        location: json['location'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'session': session,
        'transactionToken': transactionToken,
        'proxyIP': proxyIp,
        'proxyPORT': proxyPort,
        'location': location,
      };

  Location copyWith({
    String? session,
    String? transactionToken,
    String? proxyIp,
    int? proxyPort,
    String? location,
  }) {
    return Location(
      session: session ?? this.session,
      transactionToken: transactionToken ?? this.transactionToken,
      proxyIp: proxyIp ?? this.proxyIp,
      proxyPort: proxyPort ?? this.proxyPort,
      location: location ?? this.location,
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
    if (other is! Location) return false;
    return other.session == session &&
        other.transactionToken == transactionToken &&
        other.proxyIp == proxyIp &&
        other.proxyPort == proxyPort &&
        other.location == location;
  }

  @override
  int get hashCode =>
      session.hashCode ^
      transactionToken.hashCode ^
      proxyIp.hashCode ^
      proxyPort.hashCode ^
      location.hashCode;
}
