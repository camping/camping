require 'camping'

Camping.goes :ForwardToOtherController

module ForwardToOtherController

	module Controllers
	
		class Index < R '/'
			attr_accessor :msg
			
			def get
				puts "msg=#{@msg}" 
				puts "input=#{input.inspect}"
				render :index
			end
		end
			
		class Start < R '/start'
			def get
				render :start
			end
		end

		class Welcome < R '/welcome'
			def post
				if input.name == '_why'
					msg = "Wow you're back _why! This is front-page news!"
					r *ForwardToOtherController.get(:Index, :msg => msg, :input => input  )
				end
				
				@result = "Welcome #{input.name}!"
				render :welcome
			end
		end
		
	end
	
	module Views
		def index
			h1 @msg if @msg && !@msg.empty?
			a "Start", :href=> "/start"
		end
		
		def start
			h3 "Start"
			
			form :action=>R(Welcome), :method=>:post do
				label "Who are you?", :for=>:name
				div "Note: type _why if you want to test the forward logic otherwise just type your name", :style=>"color:green;font-size:8pt;"
				input :type=>:text, :name=>:name; br		 
				input :type=>:submit
			end			
		end
		
		def welcome
			div "#{@result}"
		end
	end
end
