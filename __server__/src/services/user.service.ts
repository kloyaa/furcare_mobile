import { Types } from "mongoose";
import Profile from "../models/profile.schema";

export const isUserActive = async (user: Types.ObjectId) => {
    try {
        const profile = await Profile.findOne({ user });
        if (profile) {
            if (!profile.isActive) {
                return false;
            }
        }

        return true;
    } catch (error) {
        return false;
    }
};