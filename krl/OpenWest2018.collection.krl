ruleset OpenWest2018.collection {
  meta {
    use module io.picolabs.collection alias my
    use module io.picolabs.wrangler alias Wrangler
    provides high_scores
    shares __testing, my_members, high_scores, pin_as_Rx, about_pin, place
  }
  global {
    __testing = { "queries": [ { "name": "__testing" },
                               { "name": "my_members" },
                               { "name": "high_scores" },
                               { "name": "place", "args": [ "pin" ] } ],
                  "events": [{"domain":"attendees", "type": "need_sync"}] }
    my_members = function(){
      my:members()
    }
    attendee_name = function(key) {
      name = Wrangler:skyQuery(key, "OpenWest2018.attendee", "name");
      name{"error"} => ent:attendees{key} | name
    }
    high_scores = function() {
      ent:scores.keys()
        .map(function(v){{"key":attendee_name(v),"count":ent:scores{v}}})
        .sort(function(a,b){-(a{"count"} <=> b{"count"})})
        .collect(function(v){"count="+v{"count"}})
        .map(function(v){v.map(function(w){w{"key"}})})
    }
    pin_as_Rx = function(pin) {
      ent:attendees
        .filter(function(v){v==pin})
        .keys().head()
    }
    about_pin = function(pin) {
      Tx = pin_as_Rx(pin);
      html = Wrangler:skyQuery(Tx, "OpenWest2018.attendee.ui", "about_me",
        {"placement": place(pin).encode()});
      html{"error"} => html{"skyQueryError"} | html
    }
    place = function(pin) { // returns place and whether tied
      highs = high_scores();
      pins = highs.keys();
      placement = function(v,k) {
        { "place": k+1, "tied": v.length()>1, "out_of": pins.length()}
      };
      0.range(pins.length()-1)
        .reduce(function(a,v){
          which = highs{pins[v]};
          which >< pin => placement(which,v) | a
        },placement([pin],0))
    }
  }
  rule new_member {
    select when collection new_member
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
      name = ent:attendees{key};
      temp = Wrangler:skyQuery(key, "OpenWest2018.attendee", "connection_count");
      connection_count = temp like re#\d+# => temp.as("Number") | 0;
    }
    fired {
      ent:attendees{key.klog("key")} := name.klog("name");
      ent:scores{key} := connection_count;
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
