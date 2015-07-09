local lapis = require('lapis')
local db    = require("lapis.db")
local util  = require('lapis.util')
-- define app
local app   = lapis.Application()

-- enable html views
app:enable('etlua')
app.layout = require 'views.layout'

app:get('/', function(self)
	-- retrieve posts table rowcount
	local row_count   = db.select("COUNT(*) from posts" )
	-- retrieve post list
	self.table_content = db.select("* from posts where postID >= 1 and postID <= ? order by postID DESC", row_count[1]['COUNT(*)'] )

	-- set page title
	self.page_title = 'Izana - home'

	return { render = 'index'}
end)

app:get('/post/:postID', function(self)
	-- variable for storing view output
	local postID = self.params.postID

	local row_content = db.select("* from posts where postID = ?", postID)
	-- call database
	self.post_content = row_content[1]['postcontent']
	self.post_title   = row_content[1]['posttitle']
	self.page_title   = 'Izana - ' .. row_content[1]['posttitle']

	return { render = 'post'}
end)

app:get('/dbtest', function(self)
	local row_count   = db.select("COUNT(*) from posts" )

	db.insert('posts', {
		postID = row_count[1]['COUNT(*)'] + 1,
		postdate = "2015-07-09",
		posttitle = "about fat",
		postcontent = "This is a testpost, if you read this I hope you get cancer",
		postauthor = "Jamie Roling"
	})
	return { render = 'index' }
end)

return app
