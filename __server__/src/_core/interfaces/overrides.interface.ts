import { Request } from 'express';
import { IProfile } from './schema/schema.interface';
import { type Response } from 'express';

export type TRequest = Request & {
  user: {
    origin: string;
    id: string;
  };
  profile: IProfile;
  from: string;
  files: any;
};

export type TResponse = Response;
