# Load the datamapper library for easy DB access
require 'datamapper'
require 'dm-timestamps'
require 'dm-types'
require 'digest/md5'

# Set up our app to use a local file as a sqlit3 database
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db.sqlite3")


# This is the login information and profile for each user of the system.
# Hash is a hash of the user's password used for authentication.
# Note that password_hash is private, it can be set via password=
class User
  include DataMapper::Resource
  property :id,            Serial
  property :email,         String
  property :name,          String
  property :password_hash, String,  :length => 32, :accessor => :private
  property :is_admin?,     Boolean, :default  => false

  def password= (pass)
    # Not super high security, but a start.
    self.password_hash = Digest::MD5.hexdigest("Number#{pass}Catcher")
  end
  
  has n, :reservations
end

# This represents a set of numbers.  For example, this could be the list of 
# available ports on a given machine.
class Set
  include DataMapper::Resource
  property :id,   Serial
  property :name, String
  property :type, Enum.new("int", "hex")

  has n, :sequences
  has n, :reservations
end

# A number set has several sequences of avialable numbers, this represents a
# single sequence for a set.
class Sequence
  include DataMapper::Resource
  property :id,  Serial
  property :min, Integer
  property :max, Integer

  belongs_to :set
end

# This is the reservation for a particular number for a particular set for a 
# particular user.
class Reservation
  include DataMapper::Resource
  property :id,     Serial
  property :number, Integer

  belongs_to :set
  belongs_to :user
end

# A log of all reservations and releases is stored in this table so that we
# have a history of all transactions in the system.
class Log
  include DataMapper::Resource
  property :id,         Serial
  property :action,     Enum.new("reserve", "release")
  property :note,       String
  property :number,     Integer
  property :created_at, DateTime
  belongs_to :set
  belongs_to :owner,    :model => "User"
  belongs_to :operator, :model => "User"

end

# Create the database with the following line
DataMapper.auto_migrate!

__END__
# Example usage from the command line

tim@macbook:~/Documents/code/numbercatcher$ irb
>> require 'models'
=> true
>> tim = User.new
=> #<User @id=nil @email=nil @name=nil @hash=nil @is_admin=nil>
>> tim.email = "tim@creationix.com"
=> "tim@creationix.com"
>> tim.name = "Tim Caswell"
=> "Tim Caswell"
>> tim.is_admin = true
=> true
>> tim.save!
=> true
>> User.all
=> [#<User @id=1 @email="tim@creationix.com" @name="Tim Caswell" @hash=nil @is_admin=true>]

