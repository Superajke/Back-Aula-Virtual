import { pool } from "../db.js";

export const getUsers = async (req, res) => {
  try {
    const [result] = await pool.query("SELECT * FROM user");
    res.status(200).json(result);
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};
