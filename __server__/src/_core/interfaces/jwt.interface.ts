export interface IAuthValue {
  value: {
    origin: string;
    id: string;
  };
  iat: number;
  exp: number;
}
