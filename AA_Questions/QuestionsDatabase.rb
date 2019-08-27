require 'sqlite3'
require 'singleton'
require 'byebug' 

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
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT 
       *
      FROM 
        users 
      WHERE 
        users.id = ? 
    SQL

    Users.new(*data) 
  end

  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT 
       *
      FROM 
        users 
      WHERE 
        users.fname = ? AND users.lname = ?  
    SQL

    Users.new(*data) 
  end
  
  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(self.id)
  end

  def authored_replies
    Replies.find_by_author_id(self.id)
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
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT 
       *
      FROM 
        questions 
      WHERE 
        questions.id = ? 
    SQL

    Questions.new(*data) 
  end
  
  def self.find_by_author_id(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT 
       *
      FROM 
        questions
      WHERE 
        questions.authors_id = ? 
    SQL

    Questions.new(*data) 
  end
  
  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end
  
  def author
    Users.find_by_id(self.author_id)
  end

  def replies 
    Replies.find_by_question_id(self.id)
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


class QuestionFollows 
  attr_accessor :id, :follower_id, :question_id 

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
    data.map { |datum|  QuestionFollows.new(datum) }
  end
  
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT 
       *
      FROM 
        question_follows
      WHERE 
        question_follows.id = ? 
    SQL

    QuestionFollows.new(*data) 
  end

  
  def initialize(options)
    @id = options['id']
    @follower_id = options['follower_id']
    @question_id = options['question_id']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionFollows.instance.execute(<<-SQL, @follower_id, @question_id)
      INSERT INTO
        questions (follower_id, question_id)
      VALUES 
        (?,?)
    SQL
    @id = QuestionFollows.instance.last_insert_row_id
  end

end


class Replies
  attr_accessor :id, :question_id, :parent_reply_id, :author_id, :body

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    data.map { |datum|  Replies.new(datum) }
  end
  
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT 
       *
      FROM 
        replies
      WHERE 
        replies.id = ? 
    SQL

    Replies.new(*data) 
  end

  def self.find_by_author_id(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT 
       *
      FROM 
        replies
      WHERE 
        replies.author_id = ? 
    SQL

    Replies.new(*data) 
  end

  def self.find_by_question_id(question_id)
     data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT 
       *
      FROM 
        replies
      WHERE 
        replies.question_id = ? 
    SQL

    Replies.new(*data) 
  end
  
  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
    @author_id = options['author_id']
    @body = options['body']
  end

  def author
    Users.find_by_id(self.author_id)
  end

  def question
    Questions.find_by_author_id(self.author_id)
  end

  def parent_reply
    Replies.find_by_id(self.parent_reply_id)
  end
  
  def child_reply 
    data = QuestionsDatabase.instance.execute(<<-SQL, self.id)
      SELECT 
       *
      FROM 
        replies
      WHERE 
        replies.parent_id = ?
    SQL

    data.map { |datum| Replies.new(datum) }
  end

  def create
    raise "#{self} already in database" if @id
    Replies.instance.execute(<<-SQL, @question_id, @parent_reply_id, @author_id, @body)
      INSERT INTO
       replies(question_id, parent_reply_id, author_id, body)
      VALUES 
        (?,?,?,?)
    SQL
    @id = Replies.instance.last_insert_row_id
  end

end

class QuestionLikes
  attr_accessor :id, :user_id, :question_id 

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
    data.map { |datum|  QuestionLikes.new(datum) }
  end
  
  def self.find_by_id(id)
    QuestionLikes.all.each do |question_like|
      return question_like if question_like.id == id
    end
  end
  
  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionLikes.instance.execute(<<-SQL, @user_id, @question_id)
      INSERT INTO
       question_likes (user_id, question_id)
      VALUES 
        (?,?)
    SQL
    @id = QuestionLikes.instance.last_insert_row_id
  end

end