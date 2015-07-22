-- libraries
local lapis = require('lapis')
local db    = require('lapis.db')
local util  = require('lapis.util')
local csrf  = require('lapis.csrf')
local md5   = require('lib.md5')

-- error capturing
local capture_errors = require('lapis.application').capture_errors

-- define app
local app   = lapis.Application()

-- enable html views
app:enable('etlua')
app.layout = require 'views.layout'

-- main index page
app:match('index', '/', function(self)

	-- retrieve posts table rowcount
	local row_count    = db.select('COUNT(*) from posts')

	-- retrieve post list
	self.table_content = db.select('* from posts order by postID DESC limit 10', row_count[1]['COUNT(*)'] )

	-- set page info
	self.page_title = 'Izana - home'
	self.page_author = 'Jamie Röling'

	return { render = 'index' }
end)

-- individual article pages
app:match('/post/:postID', function(self)

	-- variable for storing view output
	local postID      = self.params.postID

	-- retrieve all the post information
	local row_content = db.select('* from posts where postID = ?', postID)

	-- pass post information to the MVC
	self.post_content = row_content[1]['postcontent']
	self.post_title   = row_content[1]['posttitle']
	self.post_date    = row_content[1]['postdate']
	self.post_ID      = row_content[1]['postID']

	-- set page info
	self.page_title   = 'Izana - ' .. row_content[1]['posttitle']
	self.page_author  = row_content[1]['postauthor']

	return { render = 'post' }
end)

-- submission form page
app:get('submit', '/submit', function(self)
	self.csrf_token = csrf.generate_token(self)
	self.submit_url = self:url_for('submit')

	-- set page info
	self.page_title = 'Izana - submit a post'
	self.page_author = 'Jamie Röling'

	-- check if person is logged in
	if self.cookies.izana_session == 'ok' then

		return { render = 'submit' }
	else
		return { redirect_to = self:url_for('login') }
	end
end)

-- handling the form POST submission
app:post('submit', '/submit', capture_errors(function(self)
	csrf.assert_token(self)

	-- check session
	if self.cookies.izana_session == 'ok' then

		-- check latest post ID
		local row_info  = db.select('* from posts order by postID DESC limit 1' )

		-- insert the post into the database
		db.insert('posts', {
			postID      = row_info[1]['postID'] + 1,
			postdate    = ngx.time(),
			posttitle   = self.req.params_post['title'],
			postcontent = self.req.params_post['content'],
			postauthor  = self.req.params_post['author']
		})

		-- response
		return 'post submitted'
	else
	 	return { redirect_to = self:url_for('login') }
	end
end))

-- login page
app:get('login', '/login', function(self)
	self.csrf_token  = csrf.generate_token(self)
	self.submit_url  = self:url_for('login')

	-- set page info
	self.page_title  = 'Izana - login'
	self.page_author = 'Jamie Röling'

	-- check if the client is logged in
	if self.cookies.izana_session == 'ok' then

		-- if logged in, redirect to posting window
		return { redirect_to = self:url_for('submit') }
	else
		return { render = 'login' }
	end
end)

-- handling the login POST submission
app:post('login', '/login', capture_errors(function(self)
	csrf.assert_token(self)

	-- retrieve user information from database
	local user_info = db.select('* from users where username = ?', string.lower( self.req.params_post['username'] ) ) 

	-- check if submitted password matches database
	if md5.sumhexa( self.req.params_post['password'] ) == user_info[1]['password'] then
		
		-- create
		self.cookies.izana_session = 'ok'

		-- redirect to submit page
	 	return { redirect_to = self:url_for('submit') }
	 else
	 	-- if password is wrong, redirect to login
	 	return { redirect_to = self:url_for('login') }
	 end
end))

return app
