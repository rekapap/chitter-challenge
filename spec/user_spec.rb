require 'user'
require 'test_helpers'

describe User do
  describe '.create' do
    it 'creates a new user' do
      user = User.create(name: 'John', username: 'john', email: 'john@example.com', password: 'password123')

      persisted_data = persisted_data(id: user.id, table: 'users')

      expect(user).to be_a User
      expect(user.id).to eq persisted_data.first['id']
      expect(user.name).to eq 'John'
      expect(user.username).to eq 'john'
      expect(user.email).to eq 'john@example.com'
    end

    it "returns USERNAME_ALREADY_IN_USE constant and doesn't create user if username already exsist" do
      User.create(name: 'John', username: 'john', email: 'john@example.com', password: 'password123')
      result = User.create(name: 'Johhny', username: 'john', email: 'johhny@example.com', password: 'password123')
      expect(result).to eq User::USERNAME_ALREADY_IN_USE

      # returns all users' data
      users = DatabaseConnection.query("SELECT * FROM users").to_a
      expect(users.length).to eq 1
    end

    it "returns EMAIL_ALREADY_IN_USE constant and doesn't create user if email already exsist" do
      User.create(name: 'John', username: 'john', email: 'test@example.com', password: 'password123')
      result = User.create(name: 'Jane', username: 'jane', email: 'test@example.com', password: 'password123')
      expect(result).to eq User::EMAIL_ALREADY_IN_USE

      # returns all users' data
      users = DatabaseConnection.query("SELECT * FROM users").to_a
      expect(users.length).to eq 1
    end

    it 'hashes the password using BCrypt' do
      expect(BCrypt::Password).to receive(:create).with('password123')
      User.create(name: 'User', username: 'user1', email: 'test@example.com', password: 'password123')
    end
  end

  describe '.find' do
    it 'finds user by database column and value' do
      User.create(name: 'John', username: 'john', email: 'john@example.com', password: 'password123')
      jane = User.create(name: 'Jane', username: 'jane', email: 'jane@example.com', password: 'password123')
  
      result = User.find(column: 'username', value: 'jane') 
      expect(jane.id).to eq result.id
    end

    it 'returns nil if column is nil' do
      User.create(name: 'John', username: 'john', email: 'john@example.com', password: 'password123')
      result = User.find(column: nil, value: 'John') 
      expect(result).to eq nil
    end

    it 'returns nil if no such user' do
      User.create(name: 'John', username: 'john', email: 'john@example.com', password: 'password123')
      result = User.find(column: 'username', value: 'test') 
      expect(result).to eq nil
    end
  end

  describe '.authenticate' do
    it 'returns the user if username and password match' do
      user = User.create(name: 'John', username: 'john', email: 'john@example.com', password: 'password123')
      authenticated_user = User.authenticate(username: 'john', password: 'password123')

      expect(authenticated_user).to be_a User
      expect(authenticated_user.id).to eq user.id
      expect(authenticated_user.name).to eq 'John'
      expect(authenticated_user.username).to eq 'john'
      expect(authenticated_user.email).to eq 'john@example.com'
    end

    it 'returns nil if username doesn\'t exsists' do
      User.create(name: 'John', username: 'john', email: 'john@example.com', password: 'password123')
      authenticated_user = User.authenticate(username: 'wrongjohn', password: 'password123')

      expect(authenticated_user).to eq nil
    end

    it 'returns nil if the password doesn\'t match' do
      User.create(name: 'John', username: 'john', email: 'john@example.com', password: 'password123')
      authenticated_user = User.authenticate(username: 'john', password: 'wrongpassword')

      expect(authenticated_user).to eq nil
    end
  end

  describe '#peeps' do
    it 'calls Peep.where' do
      john = User.create(name: 'John', username: 'john', email: 'john@example.com', password: 'password123')
      Peep.create(text: "Johns peep", user_id: john.id)
      expect(Peep).to receive(:where).with(user_id: john.id)
      john.peeps
    end
  end
end
