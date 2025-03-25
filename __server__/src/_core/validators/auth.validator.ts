import Joi from 'joi';
import { passwordRegexp, usernameRegexp } from '../const/patterns.const';

export const validateLogin = (body: any) => {
  const { error } = Joi.object({
    username: Joi.string().required(),
    password: Joi.string().required(),
  }).validate(body);

  return error;
};

export const validateRegister = (body: any) => {
  const { error } = Joi.object({
    username: Joi.string().required(),
    email: Joi.string().email().required(),
    password: Joi.string()
      .required()
      .required()
      .min(6)
      .max(255)
      .pattern(new RegExp(/^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/))
      .messages({
        'string.pattern.base': 'Password must contain at least 1 uppercase letter, 1 number, and 1 special character.',
      }),
  }).validate(body);

  return error;
};

export const validateEkyc = (body: any) => {
  const { error } = Joi.object({
    account: Joi.object({
      email: Joi.string().email().required(),
      username: Joi.string()
        .min(6)
        .max(75)
        .pattern(usernameRegexp)
        .messages({
          'string.min': 'Username must be at least 6 characters long.',
          'string.max': 'Username must be less than 76 characters.',
          'string.pattern.base': 'Username must contain at least 1 uppercase letter, and 1 number'
        })
        .required(),
      password: Joi.string()
        .min(6)
        .max(255)
        .pattern(passwordRegexp)
        .messages({
          'string.min': 'Password must be at least 6 characters long.',
          'string.max': 'Password must be less than 76 characters.',
          'string.pattern.base': 'Password must contain at least 1 uppercase letter, 1 number, and 1 special character.'
        })
        .required(),
    }).required(),
    profile: Joi.object({
      firstName: Joi.string().trim().min(2).max(50).required(),
      lastName: Joi.string().trim().min(2).max(50).required(),
      birthdate: Joi.date().iso().required(),
      address: Joi.object({
        present: Joi.string().trim().min(5).max(255),
        permanent: Joi.string().trim().min(5).max(255).optional().allow(null),
      }),
      contact: Joi.object({
        email: Joi.string().trim().email().optional().allow(null).messages({ 'string.email': 'Invalid email format' }),
        number: Joi.string()
          .trim()
          .pattern(/^09\d{9}$/) // Pattern for a valid Philippine mobile number starting with '09'
          .messages({ 'string.pattern.base': 'Invalid Mobile No. format' })
          .optional()
          .allow(null),
      }),
      gender: Joi.string().valid('male', 'female', 'other').required(),
    }).required(),
  }).validate(body);

  return error;
};
