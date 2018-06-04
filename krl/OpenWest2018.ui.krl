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
      form_url = <<#{pc_host}/qr/tag/initials_provided>>;
      <<#{header(pin,scripts)}<pre>pin=#{pin}</pre>
<p>For the scoreboard:</p>
<form action="#{form_url}">
<p>Please enter a short name or your initials:</p>
<input type="hidden" name="pin" value="#{pin}">
<input name="name" placeholder="initials" size="10" maxlength="10">
<p>Please enter a one line description of yourself:</p>
<input name="tag_line" placeholder="one-liner about me" size="40" maxlength="140">
<p></p>
<input type="submit">
</form>
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
    pre {
      id = event:attr("id");
      form_url = <<#{pc_host}/qr/tag/recovery_codes_provided>>;
      html = <<#{header("Connections recovery")}<h1>Connections recovery</h1>
<p>Please enter codes to recover your connections</p>
<form action="#{form_url}">
<input type="hidden" name="id" value="#{id}">
<input name="date" placeholder="code part one">
<input name="time" placeholder="code part two">
<input name="millis" placeholder="code part three">
<br>
<input type="submit">
</form>
#{footer()}>>
    }
    send_directive("_html",{"content":html})
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
  rule tag_initials_provided {
    select when tag initials_provided
    pre {
      pin = event:attr("pin");
      name = event:attr("name") || pin;
      html = <<#{header(name)}<h1>Welcome #{name}</h1>
<h2><a href="#{page_url(pin)}">my page</a>!</h2>
<p>Hint: take a screenshot of your page and/or request a sticker with your QR Code.</p>
#{footer()}>>;
    }
    send_directive("_html",{"content":html});
  }
  rule tag_recovery_codes_accepted {
    select when tag recovery_codes_accepted
    pre {
      ok = event:attr("txnId") == meta:txnId;
      pin = ids:as_pin(event:attr("id"));
      html = <<#{header("Connections recovered")}<h1>Connections recovered</h1>
<h2><a href="#{page_url(pin)}">my page</a></h2>
#{footer()}>>;
    }
    if ok then every {
      send_directive("_cookie",{"cookie":<<whoami=#{pin}; Path=/>>});
      send_directive("_html",{"content":html});
    }
  }
}
