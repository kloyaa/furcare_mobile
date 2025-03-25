import Profile from "../models/profile.schema";
import { IProfile } from "../_core/interfaces/schema/schema.interface";
import { Types } from "mongoose";

export const findProfileByUser = async (user: Types.ObjectId): Promise<IProfile | null> => {
    try {
        const profile = await Profile.findOne({ user });
        if (!profile) {
            return null;
        }

        return profile;
    } catch (error) {
        return null;
    }
};