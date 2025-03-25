require('dotenv').config();
import { IEnvironmentVariables } from '../interfaces/env.interface';

export const getEnv = async (): Promise<IEnvironmentVariables> => {
  const env = {
    ENVIRONMENT: process.env.ENVIRONMENT,
    ENVIRONMENT_MAINTENANCE: process.env.ENVIRONMENT_MAINTENANCE,
    PORT: process.env.PORT,
    DB_CONNECTION_STRING: process.env.DB_CONNECTION_STRING,
    DB_CONNECTION_STRING_LOCAL: process.env.DB_CONNECTION_STRING_LOCAL,
    AWS_ACCESS_KEY_ID: process.env.AWS_ACCESS_KEY_ID,
    AWS_SECRET_ACCESS_KEY: process.env.AWS_SECRET_ACCESS_KEY,
    AWS_SECRET_NAME: process.env.AWS_SECRET_NAME,
    JWT_EXPIRY: process.env.JWT_EXPIRY,
    JWT_SECRET_KEY: process.env.JWT_SECRET_KEY,
    NODEX_ACCESS_KEY: process.env.NODEX_ACCESS_KEY,
    NODEX_SECRET_KEY: process.env.NODEX_SECRET_KEY,
    NODEX_CRYPTO_KEY: process.env.NODEX_CRYPTO_KEY,
    MAX_LIMIT_SMALL_CAGE: Number(process.env.MAX_LIMIT_SMALL_CAGE),
    MAX_LIMIT_MEDIUM_CAGE: Number(process.env.MAX_LIMIT_MEDIUM_CAGE),
    MAX_LIMIT_LARGE_CAGE: Number(process.env.MAX_LIMIT_LARGE_CAGE),
    CLOUDINARY_NAME: process.env.CLOUDINARY_NAME,
    CLOUDINARY_KEY: process.env.CLOUDINARY_KEY,
    CLOUDINARY_SECRET: process.env.CLOUDINARY_SECRET,
  };

  // Check if any property is undefined or null
  const missingVariables = Object.entries(env).filter(
    ([, value]) => value === undefined || value === null || value === 'null',
  );

  if (missingVariables.length > 0) {
    const missingProps = missingVariables.map(([key]) => key).join(', ');
    throw new Error(`Missing environment variables: ${missingProps}`);
  }

  return env;
};
