require 'rubygems'
require 'sinatra'
require 'models'
require 'haml' 
require 'rack-flash'

use Rack::Static, :urls => ["/theme", "/img"], :root => "public"
use Rack::Session::Cookie, :secret => "3458f7dsoiay3h45hjvfd7862873jfwghf2346"
use Rack::Flash
 
configure :test do
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db_test.sqlite3")
  DataMapper.auto_migrate!
end

# # Uncomment to reset the database
# DataMapper.auto_migrate!
# 
# user = User.new(:username => "admin")
# user.name = "Admin"
# user.password = "password"
# user.is_admin = true
# user.save

# Set up session and basic security
before do
  content_type "text/html", :charset => 'utf-8'
  
  @user = User.get(session[:user_id])
  unless @user || ["/", "/help"].include?(request.path_info)
    flash[:error] = 'Please login first.'
    redirect "/"
  end
  if request.path_info == "/"
    @links = nil
  elsif @user
    @links = [
      ["/users/#{@user.id}", "My Profile"],
      ["/sets", "Number Sets"],
      ["/users", @user.is_admin ? "User Administration" : "User Profiles"],
      ["/logout", "Logout"]
    ]
  else
    @links = [
      ["/", "Login"]
    ]
  end
end

# Show login page
get "/" do
  redirect "/users/#{@user.id}" if @user
  @title = "Please Login"
  haml :login
end

# Process login request
post "/" do

  @user = User.authenticate(params[:username], params[:password])
  session[:user_id] = @user ? @user.id : nil
  if @user
    flash[:notice] = "Login successful"
    redirect "/users/#{@user.id}"
  else
    flash[:error] = "Incorrect credentials.  Please try again"
    redirect "/"
  end
end

# Process logout request
get "/logout" do
  session[:user_id] = nil
  flash[:notice] = 'You have logged out successfully.'
  redirect "/"
end

# Show online documentation
get "/help" do
  @title = "Online Documentation"
  haml :help
end

# List all users
get "/users" do
  @title = @user.is_admin ? "User administration" : "User Listing"
  @users = User.all
  haml :users
end

# Create a new user
post "/users" do
  
  unless @user.is_admin
    flash[:error] = "You are not authorized to add new users"
    redirect "/users"
  else    
    user = User.new(params[:new_user])
    password = "changeme"
    user.password = password
    user.save
    if user.valid?
      flash[:notice] = "New user created with password #{password.inspect}"
      redirect "/users/#{user.id}"
    else
      errors = user.errors.full_messages;
      flash[:error] = "Problem#{errors.length == 1 ? '' : 's'} in creating new user: #{errors.join(', ')}"
      redirect "/users"
    end
  end    
end

# Show details for a user
get "/users/:user_id" do |user_id|
  @user_data = User.get(user_id)
  @title = @user.id == @user_data.id ? "My Profile" : "#{@user_data.name}'s Profile"
  haml :user_details
end

# Update details for a user
put "/users/:user_id" do |user_id|
  user_data = params[:user]
  unless user_id.to_i == @user.id || @user.is_admin
    flash[:error] = "You are not authorized to do this"
  else 
    if user_data[:password] != user_data[:password2]
      flash[:error] = "Passwords do not match"
    else
      edit_user = User.get(user_id)
      unless user_data[:password] == ""
        edit_user.password = user_data[:password]
      end  

      edit_user.username = user_data[:username]
      edit_user.name = user_data[:name]
      edit_user.is_admin = user_data[:is_admin] if @user.is_admin
      edit_user.save
     
      if edit_user.valid?
        flash[:notice] = "User data successfully saved"
      else
        errors = edit_user.errors.full_messages;
        flash[:error] = "Problem#{errors.length == 1 ? '' : 's'} in updating user: #{errors.join(', ')}"
      end
    end    
  end     
  redirect "/users/#{user_id}"  
end

# Delete a user
delete "/users/:user_id" do |user_id|
  @user_data = User.get(user_id)
  unless @user.is_admin && @user_data.id != @user.id
    flash[:error] = "You are not authorized to delete the #{@user_data.username.inspect} user."
  else
    flash[:notice] = "Successfully deleted the #{@user_data.username.inspect} user."
    @user_data.destroy!
  end
  redirect "/users"
end

# Release a reservation
delete "*/reservations/:reservation_id" do |redirect, reservation_id|
  reservation = Reservation.get(reservation_id)
  if reservation
    unless reservation.user.id == @user.id || @user.is_admin
      flash[:error] = "You are not authorized release this reservation!"
    else
      reservation.destroy!
      flash[:notice] = "Reservation deleted!"
    end
  else
    flash[:error] = "Invalid reservation cannot be deleted!"
  end
  redirect redirect
end

# List all number sets
get "/sets" do
  @title = "Critical Number Sets"
  @sets = Numberset.all
  haml :sets
end

# Create a new number set
post "/sets" do
  set = Numberset.new(params[:new_set])  
  set.save
  if set.valid?
    flash[:notice] = "New set created named #{set.name.inspect}"
    redirect "/sets/#{set.id}"
  else
    errors = set.errors.full_messages;
    flash[:error] = "Problem#{errors.length == 1 ? '' : 's'} in creating new set: #{errors.join(', ')}"
    redirect "/sets"
  end  
end

# Get details about a single number set
get "/sets/:set_id" do |set_id|
  @set = Numberset.get(set_id)
  @title = "Details for the #{@set.name.inspect} set"
  sequences = @set.sequences
  reservations = @set.reservations
  
  # Split the ranges so that they don't overlap the reservations
  reservations.each do |reservation|
    for sequence in sequences do
      if reservation.number == sequence.min
        if sequence.min == sequence.max
          sequences.delete sequence
        else
          sequence.min += 1
        end
        break
      elsif reservation.number == sequence.max
        if sequence.min == sequence.max
          sequences.delete sequence
        else
          sequence.max -= 1
        end
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

# Create a new number reservation
post "/sets/:set_id/reservations" do |set_id|
  set = Numberset.get(set_id)
  number = set.type == 'ip' ? params["number"].from_ip : params["number"].to_i
  
  # Find the next available number
  if params[:autoreserve]
    res = set.reservations
    seqs = set.sequences
    for seq in seqs
      ((seq.min)..(seq.max)).each do |n|
        if res.none? { |reservation| reservation.number == n }
          number = n
          break
        end
      end
    end
  end
  
  reservation = Reservation.new(:number => number, :note => params["note"])
  reservation.numberset_id = set_id
  reservation.user_id = @user.id
  reservation.save
  if reservation.valid?
    flash[:notice] = "Successfully reserved #{reservation.formatted_number}."
  else
    errors = reservation.errors.full_messages;
    flash[:error] = "Problem#{errors.length == 1 ? '' : 's'} in reserving number #{reservation.formatted_number}: #{errors.join(', ')}"
  end
  
  redirect "/sets/#{set_id}"

end

# Modify the range of available numbers
post "/sets/:set_id/sequences" do |set_id|
  unless @user.is_admin
    flash[:error] = "You are not authorized to modify the range of this set."
    redirect "/sets/#{set_id}/"
    next
  end
  if params["min"] == ""
    flash[:error] = "Please enter at least a start to the range."
    redirect "/sets/#{set_id}/"
    next
  end
  
  set = Numberset.get(set_id)

  min = set.type == 'ip' ? params["min"].from_ip : params["min"].to_i
  max = set.type == 'ip' ? params["max"].from_ip : params["max"].to_i
  if min > max
    flash[:error] = "The min number should be greater than the max number."
    redirect "/sets/#{set_id}/"
    next
  end

  
  if params["remove"]
    set.sequences.each do |sequence|
      if min <= sequence.min && max >= sequence.max
        sequence.destroy!
      elsif min <= sequence.min && max >= sequence.min
        sequence.min = max + 1
        sequence.save
      elsif min <= sequence.max && max >= sequence.max
        sequence.max = min - 1
        sequence.save
      elsif min > sequence.min && max < sequence.max
        # Split a range in two
        s = Sequence.new(:min => max + 1, :max => sequence.max, :numberset_id => set_id)
        s.save
        sequence.max = min - 1
        sequence.save
      end
    end
  elsif params["add"]
    added = false
    set.sequences.each do |sequence|
      # Merge with any existing ranges that overlap and destroy them
      if sequence.min <= max + 1 && sequence.max >= min - 1
        max = sequence.max if sequence.max > max
        min = sequence.min if sequence.min < min
        sequence.destroy!
      end
    end
    s = Sequence.new(:min => min, :max => max, :numberset_id => set_id)
    s.save
  end
  
  redirect "/sets/#{set_id}"

end

# 404 fallback
not_found do
  haml :not_found
end

# Patch Fixnum and String to make easy conversion between IP address strings
# and IP address integers
class Integer
  def to_ip
    address = self
    [24, 16, 8, 0].collect {|b| (address >> b) & 255}.join('.')
  end
end

class String
  def from_ip
    self.split('.').inject(0) {|total,value| (total << 8 ) + value.to_i}
  end
end

    
  
    