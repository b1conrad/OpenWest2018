ruleset OpenWest2018.tags {
  meta {
    use module OpenWest2018.keys alias ids
    use module io.picolabs.wrangler alias wrangler
    use module io.picolabs.cookies alias cookies
    shares __testing, timestamps
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "timestamps" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ //{ "domain": "d1", "type": "t1" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    child_specs = {
      "rids": ["io.picolabs.subscription","OpenWest2018.attendee"] };
    MDT = function(ts) {time:add(ts,{"hours": -6})}
    timestamps = function() {
      ent:owners
        .keys()
        .sort(function(a,b){ent:owners{a} cmp ent:owners{b}})
        .reduce(function(a,k){a.put(MDT(ent:owners{k}),k)},{})
    }
  }
  rule initialization {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    if ent:owners.isnull() then noop();
    fired {
      ent:owners := {};
    }
  }
  rule reject_invalid_tag {
    select when tag scanned
    pre {
      candidate_id = event:attr("id");
      ok = candidate_id.typeof() == "String"
        && candidate_id.length() == 15
        && ids:valid(candidate_id);
    }
    if not ok then
      send_directive("invalid tag",{"id":candidate_id,"page":"reject"})
    fired { last; } // may need to ban
  }
  rule tag_first_scan {
    select when tag scanned id re#^(\d{15})$# setting(id)
    pre {
      key = id;
    }
    if not (ent:owners >< key) then every {
      send_directive("first scan",{"id": id,"page":"sign-up"});
      event:send({"eci":wrangler:parent_eci(),
        "domain": "owner", "type": "creation",
        "attrs": child_specs.put({"name":ids:as_pin(id)})
      });
    }
    fired {
      ent:owners{key} := time:now();
      raise ids event "id_used" attributes event:attrs;
      raise tag event "first_scan" attributes event:attrs;
      last;
    }
  }
  rule scanner_unknown {
    select when tag scanned id re#^(\d{15})$# setting(id)
    pre {
      whoami = cookies:cookies(){"whoami"};
    }
    if whoami.isnull()
      then send_directive("unknown scanner",{"id": id,"page":"recovery"});
    fired {
      raise tag event "recovery_needed" attributes event:attrs;
      last;
    } else {
      ent:scanned_by := whoami;
    }
  }
  rule tag_subsequent_scan {
    select when tag scanned id re#^(\d{15})$# setting(id)
    pre {
      key = id;
    }
    if ent:owners >< key
      then send_directive("subsequent scan",
        {"id": id,"last scanned":ent:owners{key},"page":"about_me",
          "scanned_by": ent:scanned_by
        });
    fired {
      raise tag event "subsequent_scan"
        attributes event:attrs.put("scanned_by", ent:scanned_by);
    } finally {
      clear ent:scanned_by;
    }
  }
  rule tag_initials_provided {
    select when tag initials_provided pin re#^(\d{4})# setting(pin)
    pre {
      whoami = cookies:cookies(){"whoami"};
      initials = event:attr("name") || pin;
      tag_line = event:attr("tag_line") || "one_liner about "+pin;
      eci = wrangler:children().head(){"eci"};
      pass_along_attrs = event:attrs
        .put({"initials": initials, "tag_line": tag_line});
    }
    if pin==whoami then
      event:send({"eci":eci, "domain": "attendees", "type": "initials_provided",
        "attrs": pass_along_attrs
      });
  }
  rule tag_recovery_codes_provided {
    select when tag recovery_codes_provided id re#^(\d{15})$# setting(id)
    pre {
      date = event:attr("date");
      time = event:attr("time");
      millis = event:attr("millis");
      ts = time:add(<<#{date}T#{time}.#{millis}Z>>,{"hours":6});
    }
    if ent:owners{id} == ts then
      send_directive("recovery_codes_accepted");
    fired {
      raise tag event "recovery_codes_accepted" attributes {
        "txnId": meta:txnId, "id": id
      };
    }
  }
}
