# CloneUtil

This gem helps us to copy the ActiveRecord objects recursively

## Installation

Add this line to your application's Gemfile:

    gem 'clone_util'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install clone_util

## Usage

Call `deep_clone` with the parent object which should copy all its children

    Ex: School.first.deep_clone


Add `deep_clone_options` in the models which needs to be copied with the parent

    Ex: deep_clone_options(:associations => [:departments, :laboratories])

## Parameters passed with `deep_clone_options`:

    :associations => This contains the list of association(children) which needs to be cloned.
    Ex: deep_clone_options(:associations => [:departments])


    :unequal_attributes => This contains the column names should not be same as parent(Ex: xx column in child table will not be same as xx column in parent table so this column in child table will set to nil)
    Ex: deep_clone_options(::unequal_attributes => [:xx])


    :equivalent_associations => If child table has 2 foreign keys and one will be automatically updated with associations array mentioned in parent class and to update the other foreign key we need this option in child class.
    Ex: deep_clone_options(:equivalent_associations => [:laboratory_id])
    

    :parent_id_attr => This contains the parent column of the child table
    

## Example:
Models:

    class School < ActiveRecord::Base
        has_many :laboratories
        has_many :departments
        deep_clone_options(:associations => [:departments, :laboratories])
    end


    class Laboratory < ActiveRecord::Base
        belongs_to :school
        belongs_to :department
        deep_clone_options(:equivalent_associations => [:department]  )
    end


    class Department < ActiveRecord::Base
        belongs_to :school
        has_many :students
        deep_clone_options(:associations => [:students])
    end


    class Student < ActiveRecord::Base
        belongs_to :department
    end

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


Seed File:

    School.create([{ name: 'school1'}])
    Department.create([{ name: 'department1', :school_id => 1 }])
    Laboratory.create([{ name: 'Lab1', :school_id => 1, :department_id => 1 }, { name: 'Lab2', :school_id => 1, :department_id => 1 }])
    Student.create([{ name: 'student1', :department_id => 1 }, { name: 'student2', :department_id => 1 }])


Include the models and run the above migrations.
Finally below command gives you the clone result:

    School.first.deep_clone

## Sample Application

    Here we can find application which uses clone_util gem for copying ActiveRecord objects recursively
    https://github.com/srijithc/sample_clone_util
