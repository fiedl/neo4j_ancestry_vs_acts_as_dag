# neo4j_ancestry vs. acts-as-dag

In this quick **benchmark**, I'm trying to find out which **graph abstraction** gem I should use in a [ruby on rails](http://rubyonrails.org) project that needs a **nested group structure**.

These two gems are compared:

* [acts-as-dag](https://github.com/resgraph/acts-as-dag): This gem stores direct and indirect links in the ActiveRecord database.
* [neo4j_ancestry](https://github.com/fiedl/neo4j_ancestry): This gem stores direct links in the ActiveRecord database. Indirect links are read from a [neo4j graph database](http://neo4j.com).

Currently, we are using the *acts-as-dag* gem and are considering to migrate to *neo4j_ancestry*.

## Tests

See [spec/performance_spec.rb](spec/performance_spec.rb).

* creating 100 groups
* adding 10 users to each of the 100 groups
* moving 100 groups into a parent group
* moving the group structure into an ancestor group
* removing the link to the ancestor group
* destroying the ancestor group
* finding all descendants

## Results

### Results for acts-as-dag

    $number_of_groups = 100
    $number_of_users  = 10
    
    --------------------------------------------------------------------
    | Description                                        | Duration    |
    --------------------------------------------------------------------
    | creating 100 groups                                | 0.120807 s  |
    | adding 10 users to each of the 100 groups          | 5.208326 s  |
    | moving 100 groups into a parent group              | 4.172726 s  |
    | moving the group structure into an ancestor group  | 4.150828 s  |
    | removing the link to the ancestor group            | 1.662111 s  |
    | destroying the ancestor group                      | 0.000717 s  |
    | finding all descendants                            | 0.028424 s  |
    | finding all descendant users                       | 0.000439 s  |
    --------------------------------------------------------------------

### Results for neo4j_ancestry

    $number_of_groups = 100
    $number_of_users  = 10

    ---------------------------------------------------------------------
    | Description                                        | Duration     |
    ---------------------------------------------------------------------
    | creating 100 groups                                | 0.693674 s   |
    | adding 10 users to each of the 100 groups          | 103.020834s  |
    | moving 100 groups into a parent group              | 10.37782 s   |
    | moving the group structure into an ancestor group  | 0.123451 s   |
    | removing the link to the ancestor group            | 0.148153 s   |
    | destroying the ancestor group                      | 0.071543 s   |
    | finding all descendants                            | 0.616196 s   |
    | finding all descendant users                       | 0.172308 s   |
    ---------------------------------------------------------------------

### Results for neo4j and has_neo_node

See: https://github.com/fiedl/neo4j_gem_test

    $number_of_groups = 100
    $number_of_users  = 10
    
    ---------------------------------------------------------------------
    | Description                                        | Duration     |
    ---------------------------------------------------------------------
    | creating 100 groups                                | 2.4675473 s  |
    | adding 10 users to each of the 100 groups          | 25.227630 s  |
    | moving 100 groups into a parent group              | 0.1612957 s  |
    | moving the group structure into an ancestor group  | 0.0259047 s  |
    | removing the link to the ancestor group            | 0.0663939 s  |
    | destroying the ancestor group                      | 0.0182183 s  |
    | finding all descendants                            | 0.4834235 s  |
    | finding all descendant users                       | 0.0955578 s  |
    ---------------------------------------------------------------------
    


### Remarks

#### Contra Neo4j

* With Neo4j, it is more expensive to create a direct link between two nodes:
  * ActiveRecord: 0.055 seconds
  * with Neo4j:   0.103 seconds
* Due to the additional abstraction layer, it is more expensive to retrieve all descendant ActiveRecord objects of a node.
  * ActiveRecord: 0.0218 seconds
  * with Neo4j:   0.616 seconds

#### Pro Neo4j

* With Neo4j, it is less expensive to group structure with 1000 nodes to another parent node. That means, it is less expensive to connect a node to an existing structure …
  * ActiveRecord: 7.65 seconds
  * with Neo4j:   0.123 seconds
* … or to disconnect a node from a structure.
  * ActiveRecord: 2.83 seconds
  * with Neo4j:   0.148 seconds


## Results on Travis

https://travis-ci.org/fiedl/neo4j_ancestry_vs_acts_as_dag

## Running the Tests Locally

```
git clone git@github.com:fiedl/neo4j_ancestry_vs_acts_as_dag.git
cd neo4j_ancestry_vs_acts_as_dag

# modify config/database.yml to match your local mysql configuration

bundle exec rake neo4j:install neo4j:get_spatial neo4j:setup neo4j:start
bundle exec rake db:create db:migrate
BACKEND=acts-as-dag bundle exec rake
BACKEND=neo4j_ancestry bundle exec rake
```

## Author

&copy; 2014, Sebastian Fiedlschuster

Released under the **MIT License**.
