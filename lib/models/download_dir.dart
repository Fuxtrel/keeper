class DownloadDir {
  String? session;
  String? downloadTransactionToken;
  String? uploadTransactionToken;
  dynamic hash;
  String? proxyIp;
  int? proxyPort;

  DownloadDir({
    this.session,
    this.downloadTransactionToken,
    this.uploadTransactionToken,
    this.hash,
    this.proxyIp,
    this.proxyPort,
  });

  @override
  String toString() {
    return 'DownloadDir(session: $session, downloadTransactionToken: $downloadTransactionToken, uploadTransactionToken: $uploadTransactionToken, hash: $hash, proxyIp: $proxyIp, proxyPort: $proxyPort)';
  }

  factory DownloadDir.fromJson(Map<String, dynamic> json) => DownloadDir(
        session: json['session'] as String?,
        downloadTransactionToken: json['downloadTransactionToken'] as String?,
        uploadTransactionToken: json['uploadTransactionToken'] as String?,
        hash: json['hash'],
        proxyIp: json['proxyIP'] as String?,
        proxyPort: json['proxyPORT'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'session': session,
        'downloadTransactionToken': downloadTransactionToken,
        'uploadTransactionToken': uploadTransactionToken,
        'hash': hash,
        'proxyIP': proxyIp,
        'proxyPORT': proxyPort,
      };

  DownloadDir copyWith({
    String? session,
    String? downloadTransactionToken,
    String? uploadTransactionToken,
    dynamic hash,
    String? proxyIp,
    int? proxyPort,
  }) {
    return DownloadDir(
      session: session ?? this.session,
      downloadTransactionToken:
          downloadTransactionToken ?? this.downloadTransactionToken,
      uploadTransactionToken:
          uploadTransactionToken ?? this.uploadTransactionToken,
      hash: hash ?? this.hash,
      proxyIp: proxyIp ?? this.proxyIp,
      proxyPort: proxyPort ?? this.proxyPort,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DownloadDir &&
        other.session == session &&
        other.downloadTransactionToken == downloadTransactionToken &&
        other.uploadTransactionToken == uploadTransactionToken &&
        other.hash == hash &&
        other.proxyIp == proxyIp &&
        other.proxyPort == proxyPort;
  }

  @override
  int get hashCode =>
      session.hashCode ^
      downloadTransactionToken.hashCode ^
      uploadTransactionToken.hashCode ^
      hash.hashCode ^
      proxyIp.hashCode ^
      proxyPort.hashCode;
}
