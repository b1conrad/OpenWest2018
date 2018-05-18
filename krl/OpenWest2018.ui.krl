ruleset OpenWest2018.ui {
  meta {
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
    <title>tab title</title>
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
  }
  rule tag_first_scan {
    select when tag first_scan
  }
  rule tag_recovery_needed {
    select when tag recovery_needed
  }
  rule tag_subsequent_scan {
    select when tag subsequent_scan
  }
}
