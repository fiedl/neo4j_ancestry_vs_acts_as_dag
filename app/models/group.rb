class Group < ActiveRecord::Base

  if ENV['BACKEND'] == 'acts-as-dag'
    has_dag_links link_class_name: 'DagLink', ancestor_class_names: ['Group'], descendant_class_names: ['User', 'Group']
  elsif ENV['BACKEND'] == 'neo4j_ancestry'
    has_neo4j_ancestry parent_class_names: ['Group'], child_class_names: ['Group', 'User']
  else
    raise 'Please set the BACKEND environment variable to "acts-as-dag" or "neo4j_ancestry".'
  end

end
