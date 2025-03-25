import jwt from 'jsonwebtoken';
import { statuses } from '../const/api.statuses';
import { getEnv } from '../config/env.config';
import { decrypt } from '../utils/security/encryption.util';
import { TRequest } from '../interfaces/overrides.interface';

export const isAuthenticated = async (req: TRequest, res: any, next: any) => {
  try {
    const authHeader = req.headers['authorization'];
    if (!authHeader) {
      return res.status(401).json(statuses['10020']);
    }

    const token = authHeader.split(' ')[1];
    if (!token) {
      return res.status(401).json(statuses['10020']);
    }

    const env = await getEnv();

    jwt.verify(token, env?.JWT_SECRET_KEY as string, (err: any, decoded: any) => {
      if (err) {
        return res.status(401).json(statuses['10020']);
      }
      else if (decoded) {
        const decryptedData: { origin: string; id: string } = decrypt(decoded.value, env.NODEX_CRYPTO_KEY ?? "123_cryptoKey");
        if (!decryptedData) {
          return res.status(401).json(statuses['10020']);
        }
        req.user = decryptedData as any;
        next();
      }
    });
  } catch (error) {
    return res.status(401).json(statuses['10020']);
  }
};
