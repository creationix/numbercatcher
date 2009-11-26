require 'rubygems'
require 'sinatra'
require 'models'
require 'haml'
require 'rack-flash'

use Rack::Session::Cookie, :secret => "3458f7dsoiay3h45hjvfd7862873jfwghf2346"
use Rack::Flash

PAGES = {
  "login" => "/",
  "home" => "/home"
}
 

get PAGES["login"] do
  redirect PAGES["home"] if session[:user_id]
  haml :login
end

post PAGES["login"] do

  user = User.authenticate(params[:username], params[:password])
  session[:user_id] = user ? user.id : nil
  if user
    flash[:notice] = "Login successful"
    redirect PAGES["home"]
  else
    flash[:error] = "Incorrect credentials.  Please try again"
    redirect PAGES["login"]
  end
end

get PAGES['home'] do
  unless session[:user_id]
    flash[:error] = 'Please login first.'
    redirect PAGES["login"]
  end
  haml :home
end