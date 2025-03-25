import { type Response } from 'express';
import { emitter } from '../_core/events/activity.event';
import Profile from '../models/profile.schema';
import { validateCreateProfile, validateUpdateProfile } from '../_core/validators/user.validator';
import { statuses } from '../_core/const/api.statuses';
import { ActivityType, EventName } from '../_core/enum/activity.enum';
import { IActivity } from '../_core/interfaces/activity.interface';
import { TRequest } from '../_core/interfaces/overrides.interface';

export const createProfile = async (req: TRequest, res: Response) => {
  console.log(req.body)
  const error = validateCreateProfile(req.body);
  if (error) {
    return res.status(400).json({
      ...statuses['501'],
      message: error.details[0].message.replace(/['"]/g, ''),
    });
  }

  try {
    const { fullName, facebook, messenger, birthdate, address, contact, gender, isActive } = req.body;
    const profile = await Profile.findOne({ user: req.user.id });
    if (profile) {
      return res.status(400).json(statuses['0103']);
    }

    const newProfile = new Profile({
      user: req.user.id,
      fullName,
      birthdate,
      address,
      contact,
      gender,
      isActive,
      facebook,
      messenger
    });

    const savedProfile = await newProfile.save();

    emitter.emit(EventName.ACTIVITY, {
      user: req.user.id as any,
      description: ActivityType.PROFILE_CREATED,
    } as IActivity);

    // Return the saved profile as a response
    return res.status(201).json(savedProfile);
  } catch (error) {
    console.log('@createProfile error', error);
    return res.status(401).json(statuses['0900']);
  }
};

export const getProfileByAccessToken = async (req: TRequest, res: Response) => {
  try {
    const user = req.user.id;
    const result = await Profile.findOne({ user }).exec();

    if (!result) {
      return res.status(404).json(statuses['0104']);
    }

    return res.status(200).json(result);
  } catch (error) {
    console.log('@getProfileByAccessToken error', error);
    return res.status(401).json(statuses['0900']);
  }
};

export const updateProfileByAccessToken = async (req: TRequest, res: Response) => {
  const error = validateUpdateProfile(req.body);
  if (error) {
    return res.status(400).json({
      ...statuses['501'],
      message: error.details[0].message.replace(/['"]/g, ''),
    });
  }

  try {
    const existingProfile = await Profile.findOne({ user: req.user.id });
    if (!existingProfile) {
      return res.status(404).json(statuses['0104']);
    }

    const { fullName, address, contact, messenger, facebook } = req.body;

    // Update the existing profile fields
    existingProfile.fullName = fullName;
    existingProfile.address = address;
    existingProfile.contact = contact;
    existingProfile.messenger = messenger;
    existingProfile.facebook = facebook;

    await existingProfile.save();

    emitter.emit(EventName.ACTIVITY, {
      user: req.user.id as any,
      description: ActivityType.PROFILE_UPDATED,
    } as IActivity);

    // Return success response
    return res.status(200).json(statuses['0101']);
  } catch (error) {
    console.log('@updateProfileByAccessToken error', error);
    return res.status(500).json(statuses['0900']);
  }
};

