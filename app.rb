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
  @user_data = User.get(user_id)
  haml :user_details
end

post PAGES[:users] do
  user = User.new(params[:new_user])
  password = "changeme"
  user.password = password
  user.save
  if user.valid?
    flash[:notice] = "New user created with password #{password.inspect}"
    redirect "#{PAGES[:users]}/#{user.id}"
  else
    errors = user.errors.full_messages;
    flash[:error] = "Problem#{errors.length == 1 ? '' : 's'} in creating new user: #{errors.join(', ')}"
    redirect PAGES[:users]
  end  
end

get PAGES[:sets] do
  @sets = Numberset.all
  haml :sets
end

post PAGES[:sets] do
  set = Numberset.new(params[:new_set])  
  set.save
  if set.valid?
    flash[:notice] = "New set created named #{set.name.inspect}"
    redirect "#{PAGES[:sets]}/#{set.id}"
  else
    errors = set.errors.full_messages;
    flash[:error] = "Problem#{errors.length == 1 ? '' : 's'} in creating new set: #{errors.join(', ')}"
    redirect PAGES[:sets]
  end  
end

get "#{PAGES[:sets]}/:set_id" do |set_id|
  @set = Numberset.get(set_id)
  sequences = @set.sequences
  reservations = @set.reservations
  
  # Split the ranges so that they don't overlap the reservations
  reservations.each do |reservation|
    for sequence in sequences do
      if reservation.number == sequence.min
        sequence.min += 1
        break
      elsif reservation.number == sequence.max
        sequence.max -= 1
        break
      elsif reservation.number > sequence.min && reservation.number < sequence.max
        sequences.delete sequence
        sequences << Sequence.new(:min => sequence.min, :max => reservation.number - 1)
        sequences << Sequence.new(:min => reservation.number + 1, :max => sequence.max)
        break
      end
    end
  end
  
  # Merge the two lists and sort
  @set_data = (sequences + reservations).sort do |a, b|
    (a.respond_to?(:number) ? a.number : a.min) <=>
    (b.respond_to?(:number) ? b.number : b.min)
  end
  
  haml :set_details
end

not_found do
  haml :not_found
end


