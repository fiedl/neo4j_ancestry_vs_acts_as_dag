require 'rails_helper'

describe "performance: " do
  
  $number_of_groups = 100
  $number_of_users = 10
  
  before :each do
    Neo4jDatabase.clear :yes_i_am_sure
  end
  
  let(:groups) { (1..$number_of_groups).map { |n| Group.create(name: "Group #{n}") } }
  let(:parent_group) { Group.create name: "Parent Group" }
  let(:ancestor_group) { Group.create name: "Ancestor Group" }
  
  specify "creating #{$number_of_groups} groups" do
    benchmark do
      groups
    end
    groups.count.should == $number_of_groups
  end
  
  specify "adding #{$number_of_users} users to each of the #{$number_of_groups} groups" do
    benchmark do
      groups.each do |group|
        (1..$number_of_users).each { |n| group.child_users.create }
      end
    end
    groups.last.child_users.count.should == $number_of_users
  end
  
  describe "with child users" do
  
    before do
      # create $number_of_users users per group
      groups.each do |group|
        (1..$number_of_users).each { |n| group.child_users.create }
      end
    end
    
    specify "moving #{$number_of_groups} groups into a parent group" do
      benchmark do
        groups.each do |group|
          group.parent_groups << parent_group
        end
      end
      parent_group.child_groups.count.should == $number_of_groups
    end
    
    describe "with parent group" do
      before do
        groups.each do |group|
          group.parent_groups << parent_group
        end
      end
      
      specify "moving the group structure into an ancestor group" do
        benchmark do
          parent_group.parent_groups << ancestor_group
        end
        ancestor_group.descendant_groups.count.should > $number_of_groups
      end
      
      describe "with ancestor group" do
        before { parent_group.parent_groups << ancestor_group }
      
        specify "removing the link to the ancestor group" do
          benchmark do
            parent_group.parent_groups.destroy(ancestor_group)
          end
          ancestor_group.descendants.count.should == 0
        end
        
        specify "destroying the ancestor group" do
          benchmark do
            ancestor_group.destroy
          end
          parent_group.ancestors.should == []
        end
        
        specify "finding all descendants" do
          benchmark do
            ancestor_group.descendants
          end
          ancestor_group.descendants.count.should > $number_of_groups
        end
        
        specify "finding all descendant users" do
          benchmark do
            ancestor_group.descendant_users
          end
          ancestor_group.descendant_users.count.should > $number_of_groups
        end
      end
    end
  end
    
  after(:all) do
    print_results
  end
  
  $results = []
  def benchmark
    duration_in_seconds = Benchmark.realtime do
      yield
    end
    
    description = RSpec.current_example.metadata[:description]
    duration = "#{duration_in_seconds} seconds"
    
    $results << [description, "#{duration_in_seconds.to_s} s"]
    print "#{description}: #{duration}.\n".blue
  end
  
  def print_results
    print "\n\n## Results for #{ENV['BACKEND']}\n\n".blue.bold
    
    print "$number_of_groups = #{$number_of_groups}\n".blue
    print "$number_of_users  = #{$number_of_users}\n\n".blue
    
    print results_table.blue.bold
  end
  def results_table
    t = TableFormatter.new
    t.source = $results
    t.labels = ['Description', 'Duration']
    t.display.to_s
  end    
  
end