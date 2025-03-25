import { IProfile } from "./schema/schema.interface";

interface UserAccount {
    email: string;
    username: string;
    password: string;
}

export interface IUserRegistration {
    account: UserAccount;
    profile: IProfile;
}
