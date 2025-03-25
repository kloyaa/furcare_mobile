import { type Response } from 'express';
import { TRequest } from "../_core/interfaces/overrides.interface";
import { statuses } from '../_core/const/api.statuses';
import Pet from '../models/pet.schema';
import { emitter } from '../_core/events/activity.event';
import { ActivityType, EventName } from '../_core/enum/activity.enum';
import { IActivity } from '../_core/interfaces/activity.interface';
import { validatoCreatePet } from '../_core/validators/pet.validator';

export const createPet = async (req: TRequest, res: Response) => {
    console.log("@createPet body", req.body)
    const error = validatoCreatePet(req.body);
    if (error) {
        return res.status(403).json({
            ...statuses['501'],
            message: error.details[0].message.replace(/['"]/g, ''),
        });
    }

    try {
        const { name, breed, age, gender, } = req.body;
        const userId = req.user.id;

        const newPet = new Pet({
            user: userId,
            name,
            age,
            gender,
            breed
        });

        await newPet.save();

        emitter.emit(EventName.ACTIVITY, {
            user: req.user.id as any,
            description: ActivityType.PET_ADDED,
        } as IActivity);

        return res.status(200).json(statuses['00']);
    } catch (error) {
        console.log('@createPet error', error);
        return res.status(500).json(statuses['0900']);
    }
};

export const getPetsByAccessToken = async (req: TRequest, res: Response) => {
    try {
        const pet = await Pet.find({ user: req.user.id });
        if (!pet) {
            return res.status(404).json(statuses['99001']);
        }
        return res.status(200).json(pet);
    } catch (error) {
        console.log('@getPetByAccessToken error', error);
        return res.status(500).json(statuses['0900']);
    }
};

export const updatePetByAccessToken = async (req: TRequest, res: Response) => {
    const error = validatoCreatePet(req.body);
    if (error) {
        return res.status(403).json({
            ...statuses['501'],
            message: error.details[0].message.replace(/['"]/g, ''),
        });
    }

    try {
        const updatedPetData = req.body;

        const updatedPet = await Pet.findOneAndUpdate({ user: req.user.id }, updatedPetData, { new: true });

        if (!updatedPet) {
            return res.status(404).json(statuses['99001']);
        }

        emitter.emit(EventName.ACTIVITY, {
            user: req.user.id as any,
            description: ActivityType.PET_UPDATED,
        } as IActivity);

        return res.status(200).json(statuses['00']);
    } catch (error) {
        console.log('@updatePetByAccessToken error', error);
        return res.status(500).json(statuses['0900']);
    }
};