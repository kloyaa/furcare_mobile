import jwt from 'jsonwebtoken';
import { getEnv } from '../../config/env.config';

export const generateJwt = async (value: any, secretKey: string) => {
  const env = await getEnv();
  return jwt.sign({ value }, secretKey, { expiresIn: env.JWT_EXPIRY });
};
