class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name, @breed, @id = name, breed, id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?);
    SQL
    DB[:conn].execute(sql, name, breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:, breed:)
    new_dog = Dog.new(name: name, breed: breed)
    new_dog.save
  end

  def self.new_from_db(row)
    hash = {
      id: row[0],
      name: row[1],
      breed: row[2]
    }
    Dog.new(hash)
  end

  def self.find_by_id(id)
    Dog.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0])
  end

  def self.find_or_create_by(name:, breed:)
    new_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if new_dog.empty?
      Dog.create(name: name, breed: breed)
    else
      dog_id = new_dog[0][0]
      Dog.find_by_id(dog_id)
    end
  end

  def self.find_by_name(dog_name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    dog_id = DB[:conn].execute(sql, dog_name)[0][0]
    Dog.find_by_id(dog_id)
  end

  def update
    sql= <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end