import bcrypt from 'bcrypt';
import { type Request, type Response } from 'express';
import { statuses } from '../_core/const/api.statuses';
import { validateEkyc, validateLogin, validateRegister } from '../_core/validators/auth.validator';
import { emitter } from '../_core/events/activity.event';
import { ActivityType, EventName } from '../_core/enum/activity.enum';
import { IActivity } from '../_core/interfaces/activity.interface';
import { generateJwt } from '../_core/utils/jwt/jwt.util';
import { getEnv } from '../_core/config/env.config';

import User from '../models/user.schema';
import { encrypt } from '../_core/utils/security/encryption.util';
import RoleName from '../models/role_name.schema';
import UserRole from '../models/user_role.schema';
import { findRoleByUser } from '../services/role.service';
import { TRequest } from '../_core/interfaces/overrides.interface';
import { validatorChangePassword } from '../_core/validators/user.validator';
import { isUserActive } from '../services/user.service';
import { IUserRegistration } from '../_core/interfaces/auth.interface';
import Profile from '../models/profile.schema';
import { findProfileByUser } from '../services/profile.service';

export const login = async (req: Request, res: Response): Promise<any> => {
  try {
    const error = validateLogin(req.body);
    if (error) {
      return res.status(400).json({
        ...statuses['501'],
        message: error.details[0].message.replace(/['"]/g, ''),
      });
    }

    const { username, password } = req.body;

    const user = await User.findOne()
      .or([{ username }, { email: username }])
      .exec();

    if (!user) {
      res.status(401).json(statuses['0051']);
      return;
    }

    const passwordMatched: boolean = await bcrypt.compare(password, user.password);
    if (!passwordMatched) {
      return res.status(401).json(statuses['0051']);
    }

    const isActive = await isUserActive(user._id);
    if (!isActive) {
      return res.status(401).json(statuses['0058']);
    }

    const isProfileCreated = await findProfileByUser(user._id);


    emitter.emit(EventName.ACTIVITY, {
      user: user.id,
      description: ActivityType.LOGIN,
    } as IActivity);

    const userRole = await findRoleByUser(user.id);
    if (!userRole) {
      return res.status(403).json(statuses['0071']);
    }

    const env = await getEnv();
    const payload = { origin: req.headers['nodex-user-origin'], id: user.id };

    const encryptedPayload = encrypt(payload, env.NODEX_CRYPTO_KEY ?? '123_cryptoKey');

    if (!isProfileCreated) {
      return res.status(401).json({
        ...statuses['0104'],
        role: userRole,
        data: await generateJwt(encryptedPayload, env.JWT_SECRET_KEY || '123_secretKey'),
      });
    }

    return res.status(200).json({
      ...statuses['00'],
      role: userRole,
      data: await generateJwt(encryptedPayload, env.JWT_SECRET_KEY || '123_secretKey'),
    });
  } catch (error) {
    console.log('@login error', error);
    return res.status(401).json(statuses['0900']);
  }
};

export const register = async (req: Request, res: Response): Promise<any> => {
  try {
    const error = validateRegister(req.body);
    if (error) {
      return res.status(400).json({
        ...statuses['501'],
        message: error.details[0].message.replace(/['"]/g, ''),
      });
    }

    const { username, email, password } = req.body;

    const existingUser = await User.findOne().or([{ username }, { email }]).exec();
    if (existingUser) {
      return res.status(401).json(statuses['0052']);
    }

    const saltRounds = 10;
    const salt = await bcrypt.genSalt(saltRounds);

    const hashedPassword = await bcrypt.hash(password, salt);

    const newUser = new User({
      username,
      email,
      password: hashedPassword,
      salt,
    });

    const createdUser = await newUser.save();

    emitter.emit(EventName.ACTIVITY, {
      user: createdUser.id,
      description: ActivityType.REGISTRATION_SUCCESS,
    } as IActivity);

    const env = await getEnv();
    const payload = { origin: req.headers['nodex-user-origin'], id: createdUser.id };

    const assignedRole = await UserRole.findOne({ user: createdUser.id });

    if (!assignedRole) {
      const [customerRoleName, staffRoleName, adminRoleName] = await Promise.all([
        RoleName.findOne({ name: 'Customer' }),
        RoleName.findOne({ name: 'Staff' }),
        RoleName.findOne({ name: 'Administrator' }),
      ]);

      const newUserRole = new UserRole();

      if (payload.origin === "web") {
        newUserRole.user = createdUser.id;
        newUserRole.role = staffRoleName!._id;
      }
      else if (payload.origin === "mobile") {
        newUserRole.user = createdUser.id;
        newUserRole.role = customerRoleName!._id;
      }
      else if (payload.origin === "system") {
        newUserRole.user = createdUser.id;
        newUserRole.role = adminRoleName!._id;
      }

      await newUserRole.save();
    }

    const userRole = await findRoleByUser(createdUser.id);
    if (!userRole) {
      return res.status(403).json(statuses['0071']);
    }

    const encryptedPayload = encrypt(payload, env.NODEX_CRYPTO_KEY ?? '123_cryptoKey');

    return res.status(201).json({
      ...statuses['0050'],
      role: userRole,
      data: await generateJwt(encryptedPayload, env.JWT_SECRET_KEY || '123_secretkey'),
    });
  } catch (error) {
    console.log('@register error', error);
    return res.status(401).json(statuses['0900']);
  }
};

export const changeUserPassword = async (req: TRequest, res: Response) => {
  const error = validatorChangePassword(req.body);
  if (error) {
    return res.status(400).json({
      ...statuses['501'],
      message: error.details[0].message.replace(/['"]/g, ''),
    });
  }

  try {
    const { currentPassword, newPassword } = req.body;
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json(statuses['0056']);
    }

    const passwordMatched: boolean = await bcrypt.compare(currentPassword, user.password);
    if (!passwordMatched) {
      return res.status(403).json(statuses['0063']);
    }

    if (currentPassword === newPassword) {
      return res.status(403).json(statuses['0064']);
    }

    const saltRounds = 10;
    const salt = await bcrypt.genSalt(saltRounds);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    await User.findByIdAndUpdate(req.user.id,
      { password: hashedPassword },
      { new: true }
    );

    emitter.emit(EventName.ACTIVITY, {
      user: user.id,
      description: ActivityType.CHANGE_PASSWORD,
    } as IActivity);

    return res.status(200).json(statuses["00"]);
  } catch (error) {
    console.log('@updateUserPassword error', error);
    return res.status(500).json(statuses['0900']);
  }
}

export const ekyc = async (req: TRequest, res: Response): Promise<any> => {
  const error = validateEkyc(req.body);
  if (error) {
    return res.status(403).json({
      ...statuses['501'],
      message: error.details[0].message.replace(/['"]/g, ''),
    });
  }

  try {
    const {
      account: {
        username,
        email,
        password
      },
      profile: {
        fullName,
        address,
        contact,
        facebook,
        messenger
      }
    } = req.body as IUserRegistration;


    const existingUser = await User.findOne().or([{ username }, { email }]).exec();
    if (existingUser) {
      return res.status(403).json(statuses['0052']);
    }

    const saltRounds = 10;
    const salt = await bcrypt.genSalt(saltRounds);

    const hashedPassword = await bcrypt.hash(password, salt);

    const newUser = new User({
      username,
      email,
      password: hashedPassword,
      salt,
      origin: req.from
    });

    const createdUser = await newUser.save();

    const newProfile = new Profile({
      user: newUser._id,
      fullName,
      facebook,
      messenger,
      address,
      contact,
    });

    await newProfile.save();

    const assignedRole = await UserRole.findOne({ user: createdUser.id });

    if (!assignedRole) {
      const staffRoleName = await RoleName.findOne({ name: 'Staff' });

      const newUserRole = new UserRole({
        user: createdUser.id,
        role: staffRoleName!._id
      });

      await newUserRole.save();
    }

    emitter.emit(EventName.ACTIVITY, {
      user: createdUser.id,
      description: ActivityType.EKYC_SUCCESS,
    } as IActivity);

    return res.status(201).json(statuses['00']);
  } catch (error) {
    console.log('@register error', error);
    return res.status(500).json(statuses['0900']);
  }
};
