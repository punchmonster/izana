-- config.lua
local config = require("lapis.config")

config("development", {
  port = 80
})
config("development", {
  mysql = {
    host = "127.0.0.1",
    user = "my_user",
    password = "my_pass",
    database = "izanaDB"
  }
})