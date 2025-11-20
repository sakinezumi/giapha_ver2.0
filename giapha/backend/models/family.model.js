import db from "../config/db.js";

export const FamilyModel = {
  getAll: () => {
    return db.query("SELECT * FROM family_members");
  },

  create: (data) => {
    return db.query("INSERT INTO family_members SET ?", data);
  },

  delete: (id) => {
    return db.query("DELETE FROM family_members WHERE id = ?", [id]);
  }
};
