require './config'

DataMapper.auto_migrate!

josh = User.new(:username => "josh")
josh.save
josh.set_password "josh"

puts "User table created!"

