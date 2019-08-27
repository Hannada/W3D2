require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize 
    super('questions.db')
    self.type_translation
    self.results_as_hash = true
  end
end

class Users
  attr_accessor :id, :fname, :lname 
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM users")
    data.map { |datum| Users.new(datum) }
  end
  
  def self.find_by_id(id)
    Users.all.each do |user|
      return user if user.id == id
    end
  end

  def self.find_by_name(fname, lname)
    Users.all.each do |user|
      return user if user.fname == fname && user.lname == lname 
    end
  end
  
  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users (fname, lname)
      VALUES 
        (?,?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

end

class Questions 
  attr_accessor :id, :title, :body, :author_id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    data.map { |datum| Questions.new(datum) }
  end
  
  def self.find_by_id(id)
    Questions.all.each do |question|
      return question if question.id == id
    end
  end

  # def self.find_by_name(fname, lname)
  #   Questions.all.each do |question|
  #     return question if question.fname == fname && question.lname == lname 
  #   end
  # end
  
  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id)
      INSERT INTO
        questions (title, body, author_id)
      VALUES 
        (?,?,?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

end

