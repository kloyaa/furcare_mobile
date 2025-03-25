import { type Response } from 'express';
import { emitter } from '../_core/events/activity.event';
import { TRequest } from '../_core/interfaces/overrides.interface';
import { statuses } from '../_core/const/api.statuses';
import { validatorSavePetOwner, validatorUpdatePetOwner } from '../_core/validators/pet_owner.validator';
import { ActivityType, EventName } from '../_core/enum/activity.enum';
import { IActivity } from '../_core/interfaces/activity.interface';

import PetOwner from '../models/pet_owner.schema';
import { findProfileByUser } from '../services/profile.service';
import { findPetOwnerByUser } from '../services/pet_owner.service';

export const savePetOwner = async (req: TRequest, res: Response) => {
    const error = validatorSavePetOwner(req.body);
    if (error) {
        return res.status(403).json({
            ...statuses['501'],
            message: error.details[0].message.replace(/['"]/g, ''),
        });
    }

    try {
        const { emergencyContactNo, work } = req.body;
        const userId = req.user.id;

        const petOwner = await PetOwner.findOne({ user: userId });
        if (petOwner) {
            return res.status(404).json(statuses['04']);
        }

        const profile = await findProfileByUser(userId as any);
        if (!profile) {
            return res.status(404).json(statuses['0104']);
        }

        const newPetOwner = new PetOwner({
            user: userId,
            name: profile.fullName,
            address: `${profile?.address}`,
            mobileNo: `${profile?.contact.number}`,
            email: `${profile?.contact.email}`,
            emergencyContactNo,
            work,
        });

        await newPetOwner.save();

        emitter.emit(EventName.ACTIVITY, {
            user: req.user.id as any,
            description: ActivityType.PET_OWNER_ADDED,
        } as IActivity);

        return res.status(201).json(statuses["00"]);
    } catch (error) {
        console.log('@savePetOwner error', error);
        return res.status(500).json(statuses['0900']);
    }
};

export const getPetOwnerByAccessToken = async (req: TRequest, res: Response) => {
    try {
        const petOwner = await findPetOwnerByUser(req.user.id);
        if (!petOwner) {
            return res.status(404).json(statuses['99000']);
        }
        return res.status(200).json(petOwner);
    } catch (error) {
        console.log('@getPetOwnerByAccessToken error', error);
        return res.status(500).json(statuses['0900']);
    }
}

export const updatePetByAccessToken = async (req: TRequest, res: Response) => {
    const error = validatorUpdatePetOwner(req.body);
    if (error) {
        return res.status(403).json({
            ...statuses['501'],
            message: error.details[0].message.replace(/['"]/g, ''),
        });
    }

    try {
        const updatedOwner = await PetOwner.findOneAndUpdate({ user: req.user.id }, req.body, { new: true });
        if (!updatedOwner) {
            return res.status(404).json(statuses['99000']);
        }

        emitter.emit(EventName.ACTIVITY, {
            user: req.user.id as any,
            description: ActivityType.PET_OWNER_UPDATED,
        } as IActivity);

        return res.status(200).json(statuses['00']);
    } catch (error) {
        console.log('@updatePetByAccessToken error', error);
        return res.status(500).json(statuses['0900']);
    }
};