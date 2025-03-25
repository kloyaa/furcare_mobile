import mongoose from 'mongoose';
import { getEnv } from '../../config/env.config';

export const connectDB = async () => {
  try {
    const env = await getEnv();
    if (env?.DB_CONNECTION_STRING) {
      await mongoose.connect(env?.DB_CONNECTION_STRING);
      console.log('@connectDB Database connection success.');
      return;
    }
    throw new Error('Missing connection string.');
  } catch (error) {
    console.error('@connectDB ', error);
    process.exit(1);
  }
};

export const closeDB = async () => {
  try {
    await mongoose.disconnect();
    console.log('@closeDB Database connection closed.');
  } catch (error) {
    console.error('@closeDB Error closing database connection:', error);
    process.exit(1); // Optionally exit process if closing fails
  }
};
