ruleset OpenWest2018.attendee {
  meta {
    use module io.picolabs.visual_params alias vp
    use module io.picolabs.subscription alias Subs
    use module io.picolabs.cookies alias cookies
    use module io.picolabs.wrangler alias wrangler
    provides name, tag_line, intro_channel_id
    shares __testing, tag_line, name, connections, connection_count
  }
  global {
    __testing = { "queries": [ { "name": "__testing" },
                               { "name": "tag_line" },
                               { "name": "name" },
                               { "name": "connections"  },
                               { "name": "connection_count"  }],
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
    connection_count = function() {
      Subs:established("Rx_role","peer").length();
    }
    intro_channel_id = function() {
      ent:intro_channel_id
    }
  }
  rule intialization {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    fired {
      raise wrangler event "channel_creation_requested"
        attributes { "name": "introduction", "type": "public" };
      raise visual event "config"
        attributes { "width":50, "height": 50 };
      raise wrangler event "subscription"
        attributes { "wellKnown_Tx": "E4vTvKQ3M2eXUwLujhBWJd",
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
    pre {
      whoami = cookies:cookies(){"whoami"};
      attendees_subs = Subs:established("Rx_role","member").head();
      eci = attendees_subs{"Tx"};
      Tx = whoami && eci => wrangler:skyQuery(eci,"OpenWest2018.collection","pin_as_Rx", {"pin": whoami})
                          | null;
    }
    if Tx.klog("DID") like re#^.{22}$# then every {
      send_directive("met",{"name":ent:name,"about me":ent:tag_line, "peer":whoami, "peer_Tx": Tx});
    }
    fired {
      raise wrangler event "subscription"
        attributes { "wellKnown_Tx": Tx,
          "Rx_role": "peer", "Tx_role": "peer", 
          "name": name()+"<=>"+whoami, "channel_type": "subscription" };
    }
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
  rule wrangler_subscription_added {
    select when wrangler subscription_added
    pre {
      attendees_subs = Subs:established("Rx_role","member")[0];
      attendees_eci = attendees_subs{"Tx"};
      attendees_id = attendees_subs{"Id"};
    }
    if attendees_eci && attendees_id then
      event:send({"eci":attendees_eci,
        "domain": "attendee", "type": "new_connection",
        "attrs": {"id":attendees_id,"connection_count":connection_count()}});
  }
}
