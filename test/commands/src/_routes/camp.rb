require 'camping'

Camping.goes :Nuts

get "/" do
"Hello Friends"
end

get "/accounts" do
"Get Some Accounts"
end

get "/accounts/new" do
"Try my hardest."
end

get "/home", "/about" do
"About page"
end

