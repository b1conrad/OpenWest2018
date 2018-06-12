ruleset io.picolabs.pds {
  meta {
    shares __testing, read_item, read_all
    provides read_item, read_all
  }
  
  global {
    __testing = { "events" : [{"domain" : "store", "type" : "new_value", "attrs" : ["key", "value"]}],
                  "queries" : [{"name" : "read_item", "args" : ["key"]},
                               {"name" : "read_all"}] }
    
    
    //returns the value paired with key provided
    read_item = function(key) {
      ent:store{key}
    }
    
    //returns entire store
    read_all = function() {
      ent:store
    }
    
  }
  
  rule intialize {
    select when wrangler ruleset_added
    
    if ent:store.isnull() then noop();
    fired {
      ent:store := {};
      raise store event "initialized";
    }
}
  
  //updates the value paired to the key to newVal
  rule update_store {
    select when store new_value
    
    pre {
      key = event:attr("key");
      newVal = event:attr("value");
    }
    
    fired {
      ent:store{key} := newVal;
      raise store event "updated"
      attributes {"key" : key, "value" : newVal}
    }
    
  }
  
}
