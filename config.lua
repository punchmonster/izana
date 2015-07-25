-- config.lua
local config = require("lapis.config")

config("development", {
  port = 80
})

config("development", {
  secret = "secret"
})

config("development", {
  mysql = {
    host = "127.0.0.1",
    user = "root",
    password = "password",
    database = "izanaDB"
  }
})
