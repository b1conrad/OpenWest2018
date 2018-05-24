ruleset OpenWest2018.ui {
  meta {
    use module OpenWest2018.keys alias ids
    shares __testing
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ //{ "domain": "d1", "type": "t1" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    pc_host = "http://picos.byu.edu:8080"
    header = function(title,scripts) {
      <<<!DOCTYPE HTML>
<html>
  <head>
    <title>#{title}</title>
    <meta charset="UTF-8">
#{scripts.defaultsTo("")}
  </head>
  <body>
>>
    }
    footer = function() {
      <<  </body>
</html>
>>
    }
    page_url = function(pin) {
      <<#{pc_host}/OpenWest2018.collection/about_pin.html?pin=#{pin}>>
    }
    html = function(id,pin) {
      <<#{header(pin,scripts)}<pre>id=#{id}</pre>
<h1>#{pin}</h1>
<h2><a href="#{page_url(pin)}">my page</a></h2>
#{footer()}>>
    }
  }
  rule tag_first_scan {
    select when tag first_scan
    pre {
      id = event:attr("id");
      pin = ids:as_pin(id);
    }
    every {
      send_directive("_cookie",{"cookie":<<whoami=#{pin}; Path=/>>});
      send_directive("_html",{"content":html(id,pin)});
    }
  }
  rule tag_recovery_needed {
    select when tag recovery_needed
  }
  rule tag_subsequent_scan {
    select when tag subsequent_scan
    pre {
      id = event:attr("id");
      pin = ids:as_pin(id);
      scanned_by = event:attr("scanned_by");
      html = <<#{header(pin)}<h1>Welcome #{scanned_by}</h1>
<h2><a href="#{page_url(pin)}">my page</a></h2>
#{footer()}>>;
    }
    send_directive("_html",{"content":html});
  }
}
