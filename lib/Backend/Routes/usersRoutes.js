const express = require("express");
const { loginUser, registerUser, getUsers } = require("../Controllers/usersControllers");

const router = express.Router();

router.post("/register", registerUser);

router.post("/login", loginUser);

router.get('/', getUsers);

module.exports = router;
