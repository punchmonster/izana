local lapis = require('lapis')
local db    = require("lapis.db")
local util  = require('lapis.util')
-- define app
local app   = lapis.Application()

-- enable html views
app:enable('etlua')
app.layout = require 'views.layout'

app:get('/', function(self)
	local content = nil

	function readFile(file, i)
		-- assign file to variable
	    local f = io.open(file, 'rb')
	    -- check if file exists, if not 404
	    if f~=nil then
	    	content = f:read('*all')
	    	f:close()
	    	return content
	    else
	    	return false
	    end
	end
	
	-- array to store the posts in
	self.post_list = {}

	-- for loop to insert posts into array
	for i=1, 11, 1 do
		-- check if there's a post to retrieve
		if readFile('posts/post' .. i .. '.txt', i) ~= false then
			-- read the whole file into a string
			self.post_list[i] = readFile('posts/post' .. i .. '.txt', i) .. '<div class="col-50">&nbsp;</div><div class="col-50" ><a href="/post/' .. i .. '" class="read-more">read more...</a></div>'
		else
			break
		end
	end

	-- set page title
	self.page_title = '{ home }'

	return { render = 'index'}
end)

app:get('/post/:postID', function(self)
	-- variable for storing view output
	local content = nil

	-- function to read the file
	function readFile(file)
		-- assign file to variable
	    local f = io.open(file, 'rb')
	    -- check if file exists, if not 404
	    if f==nil then
	    	content = '<h2>404 page not found</h2>'
	    else
	    	content = f:read('*all')
	    	f:close()
	    end
	    return content
	end

	-- read the whole file into a string
	self.post_content = readFile('posts/post' .. self.params.postID .. '.txt')
	-- set page title
	self.page_title = string.match(self.post_content, '{.-}')

	return { render = 'post'}
end)

app:get('/dbtest', function(self)

	return { render = 'index' }
end)

return app
