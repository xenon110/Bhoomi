/// Turso Cloud (libSQL / Edge SQLite) Configuration
/// Database: bhoomi-xenon110
/// Region: aws-ap-south-1 (Mumbai, India)
/// 24/7 Serverless Edge SQLite Database
class TursoConfig {
  /// Default Turso LibSQL database URL
  static const String defaultDbUrl = 'libsql://bhoomi-xenon110.aws-ap-south-1.turso.io';

  /// Turso HTTP Pipeline endpoint (v2/pipeline)
  static const String defaultPipelineUrl = 'https://bhoomi-xenon110.aws-ap-south-1.turso.io/v2/pipeline';

  /// Official Turso Auth Token (JWT)
  static const String initialToken = 'eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.eyJhIjoicnciLCJpYXQiOjE3OTM4NjM0OTksImlkIjoiMDFhMWFhN2UtYzgwMS03NGJhLTk1OGYtZjRhNmYxOGM1N2E4Iiwia2lkIjoiSk5fTDYxUzJDNnhZOEZXMThhOHVEenVsZnZ3X1UtRlotN3gtT28tc0Z2TSIsInJpZCI6IjVmMzNmMDlmLTJiMzktNDYwNi04MWM2LTI4NTY3NTBmZGRhNyJ9.JIZzSz8zaBfWeHC3mQes3uZCbZ0m5Niu2NCrBB7jVYlSNL2yRpbiHIKc6rHsHBWSuWmM7t5Vn3TLcO48VDZvDg';

  static const String storageKeyToken = 'bhoomi_turso_auth_token';
  static const String storageKeyUrl = 'bhoomi_turso_pipeline_url';
}

