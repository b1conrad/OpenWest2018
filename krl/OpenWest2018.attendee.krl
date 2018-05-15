ruleset OpenWest2018.attendee {
  meta {
    use module io.picolabs.visual_params alias vp
    use module io.picolabs.subscription alias Subs
    use module io.picolabs.wrangler alias wrangler
    shares __testing, tag_line, name, connections
  }
  global {
    __testing = { "queries": [ { "name": "__testing" },
                               { "name": "tag_line" },
                               { "name": "name" },
                               { "name": "connections"  }],
                  "events": [ {"domain": "about_me", "type": "new_tag_line", "attrs": ["tag_line"]},
                              {"domain": "about_me", "type": "name_provided", "attrs": ["name"]} ] }
    tag_line = function() {
      ent:tag_line
    }
    name = function() {
      ent:name || vp:dname()
    }
    connections = function() {
      Subs:established("Rx_role","peer")
        .map(function(v){wrangler:skyQuery(v{"Tx"},meta:rid,"name")})
    }
  }
  rule intialization {
    select when wrangler ruleset_added where rids >< meta:rid
    fired {
      raise wrangler event "channel_creation_requested"
        attributes { "name": "introduction", "type": "public" };
      raise visual event "config"
        attributes { "width":50, "height": 50 };
      raise wrangler event "subscription"
        attributes { "wellKnown_Tx": "KmHBdDKH9VU8Kno6ZDH1mP",
          "Rx_role": "member", "Tx_role": "collection", 
          "name": name(), "channel_type": "subscription" };
    }
  }
  rule record_intro_channel {
    select when wrangler channel_created
    pre {
      channel = event:attr("channel");
    }
    if channel{"name"}=="introduction" then noop();
    fired {
      ent:intro_channel_id := channel{"id"};
    }
  }
  rule new_tag_line {
    select when about_me new_tag_line
    pre {
      tag_line = event:attr("tag_line");
    }
    if tag_line then noop();
    fired {
      ent:tag_line := tag_line;
    }
  }
  rule name_provided {
    select when about_me name_provided
    pre {
      name = event:attr("name");
    }
    if name then noop();
    fired {
      ent:name := name;
    }
  }
  rule tag_scanned {
    select when tag scanned
    send_directive("met",{"name":ent:name,"about me":ent:tag_line})
  }
  rule auto_accept {
    select when wrangler inbound_pending_subscription_added
    pre {
      acceptable = event:attr("Rx_role")=="peer"
                && event:attr("Tx_role")=="peer";
    }
    if acceptable then noop();
    fired {
      raise wrangler event "pending_subscription_approval"
        attributes event:attrs;
    } else {
      raise wrangler event "inbound_rejection"
        attributes { "Rx": event:attr("Rx") }    }
  }
}
