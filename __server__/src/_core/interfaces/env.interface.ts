export interface IEnvironmentVariables {
  ENVIRONMENT: string | undefined;
  ENVIRONMENT_MAINTENANCE: string | undefined;
  PORT: string | undefined;
  DB_CONNECTION_STRING: string | undefined;
  DB_CONNECTION_STRING_LOCAL: string | undefined;
  AWS_ACCESS_KEY_ID: string | undefined;
  AWS_SECRET_ACCESS_KEY: string | undefined;
  AWS_SECRET_NAME: string | undefined;
  JWT_EXPIRY: string | undefined;
  JWT_SECRET_KEY: string | undefined;
  NODEX_ACCESS_KEY: string | undefined;
  NODEX_SECRET_KEY: string | undefined;
  NODEX_CRYPTO_KEY: string | undefined;
  MAX_LIMIT_SMALL_CAGE: number | undefined;
  MAX_LIMIT_MEDIUM_CAGE: number | undefined;
  MAX_LIMIT_LARGE_CAGE: number | undefined;
}
