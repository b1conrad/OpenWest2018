ruleset OpenWest2018.tags {
  meta {
    use module OpenWest2018.keys alias ids
    use module io.picolabs.wrangler alias wrangler
    shares __testing
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ ] }
    namespace = "ow18"
    cookies = function(_headers) {
      arg = event:attr("_headers") || _headers;
      arg{"cookie"}.isnull() => {} |
      arg{"cookie"}                      //.klog("cookie")
        .split("; ")                     //.klog("split")
        .map(function(v){v.split("=")})  //.klog("map1")
        .collect(function(v){v.head()})  //.klog("collect")
        .map(function(v){v.head()[1]})   //.klog("map2")
    }
    child_rids = ["io.picolabs.subscription","OpenWest2018.attendee"];
    child_specs = { "rids": child_rids};
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
      send_directive("invalid tag",{"id":id,"page":"reject"})
    fired { last; } // may need to ban
  }
  rule tag_first_scan {
    select when tag scanned id re#^(\d{15})$# setting(id)
    pre {
      key = namespace + id;
    }
    if not (ent:owners >< key) then every {
      send_directive("first scan",{"id": id,"page":"sign-up"});
      event:send({"eci":wrangler:parent_eci(),
        "domain": "owner", "type": "creation",
        "attrs": child_specs.put({"name":namespace+ids:as_pin(id)})
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
      key = namespace + id;
      wellKnown_Rx = cookies(){"wellKnown_Rx"};
    }
    if wellKnown_Rx.isnull()
      then send_directive("unknown scanner",{"id": id,"page":"recovery"});
    fired {
      ent:owners{key} := time:now();
      raise tag event "recovery_needed" attributes event:attrs;
      last;
    }
  }
  rule tag_subsequent_scan {
    select when tag scanned id re#^(\d{15})$# setting(id)
    pre {
      key = namespace + id;
    }
    if ent:owners >< key
      then send_directive("subsequent scan",
        {"id": id,"last scanned":ent:owners{key},"page":"about_me"});
    fired {
      ent:owners{key} := time:now();
      raise tag event "subsequent_scan" attributes event:attrs;
    }
  }
}