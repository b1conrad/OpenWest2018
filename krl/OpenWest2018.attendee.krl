ruleset OpenWest2018.attendee {
  meta {
    use module io.picolabs.subscription alias Subs
    use module io.picolabs.cookies alias cookies
    use module io.picolabs.wrangler alias wrangler
    provides name, tag_line, intro_channel_id, connections, pin
    shares __testing, tag_line, name, connections, connection_count
      , designation
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
      ent:tag_line.defaultsTo("")
    }
    name = function() {
      ent:name || ent:pin
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
    pin = function() {
      ent:pin
    }
    designation = function() {
      name() + (ent:tag_line => ": " + ent:tag_line | "")
    }
  }
//------------------------------------------
// when this ruleset is installed in a new owner pico
//
  rule intialization {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    fired {
      ent:connections := {};
      ent:pin := wrangler:myself(){"name"};
      raise wrangler event "channel_creation_requested"
        attributes { "name": "introduction", "type": "public" };
      raise visual event "config"
        attributes { "width":50, "height": 50 };
      raise wrangler event "subscription"
        attributes { "wellKnown_Tx": "E4vTvKQ3M2eXUwLujhBWJd",
          "Rx_role": "member", "Tx_role": "collection", 
          "name": ent:pin, "channel_type": "subscription" };
      raise wrangler event "install_rulesets_requested"
        attributes { "rid": "OpenWest2018.attendee.ui" }
    }
  }
  rule record_intro_channel {
    select when wrangler channel_created
    pre {
      channel = event:attr("channel");
      pertinent = channel{"name"}=="introduction"
                && channel{"type"}=="public"
    }
    if pertinent then noop();
    fired {
      ent:intro_channel_id := channel{"id"};
    }
  }
//------------------------------------------
// manage updates to information about the owner pico
//
  rule new_tag_line {
    select when about_me new_tag_line
    pre {
      tag_line = event:attr("tag_line");
    }
    if not tag_line.isnull() then noop();
    fired {
      ent:tag_line := tag_line;
    }
  }
  rule name_provided {
    select when about_me name_provided
    pre {
      name = event:attr("name");
    }
    if not name.isnull() then noop();
    fired {
      ent:name := name;
    }
  }
//------------------------------------------
// when the tag of this owner pico is scanned
//
  rule identify_scanner {
    select when tag scanned
    pre {
      scanner = cookies:cookies(){"whoami"};
    }
    fired {
      ent:scanner_pin := scanner;
    }
  }
  rule handle_unknown_scanner {
    select when tag scanned
    if not ent:scanner_pin.match(re#^\d{4}$#) then noop();
    fired {
      raise attendee event "unknown_scanner";
      clear ent:scanner_pin;
      last;
    }
  }
  rule avoid_self_to_self {
    select when tag scanned
    if ent:scanner_pin == ent:pin then noop();
    fired {
      clear ent:scanner_pin;
      last;
    }
  }
  rule avoid_duplicate_connection {
    select when tag scanned
    pre {
      already_connected = ent:connections.values() >< ent:scanner_pin;
    }
    if already_connected then noop();
    fired {
      clear ent:scanner_pin;
      last;
    }
  }
  rule tag_scanned {
    select when tag scanned
    pre {
      attendees_subs = Subs:established("Rx_role","member").head();
      eci = attendees_subs{"Tx"};
      Tx = eci => wrangler:skyQuery(eci,"OpenWest2018.collection","pin_as_Rx", {"pin": ent:scanner_pin})
                | null;
    }
    if Tx.klog("DID") like re#^.{22}$# then every {
      send_directive("met",{"name":name(),"about me":ent:tag_line, "peer":whoami, "peer_Tx": Tx});
    }
    fired {
      raise wrangler event "subscription"
        attributes { "wellKnown_Tx": Tx,
          "Rx_role": "peer", "Tx_role": "peer",
          "name": ent:pin+"<=>"+whoami, "channel_type": "subscription" };
    }
    finally {
      clear ent:scanner_pin;
    }
  }
//------------------------------------------
// subscription management
//
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
    }
  }
  rule record_new_contact_pin {
    select when wrangler subscription_added
    pre {
      subs_id = event:attr("Id");
      subs = Subs:established("Id",subs_id)[0].klog("subs");
      pertinent = subs{"Rx_role"}=="peer"
               && subs{"Tx_role"}=="peer";
      subs_Rx = subs{"Rx"}.klog("subs_Rx");
      subs_name = engine:listChannels()
        .filter(function(v){v{"id"}==subs_Rx}).klog("filtered")
        [0]{"name"}.klog("subs_name");
      peer_pin = subs_name.extract("(\d{4})<=>(\d{4})").klog("pins")
        .filter(function(v){v!=ent:pin})[0];
    }
    if pertinent then noop();
    fired {
      ent:connections{subs_id} := peer_pin;
    }
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
