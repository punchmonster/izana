# Izana
A simple blog/CMS platform built on [Lapis framework](http://leafo.net/lapis/)

## How to run
Simply copy the files anywhere you want and run
```
lapis server
```

## Configure port
Default port is set to 80, to change this open `config.lua` and change the key value for port:
```
config("development", {
  --change this
  port = 80
})
```

## How to use
Simply use one of the text files in `/posts` as a template for your blog post.
