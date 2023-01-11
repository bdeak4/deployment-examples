const express = require("express");
const os = require("os");

require("dotenv").config();

const app = express();

app.get("/", (req, res) => {
  res.send({ message: process.env.MESSAGE, hostname: os.hostname() });
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
