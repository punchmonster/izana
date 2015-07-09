# Izana
A simple Lua blog/CMS platform built on [Lapis framework](http://leafo.net/lapis/)

## How to run
Simply copy the files anywhere you want and run
```
lapis server
```

## Configure port and database
Default port is set to 80, to change this open `config.lua` and change the key value for port:
```lua
config("development", {
  --change this
  port = 80
})
```
To set up the database connection, edit the block below with your database settings in `config.lua`.
```lua
config("development", {
  mysql = {
    host = "127.0.0.1",
    user = "my_username",
    password = "my_password",
    database = "my_database"
  }
})
```
Also make sure your database has a table named post with these columns:

`| postID  | postdate | posttitle | postcontent | postauthor  |`



## How to use
- needs to be updated
