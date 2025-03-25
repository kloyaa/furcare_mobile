import Joi from "joi";
import { isObjectIdOrHexString } from "mongoose";
import { BookingStatus, UploadContentScope, UploadContentType } from "../enum/booking.enum";

export const validateCreateBoardingApplication = (body: any) => {
    const { error } = Joi.object({
        schedule: Joi.date().required(),
        daysOfStay: Joi.number().required(),
        cage: Joi
            .string()
            .custom((value, helpers) => {
                if (!isObjectIdOrHexString(value)) {
                    return helpers.error('any.invalid');
                }
                return value;
            })
            .required(),
        pet: Joi
            .string()
            .custom((value, helpers) => {
                if (!isObjectIdOrHexString(value)) {
                    return helpers.error('any.invalid');
                }
                return value;
            })
            .required(),
    }).validate(body);

    return error;
};

export const validateCreateTransitApplication = (body: any) => {
    const { error } = Joi.object({
        schedule: Joi.date().iso().required(),
        pet: Joi
            .string()
            .custom((value, helpers) => {
                if (!isObjectIdOrHexString(value)) {
                    return helpers.error('any.invalid');
                }
                return value;
            })
            .required(),
    }).validate(body);

    return error;
};


export const validateUpdateBookingStatusById = (body: any) => {
    const { error } = Joi.object({
        status: Joi.string().valid(
            BookingStatus.Cancel,
            BookingStatus.Confirmed,
            BookingStatus.Declined,
            BookingStatus.Done,
            BookingStatus.Pending
        ).required(),
        booking: Joi
            .string()
            .custom((value, helpers) => {
                if (!isObjectIdOrHexString(value)) {
                    return helpers.error('any.invalid');
                }
                return value;
            })
            .required(),
    }).validate(body);

    return error;
};

export const validateUploadImages = (body: any) => {
    const { error } = Joi.object({
        uploadContentScope: Joi.string().valid(
            UploadContentScope.Avatar,
            UploadContentScope.QRCode,
        ).required(),
        uploadContentType: Joi.string().valid(
            UploadContentType.Image,
            UploadContentType.Video,
        ).required(),
    }).validate(body);

    return error;
};