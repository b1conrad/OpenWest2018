ruleset OpenWest2018.collection.find {
  meta {
    use module OpenWest2018.collection alias all
    shares __testing, designations
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "designations" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ //{ "domain": "d1", "type": "t1" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    designations = function(){
      2603.range(2705)
        .map(function(n){
          all:attendee_designation(n.as("String"))
        })
        .join(10.chr())
        
    }
  }
}
