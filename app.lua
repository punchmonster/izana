local lapis = require('lapis')
local db    = require("lapis.db")
local util  = require('lapis.util')
local csrf  = require("lapis.csrf")

-- error capturing
local capture_errors = require("lapis.application").capture_errors

-- define app
local app   = lapis.Application()

-- self.post_author = 'Jamie Röling'

-- enable html views
app:enable('etlua')
app.layout = require 'views.layout'

-- runs before action
app.__class:before_filter(function(self)
	
	-- set page defaults
	self.page_title = 'Poopy Pants'
end)

-- main index page
app:match('index', '/', function(self)

	-- retrieve posts table rowcount
	local row_count   = db.select("COUNT(*) from posts" )

	-- retrieve post list
	self.table_content = db.select("* from posts where postID >= 1 and postID <= ? order by postID DESC", row_count[1]['COUNT(*)'] )

	-- set page title
	self.page_title = 'Izana - home'

	return { render = 'index' }
end)

-- individual article pages
app:match('/post/:postID', function(self)

	-- variable for storing view output
	local postID      = self.params.postID

	-- retrieve all the post information
	local row_content = db.select("* from posts where postID = ?", postID)

	-- pass post information to the MVC
	self.post_content = row_content[1]['postcontent']
	self.post_title   = row_content[1]['posttitle']
	self.post_date    = row_content[1]['postdate']
	self.page_title   = 'Izana - ' .. row_content[1]['posttitle']
	self.page_author  = row_content[1]['postauthor']

	return { render = 'post' }
end)

-- submission form page
app:get("submit", "/submit", function(self)
	self.csrf_token = csrf.generate_token(self)
	self.submit_url = self:url_for("submit")

	--page title
	self.page_title = 'Izana - submit a post'
	return { render = 'submit' }
end)

-- handling the form POST submission
app:post("submit", "/submit", capture_errors(function(self)
	csrf.assert_token(self)

	if self.req.params_post['password'] == 'dickbutt' then

		-- retrieve total amount of posts
		local row_count = db.select("COUNT(*) from posts" )

		-- insert the post into the database
		db.insert('posts', {
			postID      = row_count[1]['COUNT(*)'] + 1,
			postdate    = ngx.time(),
			posttitle   = self.req.params_post['title'],
			postcontent = self.req.params_post['content'],
			postauthor  = self.req.params_post['author']
		})

		-- response
	 	return 'post submitted'
	 else
	 	return { redirect_to = self:url_for("submit") }
	 end
end))

return app
