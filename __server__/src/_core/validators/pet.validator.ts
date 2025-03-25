import Joi from 'joi';

export const validatoCreatePet = (body: any) => {
    const { error } = Joi.object({
        name: Joi.string().min(2).max(75).required(),
        age: Joi.number().required(),
        gender: Joi.string().valid('male', 'female', 'other').required(),
        breed: Joi.string().required(),
    }).validate(body);

    return error;
};
