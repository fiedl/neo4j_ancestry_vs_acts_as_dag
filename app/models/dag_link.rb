class DagLink < ActiveRecord::Base
  
  if ENV['BACKEND'] == 'acts-as-dag'
    acts_as_dag_links polymorphic: true
  elsif ENV['BACKEND'] == 'neo4j_ancestry'
    # This class is not used with neo4j_ancestry.
  else
    raise 'Please set the BACKEND environment variable to "acts-as-dag" or "neo4j_ancestry".'
  end
  
end
