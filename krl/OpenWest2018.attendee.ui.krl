ruleset OpenWest2018.attendee.ui {
  meta {
    use module io.picolabs.wrangler alias wrangler
    use module OpenWest2018.attendee alias me
    shares __testing, about_me
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
//---------- hard-coded personal cloud server -----------------------
//
    pc_host = "http://picos.byu.edu:8080"

//--------- standard HTML header ------------------------------------
//title and optional scripts
//
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
//--------- standard HTML footer ------------------------------------
//
    footer = function() {
      <<  </body>
</html>
>>
    }
//----- generate HTML for an array of list items --------------------
    li = function(array) {
      array.map(function(v){<<<li>#{v}</li>
>>}).join("")
    }
//------------- ordinal string in English for a positive integer-----
//
    ordinalize = function(n) {
      unit = n % 10;
      teen = 10 <= n && n < 20;
      suffix = teen      => "th"
             | unit == 1 => "st"
             | unit == 2 => "nd"
             | unit == 3 => "rd"
             |              "th";
      n.as("String") + suffix;
    }
//--------- compute placement string -------------------------------
// render  ::= ["tied for "] ordinal " place" [" out of " TOTAL ]
// ordinal ::= "first" | "second" | "third" | "4th" | ... | "42nd" | ... | "last"
//
    render = function(placement) {
      ranking = placement{"place"};
      places = placement{"out_of"};
      last_place = ranking >= places;
      rank = last_place => "last"
           | ranking==1 => "first"
           | ranking==2 => "second"
           | ranking==3 => "third"
           |               ordinalize(ranking);
      prefix = placement{"tied"} => "tied for " | "";
      prefix + rank + " place"
        + (places > 1 => " out of " + places | "")
    }
//----------- generate HTML for the about me page ------------------
//
    about_me = function(placement) {
      connections = me:connections();
      progress = placement => render(placement.decode()) | "";
      my_name = me:name();
      intro_url = <</sky/event/#{me:intro_channel_id()}/intro/tag/scanned>>;
      scripts = <<<script src="#{pc_host}/js/jquery-3.1.0.min.js"></script>
<!-- thanks to Jerome Etienne http://jeromeetienne.github.io/jquery-qrcode/ -->
<script type="text/javascript" src="#{pc_host}/js/jquery.qrcode.js"></script>
<script type="text/javascript" src="#{pc_host}/js/qrcode.js"></script>
<script type="text/javascript">
$(function(){
      var url = "#{pc_host + intro_url}";
      $("div").qrcode(url);
      $("div").click(function(){location=url});
      var canvas = $("div canvas").get(0);
      var context = canvas.getContext("2d");
      var logo = new Image();
      logo.src = "#{pc_host}/pico-logo-48x48.png";
      logo.onload = function(){
        context.drawImage(logo,104,104);
      }
});
</script>
>>;
      <<#{header(my_name,scripts)}
    <h1>#{my_name}</h1>
    <h2>#{me:tag_line()}</h2>
<div style="border:1px dashed silver;padding:5px;float:left;cursor:pointer"></div>
<br clear="all">
<p>pin: #{me:pin()} #{progress}</p>
<p>
Connections (#{connections.length()}):
<ul>
#{li(connections)}</ul>
</p>
#{footer()}>>
    }
    my_page_link = function(pin) {
      url = <<#{pc_host}/OpenWest2018.collection/about_pin.html?pin=#{pin}>>;
      <<<a href="#{url}">my page</a>
>>
    }
  }
  rule recruit_booth_visitor {
    select when attendee unknown_scanner
    pre {
      connections_count = event:attr("connections_count");
      connection_s = connections_count == 1 => "connection" | "connections";
    }
    send_directive("_html",{"content":<<#{header("Connection Collection")}
  <h1>Connection Collection</h1>
  <h2>Most connections wins a daily prize!</h2>
  <p>Please visit the Pico Labs booth to participate</p>
  <p>You have #{connections_count} pending #{connection_s}</p>
Sponsored by <a href="http://picolabs.io/">Pico Labs</a>
#{footer()}>>});
  }
  rule notify_attempt_to_connect_to_self {
    select when attendee scan_self
    send_directive("_html",{"content":<<#{header("Cannot connect to self")}<p>
Cannot make a connection with yourself
</p>
#{my_page_link(event:attr("scanner_pin"))}
#{footer()}>>});
  }
  rule notify_attempted_duplicate {
    select when attendee already_connected
    send_directive("_html",{"content":<<#{header("Already connected")}<p>
You are already connected to #{event:attr("designation")}
</p>
#{my_page_link(event:attr("scanner_pin"))}
#{footer()}>>});
  }
  rule notify_connection {
    select when attendee connected
    send_directive("_html",{"content":<<#{header("Connected")}<p>
You are now connected to #{event:attr("designation")}
</p>
#{my_page_link(event:attr("scanner_pin"))}
#{footer()}>>});
  }
}
