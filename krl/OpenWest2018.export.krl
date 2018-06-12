ruleset OpenWest2018.export {
  meta {
    use module OpenWest2018.attendee alias Attendee
    shares __testing, testFunc
  }
  
  global {
    
    designations = function(x){x{"designation"}}
    
    testFunc = function() {
      name = Attendee:name();
      tag_line = Attendee:tag_line();
      intro_channel_id = Attendee:intro_channel_id();
      pin = Attendee:pin();
      connections = Attendee:connections().map(designations);
      csv = <<#{name},"#{tag_line}",#{intro_channel_id},#{pin}#{13.chr() + 10.chr()}>>;
      csv
    }
    
    __testing = {"queries" : [{"name" : "testFunc"}],
                 "events" : [{"domain" : "export", "type" : "json"}]
                }
  }
  
  rule export_json {
    select when export json
    
    pre {
      name = Attendee:name();
      tag_line = Attendee:tag_line();
      intro_channel_id = Attendee:intro_channel_id();
      pin = Attendee:pin();
      connections = Attendee:connections().map(designations);
      json = {}.put("name", name).put("tag_line", tag_line).put("pin", pin)
        .put("intro_channel_id", intro_channel_id).put("connections", connections)
    }
    
    send_directive("json", json);
    
  }
  
  rule export_csv_info {
    select when export csv_info
    
    pre {
      name = Attendee:name();
      tag_line = Attendee:tag_line();
      intro_channel_id = Attendee:intro_channel_id();
      pin = Attendee:pin();
      csv = <<#{name},"#{tag_line}",#{intro_channel_id},#{pin}#{13.chr() + 10.chr()}>>;
    }
    
    send_directive("_txt", {"content" : csv})
  }
  
  rule export_csv_connections {
    select when export csv_connections
    
    pre{
      csv = Attendee:connections().map(designations).reduce(function(a,b){a + <<#{13.chr() + 10.chr()}>> + b})
    }
    
    send_directive("_txt", {"content" : csv})
  }

}
