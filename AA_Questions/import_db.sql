PRAGMA foreign_keys = ON;

DROP TABLE if EXISTS question_likes; 
DROP TABLE if EXISTS replies; 
DROP TABLE if EXISTS question_follows; 
DROP TABLE if EXISTS questions; 
DROP TABLE if EXISTS users; 

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL 
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER,

  FOREIGN KEY (author_id) REFERENCES users(id) 
); 

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  follower_id INTEGER, 
  question_id INTEGER,

  FOREIGN KEY (follower_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY, 
  question_id INTEGER NOT NULL,
  parent_reply_id INTEGER, 
  author_id INTEGER NOT NULL, 
  body TEXT NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY (author_id) REFERENCES users(id)

);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  users_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (users_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Lisa', 'Li'),
  ('Dave', 'Hanna'),
  ('Bob', 'Johnson');

INSERT INTO 
  questions (title, body, author_id)
VALUES 
  ('send help', 'please?', (SELECT id FROM users WHERE fname =  'Lisa' AND lname = 'Li')),
  ("send snacks", "please?", (SELECT id FROM users WHERE fname = 'Dave')),
  ("send code", "please?", (SELECT id FROM users WHERE fname = 'Bob'));

INSERT INTO 
  question_follows (follower_id, question_id)

VALUES 
  ((SELECT id FROM users WHERE fname ='Lisa'), (SELECT id FROM questions WHERE title = 'send snacks')),
  ((SELECT id FROM users WHERE fname ='Dave'), (SELECT id FROM questions WHERE title = 'send code')),
  ((SELECT id FROM users WHERE fname ='Dave'), (SELECT id FROM questions WHERE title = 'send help'));

  INSERT INTO 
    replies (question_id, parent_reply_id, author_id, body)

  VALUES 
  ((SELECT id FROM questions WHERE title = 'send help'), 
    (SELECT id FROM replies WHERE parent_reply_id = NULL),
      (SELECT id FROM users WHERE fname = 'Lisa'),
        'aaaaaaaaa' 

    );

  INSERT INTO 
    question_likes (users_id, question_id)
  VALUES 
  ((SELECT id FROM users WHERE fname ='Dave'), (SELECT id FROM questions WHERE title = 'send help'));
    
    

