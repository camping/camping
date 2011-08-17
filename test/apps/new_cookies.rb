# coding: utf-8

require 'camping-unabridged'


Camping.goes :CookieTest
module CookieTest::Controllers
	class Index
		def get
			"Head to <a href='#{R TestSet}'>TestSet</a> to set cookies." +
			'<br><br>' +
			"Head to <a href='#{R TestGet}'>TestGet</a> to check them."
		end
	end
	
	class TestSet
		def get
			set_cookie :regular, 'val1'
			@cookies[:trying_old_syntax] = 'val2' # this will print a warning to the console
			set_cookie 'expiresin30s', 'val3', :expires=>30
			set_cookie 'expiresv2', 'val4', :expires=>(Time.now+30)
			set_cookie(:hashie, {:a => 5})
			'OK.'
		end
	end
	
	class TestGet
		def get
			@cookies.cookies.inspect
		end
	end
end


