import { pool } from "../database/db.js";
import bcrypt from "bcrypt";
import dotenv from "dotenv";

dotenv.config();
export const getUsers = async (req, res) => {
  try {
    const [result] = await pool.query("SELECT * FROM user");
    res.status(200).json(result);
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

export const getUser = async (req, res) => {
  try {
    const [result] = await pool.query("SELECT * FROM user WHERE id = ?", [
      req.params.id,
    ]);
    if (result.length <= 0)
      return res.status(404).json({ message: "User not found" });
    res.status(200).json(result[0]);
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

export const createUser = async (req, res) => {
  try {
    const {
      email,
      password,
      first_name,
      last_name,
      phone,
      photo,
      status,
      type,
    } = req.body;
    // Check if the user already exists
    const [rows] = await pool.query("SELECT * FROM user WHERE email = ?", [
      email,
    ]);
    if (rows.length > 0)
      return res.status(400).json({ message: "User already exists" });
    // Check if phone number is already registered
    const [rowsPhone] = await pool.query("SELECT * FROM user WHERE phone = ?", [
      phone,
    ]);
    if (rowsPhone.length > 0)
      return res
        .status(400)
        .json({ message: "Phone number already registered" });
    const finalPass = await bcrypt.hash(password, SALT_ROUNDS);

    const [result] = await pool.query(
      "INSERT INTO user (email, password, first_name, last_name, phone, photo, status, type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
      [email, finalPass, first_name, last_name, phone, photo, status, type]
    );
    res.status(201).json({ id: result.insertId, email });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

export const updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      email,
      password,
      old_password,
      first_name,
      last_name,
      phone,
      photo,
      status,
      type,
    } = req.body;

    // Check if the user exists
    const [exist] = await pool.query("SELECT * FROM user WHERE id = ?", [id]);
    if (exist.length <= 0)
      return res.status(404).json({ message: "User not found" });

    // If empty, set known values from existing user
    if (email === "") email = rows[0].email;
    if (password === "") password = rows[0].password;
    if (first_name === "") first_name = rows[0].first_name;
    if (last_name === "") last_name = rows[0].last_name;
    if (phone === "") phone = rows[0].phone;
    if (photo === "") photo = rows[0].photo;
    if (status === "") status = rows[0].status;
    if (type === "") type = rows[0].type;

    // check older password with old_password
    const isMatch = await bcrypt.compare(old_password, rows[0].password);
    if (!isMatch)
      return res.status(400).json({ message: "Invalid old password" });

    // encrypt new password
    const finalPass = await bcrypt.hash(password, SALT_ROUNDS);

    const [result] = await pool.query("UPDATE user SET ? WHERE id = ?", [
      {
        email,
        finalPass,
        first_name,
        last_name,
        phone,
        photo,
        status,
        type,
      },
      id,
    ]);
    if (result.affectedRows === 0)
      return res.status(404).json({ message: "User not found" });

    res.status(200).json({ message: "User updated" });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

export const changeUserState = async (req, res) => {
  // delete is logical, status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
  // set status to sent status
  try {
    const { id } = req.params;
    const { status } = req.body;
    // Check if the user exists
    const [exist] = await pool.query("SELECT * FROM user WHERE id = ?", [id]);
    if (exist.length <= 0)
      return res.status(404).json({ message: "User not found" });
    const [result] = await pool.query(
      "UPDATE user SET status = ? WHERE id = ?",
      [status, id]
    );
    if (result.affectedRows === 0)
      return res.status(404).json({ message: "User not found" });
    res.status(200).json({ message: "User state updated" });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};
