import { Router } from 'express';
import { isAuthenticated } from '../_core/middlewares/jwt.middleware';
import { isPetOwner } from '../_core/middlewares/is_pet_owner.middleware';
import { createBoardingApplication } from '../controllers/boarding_application.controller';
import { isProfileCreated } from '../_core/middlewares/is_profile_created.middleware';

const router = Router();

const commonMiddlewares = [
    isAuthenticated,
    isPetOwner,
    isProfileCreated
];

router.post('/application/v1/boarding', commonMiddlewares, createBoardingApplication as any);

export default router;