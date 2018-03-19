class Student
  attr_accessor :id, :name, :grade

  
  def initialize(name = nil , grade = nil, id = nil)
    @name = name
    @grade = grade
    @id = id
  end 

  def self.new_from_db(row)
    new_student = self.new
    new_student.id = row[0]
    new_student.name =  row[1]
    new_student.grade = row[2]
    new_student
  end


  def self.all
    # retrieve all the rows from the "Students" database
    DB[:conn].execute('SELECT id, name, grade FROM students').map do |student_info|
      self.new_from_db(student_info)
    end
  end

  def self.find_by_name(name)
    sql = "SELECT id, name, grade FROM students WHERE name = :name LIMIT 1" 
    DB[:conn].execute(sql, name).map do |student_info| 
      self.new_from_db(student_info)
    end.first
  end

  def self.count_all_students_in_grade_9
    self.all_students_in_grade_X(9)
  end

  def self.count_all_students_in_grade_10
    self.all_students_in_grade_X(10)
  end

  def self.students_below_12th_grade
    DB[:conn].execute('SELECT id, name, grade FROM students where grade < 12')
  end

  def self.first_student_in_grade_10
      self.first_X_students_in_grade_10(1).first
  end

  def self.first_X_students_in_grade_10(x)
    sql = "SELECT id, name, grade FROM students WHERE grade = 10 LIMIT :x" 
    DB[:conn].execute(sql, x).map do |student_info|
      self.new_from_db(student_info)
    end
  end

  def self.all_students_in_grade_X(grade)
    DB[:conn].execute('SELECT id, name, grade FROM students where grade = :grade', grade)
  end
  
  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def update
     DB[:conn].execute("UPDATE students SET name = :name, grade = :grade WHERE id = :id", @name, @grade, @id)
  end

  def self.create_table
    # replace spaces preceeded by pipe with empty string and
    # replace carriage returns and new lines with a space
    sql = <<-END_SQL.gsub(/^\s+\|/, '').gsub("[\r\n]", ' ')
      | CREATE TABLE IF NOT EXISTS students (
      |   id INTEGER PRIMARY KEY,
      |   name TEXT, 
      |   grade TEXT
      | );
    END_SQL
    DB[:conn].execute sql
  end 

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students;"
    DB[:conn].execute sql
  end

  def save
         if @id.nil?
           DB[:conn].execute("INSERT INTO students (name, grade) VALUES(:name, :grade)", "name" => @name, "grade" => @grade)
           @id = DB[:conn].last_insert_row_id
         else
           self.update
         end
  end

  def self.create(name, grade)
    student = self.new(name, grade)   
    student.save
    student
  end
end
