import { IPetOwner } from "../_core/interfaces/schema/schema.interface";
import PetOwner from "../models/pet_owner.schema";

export const findPetOwnerByUser = async (user: string): Promise<IPetOwner | null> => {
    try {
        const petOwner = await PetOwner.findOne({ user });
        if (!petOwner) {
            return null;
        }

        return petOwner;
    } catch (error) {
        return null;
    }
};