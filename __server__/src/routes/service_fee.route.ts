import { Router } from 'express';
import { isAuthenticated } from '../_core/middlewares/jwt.middleware';
import { getServiceFees, updateServiceFeeById } from '../controllers/service_fee.controller';
const router = Router();

const commonMiddlewares = [
    isAuthenticated
];

router.get('/service/v1/fees', commonMiddlewares, getServiceFees as any);
router.put('/service/v1/fees/:_id', commonMiddlewares, updateServiceFeeById as any);

export default router;