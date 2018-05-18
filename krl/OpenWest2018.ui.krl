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
    header = function(title) {
      <<<!DOCTYPE HTML>
<html>
  <head>
    <title>#{title}</title>
    <meta charset="UTF-8">
  </head>
  <body>
>>
    }
    footer = function() {
      <<  </body>
</html>
>>
    }
    html = function(id,pin) {
      <<#{header(pin)}<pre>id=#{id}</pre>
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
      send_directive("_cookie",{"cookie":<<whoami=#{pin}; Path=/sky>>});
      send_directive("_html",{"content":html(id,pin)});
    }
  }
  rule tag_recovery_needed {
    select when tag recovery_needed
  }
  rule tag_subsequent_scan {
    select when tag subsequent_scan
  }
}
