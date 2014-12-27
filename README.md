# CloneUtil

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'clone_util'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install clone_util

## Usage

#Call deep_clone with the parent object which should copy all its children
```javascript
Ex: School.first.deep_clone
```

#Add deep_clone_options in the models which needs to be copied with the parent
Ex: deep_clone_options(:associations => [:departments, :laboratories])

Example:
```javascript
Models:

class School < ActiveRecord::Base
  has_many :laboratories
  has_many :departments

  deep_clone_options(:associations => [:departments, :laboratories])

  def copy
    self.deep_clone
  end
end

class Laboratory < ActiveRecord::Base
  belongs_to :school
  belongs_to :department

  deep_clone_options(:parent_id_att => [:school_id],
                     :equivalent_associations => [:department]  )
end

class Department < ActiveRecord::Base
  belongs_to :school
  has_many :students

  deep_clone_options(:parent_id_att => [:school_id],
                     :associations => [:students])
end

class Student < ActiveRecord::Base
  belongs_to :department
end
```
Migrations:

class CreateSchools < ActiveRecord::Migration
  def change
    create_table :schools do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end

class CreateLaboratories < ActiveRecord::Migration
  def change
    create_table :laboratories do |t|
      t.string :name
      t.integer :department_id
      t.integer :school_id

      t.timestamps null: false
    end
  end
end

class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :name
      t.integer :school_id

      t.timestamps null: false
    end
  end
end

class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.string :name
      t.integer :age
      t.integer :department_id
      
      t.timestamps null: false
    end
  end
end

# Seed File:
School.create([{ name: 'school1'}])
Department.create([{ name: 'department1', :school_id => 1 }])
Laboratory.create([{ name: 'Lab1', :school_id => 1, :department_id => 1 }, { name: 'Lab2', :school_id => 1, :department_id => 1 }])
Student.create([{ name: 'student1', :department_id => 1 }, { name: 'student2', :department_id => 1 }])

Include the models and run the above migrations
Finally below command gives you the clone result

School.first.deep_clone


## Contributing

1. Fork it ( https://github.com/[my-github-username]/clone_util/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
