local lapis = require('lapis')
local db    = require("lapis.db")
local util  = require('lapis.util')
local csrf  = require("lapis.csrf")

-- error capturing
local capture_errors = require("lapis.application").capture_errors

-- define app
local app   = lapis.Application()

-- enable html views
app:enable('etlua')
app.layout = require 'views.layout'


-- main inex page
app:get('/', function(self)

	-- retrieve posts table rowcount
	local row_count   = db.select("COUNT(*) from posts" )

	-- retrieve post list
	self.table_content = db.select("* from posts where postID >= 1 and postID <= ? order by postID DESC", row_count[1]['COUNT(*)'] )

	-- set page title
	self.page_title = 'Izana - home'

	return { render = 'index' }
end)

-- individual article pages
app:get('/post/:postID', function(self)

	-- variable for storing view output
	local postID      = self.params.postID

	-- retrieve all the post information
	local row_content = db.select("* from posts where postID = ?", postID)

	-- pass post information to the MVC
	self.post_content = row_content[1]['postcontent']
	self.post_title   = row_content[1]['posttitle']
	self.post_date    = row_content[1]['postdate']
	self.page_title   = 'Izana - ' .. row_content[1]['posttitle']

	return { render = 'post' }
end)

-- test function for adding test posts to database
app:get('/dbtest', function(self)

	-- retrieve total amount of posts
	local row_count = db.select("COUNT(*) from posts" )

	-- insert the post into the database
	db.insert('posts', {
		postID      = row_count[1]['COUNT(*)'] + 1,
		postdate    = "2015-07-09",
		posttitle   = "about fat",
		postcontent = "This is a testpost, if you read this I hope you get cancer",
		postauthor  = "Jamie Roling"
	})
	return { render = 'index' }
end)

-- submission form page
app:get("form", "/form", function(self)
	self.csrf_token = csrf.generate_token(self)
	self.form_url = self:url_for("form")

	self.page_title = 'Submit a post'
	return { render = 'submit' }
end)

-- handling the form POST submission
app:post("form", "/form", capture_errors(function(self)
	csrf.assert_token(self)

	-- retrieve total amount of posts
	local row_count = db.select("COUNT(*) from posts" )

	-- insert the post into the database
	db.insert('posts', {
		postID      = row_count[1]['COUNT(*)'] + 1,
		postdate    = "2015-07-09",
		posttitle   = self.req.params_post['title'],
		postcontent = self.req.params_post['content'],
		postauthor  = self.req.params_post['author']
	})

	-- response
 	return 'post submitted'
end))

return app
