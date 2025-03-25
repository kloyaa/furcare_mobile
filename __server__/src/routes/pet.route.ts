import { Router } from 'express';
import { isAuthenticated } from '../_core/middlewares/jwt.middleware';
import { isValidUser } from '../_core/middlewares/is_valid_user.middleware';
import { isPetOwner } from '../_core/middlewares/is_pet_owner.middleware';
import { createPet, getPetsByAccessToken, updatePetByAccessToken } from '../controllers/pet.controller';
import { isProfileCreated } from '../_core/middlewares/is_profile_created.middleware';

const router = Router();

const commonMiddlewares = [
    isAuthenticated,
    isValidUser,
    isPetOwner,
    isProfileCreated
];

router.post('/pet/v1/me', commonMiddlewares, createPet as any);
router.get('/pet/v1/me', commonMiddlewares, getPetsByAccessToken as any);
router.put('/pet/v1/me', commonMiddlewares, updatePetByAccessToken as any);

export default router;
