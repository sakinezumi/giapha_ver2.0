import express from "express";
import { FamilyController } from "../controllers/family.controller.js";

const router = express.Router();

router.get("/", FamilyController.getAll);
router.post("/", FamilyController.create);
router.delete("/:id", FamilyController.delete);

export default router;
