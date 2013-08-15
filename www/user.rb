
class User  
    include DataMapper::Resource  
      
    property :id       , Serial  
    property :username , String  
    property :salt     , String
    property :password , String

    def set_password(password)
      salt = BCrypt::Engine.generate_salt
      self.update(
        :salt => salt,
        :password => BCrypt::Engine.hash_secret(password, salt)
      )
    end
end
