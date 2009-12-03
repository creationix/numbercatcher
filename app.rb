require 'rubygems'
require 'sinatra'
require 'models'
require 'haml'
require 'rack-flash'

use Rack::Static, :urls => ["/theme", "/img"], :root => "public"
use Rack::Session::Cookie, :secret => "3458f7dsoiay3h45hjvfd7862873jfwghf2346"
use Rack::Flash

PAGES = {
  :login => "/",
  :logout => "/logout",
  :home => "/home",
  :sets => "/sets",
  :users => "/users",
  :help => "/help"
}
 
configure :test do
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db_test.sqlite3")
  DataMapper.auto_migrate!
end

DataMapper.auto_migrate!

user = User.new(:username => "admin")
user.name = "Admin"
user.password = "password"
user.is_admin = true
user.save


before do
  content_type "text/html", :charset => 'utf-8'
  
  @user = User.get(session[:user_id])
  unless @user || [PAGES[:login], PAGES[:help]].include?(request.path_info)
    flash[:error] = 'Please login first.'
    redirect PAGES[:login]
  end
  if request.path_info == PAGES[:login]
    @links = nil
  elsif @user
    @links = [
      [:home, "My Profile"],
      [:sets, "Number Sets"],
      [:users, "User Administration"],
      [:logout, "Logout"]
    ]
  else
    @links = [
      [:login, "Login"]
    ]
  end
end


get PAGES[:login] do
  redirect PAGES[:home] if @user
  haml :login
end

post PAGES[:login] do

  @user = User.authenticate(params[:username], params[:password])
  session[:user_id] = @user ? @user.id : nil
  if @user
    flash[:notice] = "Login successful"
    redirect PAGES[:home]
  else
    flash[:error] = "Incorrect credentials.  Please try again"
    redirect PAGES[:login]
  end
end

get PAGES[:home] do
  haml :home
end

get PAGES[:help] do
  haml :help
end

get PAGES[:logout] do
  session[:user_id] = nil
  flash[:notice] = 'You have logged out successfully.'
  redirect PAGES[:login]
end

get PAGES[:users] do
  @users = User.all
  haml :users
end

get "#{PAGES[:users]}/:user_id" do |user_id|
  @user = User.get(user_id)
  haml :user_details
end

post PAGES[:users] do
  user = User.new(params[:new_user])
  password = "changeme"
  user.password = password
  user.save
  if user.valid?
    flash[:notice] = "New user created with password #{password.inspect}"
  else
    errors = user.errors.full_messages;
    flash[:error] = "Problem#{errors.length == 1 ? '' : 's'} in creating new user: #{errors.join(', ')}"
  end
  redirect PAGES[:users]
end

not_found do
  haml :not_found
end