import { Router } from 'express';
import { isAuthenticated } from '../_core/middlewares/jwt.middleware';
import { getPetOwnerByAccessToken, savePetOwner, updatePetByAccessToken } from '../controllers/pet_owner.controller';
import { isValidUser } from '../_core/middlewares/is_valid_user.middleware';
import { isProfileCreated } from '../_core/middlewares/is_profile_created.middleware';
import { isPetOwner } from '../_core/middlewares/is_pet_owner.middleware';

const router = Router();

const commonMiddlewares = [
    isAuthenticated,
    isValidUser,
    isPetOwner
    // isProfileCreated
];

router.post('/owner/v1', commonMiddlewares, savePetOwner as any);
router.get('/owner/v1/me', commonMiddlewares, getPetOwnerByAccessToken as any);
// router.get('/pet-owner/v1/data', commonMiddlewares, getPetOwnersData as any);
// router.get('/pet-owner/v1/me', commonMiddlewares, getPetOwnersByUserId as any);
// router.get('/pet-owner/v1/s/:_id', commonMiddlewares, getPetOwnerDetailsByUserId as any);
router.put('/owner/v1/me', commonMiddlewares, updatePetByAccessToken as any);
// router.put('/pet-owner/v1/:_id', commonMiddlewares, updatePetOwnerDetailsById as any);

export default router;
