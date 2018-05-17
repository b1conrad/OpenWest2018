ruleset OpenWest2018.collection {
  meta {
    use module io.picolabs.collection alias my
    use module io.picolabs.wrangler alias Wrangler
    shares __testing, my_members, high_scores
  }
  global {
    __testing = { "queries": [ { "name": "__testing" },
                               { "name": "my_members" },
                               { "name": "high_scores" } ],
                  "events": [{"domain":"attendees", "type": "need_sync"}] }
    my_members = function(){
      my:members()
    }
    attendee_name = function(key) {
      ent:attendees{key} || Wrangler:skyQuery(key, "OpenWest2018.attendee", "name")
    }
    high_scores = function() {
      ent:scores.values().sort("ciremun")
    }
  }
  rule new_member {
    select when wrangler subscription_added
    pre {
      key = event:attr("Tx");
      name = event:attr("name");
    }
    fired {
      ent:attendees{key.klog("key")} := name.klog("name");
    }
  }
  rule sync_members {
    select when attendees need_sync
    foreach my_members() setting(subs)
    pre {
      key = subs{"Tx"};
      name = ent:attendees{key} || attendee_name(key)
    }
    fired {
      ent:attendees{key.klog("key")} := name.klog("name");
    }
  }
  rule update_high_scores {
    select when attendee new_connection
    pre {
      id = event:attr("id");
      connection_count = event:attr("connection_count");
      key = my_members().filter(function(v){v{"Id"}==id}).head(){"Tx"};
    }
    fired {
      ent:scores{key} := connection_count;
    }
  }
}
