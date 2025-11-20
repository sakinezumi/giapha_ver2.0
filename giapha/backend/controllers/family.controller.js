import { FamilyModel } from "../models/family.model.js";

export const FamilyController = {
  getAll: async (req, res) => {
    try {
      const [rows] = await FamilyModel.getAll();
      res.json(rows);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  },

  create: async (req, res) => {
    try {
      await FamilyModel.create(req.body);
      res.json({ message: "Created!" });
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  },

  delete: async (req, res) => {
    try {
      await FamilyModel.delete(req.params.id);
      res.json({ message: "Deleted!" });
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  }
};
