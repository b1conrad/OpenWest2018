ruleset OpenWest2018.collection {
  meta {
    use module io.picolabs.collection alias my
    use module io.picolabs.cookies alias cookies
    use module io.picolabs.wrangler alias Wrangler
    provides high_scores, attendee_designation, connections_possible
    shares __testing, my_members, high_scores, pin_as_Rx, about_pin, place
      , sizes
  }
  global {
    __testing = { "queries": [ { "name": "__testing" },
                               { "name": "my_members" },
                               { "name": "high_scores" },
                               { "name": "pin_as_Rx", "args": [ "pin" ] },
                               { "name": "place", "args": [ "pin" ] } ],
                  "events": [{"domain":"attendees", "type": "need_sync"}] }
    sizes = function(){
      [ent:attendees.length(),ent:scores.length(),
        connections_possible(),ent:old_scores.length()]
    }
    connections_possible = function(){
      my:members().length()-1
    }
    my_members = function(){
      my:members()
    }
    attendee_designation = function(pin) {
      key = pin_as_Rx(pin.klog("pin")).klog("key");
      designation = Wrangler:skyQuery(key, "OpenWest2018.attendee", "designation")
        .klog("designation");
      designation{"error"} => pin | designation
    }
    high_scores = function() {
      ent:scores.keys()
        .map(function(v){{"key":ent:attendees{v},"count":ent:scores{v}}})
        .sort(function(a,b){-(a{"count"} <=> b{"count"})})
        .collect(function(v){"count="+v{"count"}})
        .map(function(v){v.map(function(w){w{"key"}})})
    }
    pin_as_Rx = function(pin) {
      ent:attendees
        .filter(function(v){v==pin})
        .keys().head()
    }
    about_pin = function(pin,_headers) {
      scanner = cookies:cookies(_headers){"whoami"};
      get_page = function(){
        Tx = pin_as_Rx(pin);
        html = Wrangler:skyQuery(Tx, "OpenWest2018.attendee.ui", "about_me",
          {"placement": place(pin).encode()});
        html{"error"} => html{"skyQueryError"} | html
      };
      scanner == pin => get_page()
                      | <<{"directives": [ ]}>>
    }
    place = function(pin) { // returns place and whether tied
      total = ent:attendees.keys().length();
      highs = high_scores();
      places = highs.keys();
      places_len = places.length();
      placement = function(v,k) {
        { "place": k+1, "tied": v.length()>1, "out_of": places_len, "total": total}
      };
      places.reduce(function(a,v,k){
        highs{v} >< pin => placement(highs{v},k) | a
      },placement(highs{"count=0"},places_len-1))
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
      old_connection_count = ent:old_scores{key}.defaultsTo(0);
      new_connection_count = 
        connection_count == 0 => 0
                               | connection_count - old_connection_count;
    }
    fired {
      ent:attendees{key.klog("key")} := name.klog("name");
      ent:scores{key} := new_connection_count;
    }
  }
  rule update_high_scores {
    select when attendee new_connection
    pre {
      id = event:attr("id");
      connection_count = event:attr("connection_count").klog("connection_count");
      subs = my_members().filter(function(v){v{"Id"}==id}).head();
      key = subs{"Tx"};
      verified_message = engine:verifySignedMessage(
          subs{"Tx_verify_key"}, event:attr("signed_message")
        ).klog("signed_message");
      verified_count = verified_message.decode();
    }
    if verified_count{"connection_count"} == connection_count then noop();
    fired {
      ent:scores{key} := connection_count - ent:old_scores{key}.defaultsTo(0);
      raise attendees event "scores_changed" attributes event:attrs;
    } else {
      raise attendees event "under_attack" attributes event:attrs.put({
        "verified_count": verified_count, "connection_count": connection_count
      });
    }
  }
  rule inform_attendee_of_initials {
    select when attendees initials_provided
    pre {
      pin = event:attr("pin");
      initials = event:attr("initials");
      tag_line = event:attr("tag_line");
      eci = pin_as_Rx(pin);
    }
    if eci then every {
      event:send({"eci": eci, "domain": "about_me", "type": "name_provided",
        "attrs": {"name": initials}
      });
      event:send({"eci": eci, "domain": "about_me", "type": "new_tag_line",
        "attrs": {"tag_line": tag_line}
      });
      event:send({"eci": eci, "domain": "about_me", "type": "sign_up_complete",
        "attrs": event:attrs
      });
    }
  }
  rule roll_over_past_scores {
    select when attendees new_day
    if ent:old_scores.isnull() then noop();
    fired {
      ent:old_scores := {}.put(ent:scores);
    }
  }
}
