require "camping"

Camping.goes :Migrations

module Migrations
  module Models
	class BadDude < Base; end
	class TableCreation < V 1.0
	  def self.up
	    puts "FORCE THE TABLES"
	    create_table BadDude.table_name, :force=>true do |t|
	      t.string :name, :limit => 255
		  t.integer :bad
		  t.timestamps
	    end
	  end
	  def self.down
	    drop_table BadDude.table_name
	  end
	end
	class StartingDudes < V 1.3
	  def self.up
	    puts "There is only one way to make sure Bruce is the baddest"
	    BadDude.create :name => "Bruce", :bad => 1
	    BadDude.create :name => "Bruce", :bad => 2
	    BadDude.create :name => "Bruce", :bad => 5
	  end
	  def self.down
	    BadDude.delete_by_name "Bruce"
	  end
	end
	class WeNeedMoreDudes < V 2.7
	  def self.up
	    puts "Maybe a non Bruce would help our worst case scenario planning"
	    BadDude.create :name => "Bob", :bad => 3
	    BadDude.create :name => "Samantha", :bad => 3
	  end
	  def self.down
	    BadDude.delete_by_name "Bob"
		BadDude.delete_by_name "Samantha"
	  end
	end
    class NoIMeanWeNeedBadderDudes < V 3.14159
	  def self.up
	    puts "just in case things get ugly"
	    sam = BadDude.find_by_name "Samantha"
        sam.bad = 9001
	    sam.save
	  end
	  def self.down
	    sam = BadDude.find_by_name "Samantha"
		sam.bad = 3
		sam.save
	  end
	end
	class WaitWeShouldDoThisEarlier < V 3.11
	  def self.up
	    puts "for workgroups"
	    bruce = BadDude.find_by_name "Bob"
	    bruce.bad = 45
	    bruce.save
	  end
	  def self.down
	    bruce = BadDude.find_by_name "Bob"
		bruce.bad = 3
		bruce.save
	  end
	end
  end
  module Controllers
    class Bad < R '/(\d+)?'
	  def get enough
	    @dudes = BadDude.all :conditions => ["bad >= ?", enough.to_i]
		@howbad = enough
		render :savethepresident
	  end
	end
  end
  module Views
    def savethepresident
	  h1.ohnoes "The President Has Been Kidnapped By #{@howbad} Ninjas!"
	  if @dudes.empty?
	    div "None of the dudes are bad enough to rescue him, We are doomed!"
      else
	    div "Please get the following dudes:"
	    ul.dudes do
	      @dudes.each do |dude|
		    li.dude dude.name
		  end
	    end
      end
	end
  end
end
def Migrations.create
  Migrations::Models.create_schema
end
