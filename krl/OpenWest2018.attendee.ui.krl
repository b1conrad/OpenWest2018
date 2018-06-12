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
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="http://picos.byu.edu:8080/css/picomobile.css">
    <link rel="stylesheet" href="https://use.typekit.net/miv2swc.css">
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
      array.map(function(v){
        designation = v{"designation"}.klog("designation");
        ok_to_contact = v{"contactable"}.klog("ok_to_contact");
        button = ok_to_contact => <<<button id="contact#{array.index(v)}">Contact</button> >>
          | "";
        <<<li>#{designation}</li>
>>}).join("")
    }
//------ generate html to raise unique events for each button

    contact_buttons = function(array) {
      contact_channel = me:connections().map(function(c){c{"eci"}});
      array.map(function(v){
      contact_url = <</sky/event/#{contact_channel[array.index(v)]}/contact_clicked/contact/getter>>;
      <<var contact#{array.index(v)} = "#{pc_host + contact_url}";
      $("#contact#{array.index(v)}").click(function(){location=contact#{array.index(v)}});
      >>
      }).join("")
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
      connections = me:connections().klog("connections");
      progress = placement => render(placement.decode()) | "";
      possible = placement && placement.decode(){"total"}
        => "/"+(placement.decode(){"total"}-1) | "";
      my_name = me:name();
      intro_url = <</sky/event/#{me:intro_channel_id()}/intro/tag/scanned>>;
      export_url = <</sky/event/#{me:intro_channel_id()}/export/export/json>>;
      export_button = export_avail() => <<<button id="export" style="float:right">export</button>
>> | "";
      scripts = <<<script src="#{pc_host}/js/jquery-3.1.0.min.js"></script>
<!-- thanks to Jerome Etienne http://jeromeetienne.github.io/jquery-qrcode/ -->
<script type="text/javascript" src="#{pc_host}/js/jquery.qrcode.js"></script>
<script type="text/javascript" src="#{pc_host}/js/qrcode.js"></script>
<script type="text/javascript">
$(function(){
      var url = "#{pc_host + intro_url}";
      $("#cs").qrcode(url);
      $("#cs").click(function(){location=url});
      var canvas = $("div canvas").get(0);
      var context = canvas.getContext("2d");
      var logo = new Image();
      logo.src = "http://picos.byu.edu:8080/pico-logo-48x48.png";
      logo.onload = function(){
        context.drawImage(logo,104,104);
      }

      var export_url = "#{pc_host + export_url}";
      $("#export").click(function(){location=export_url});


          closeMenubar();
        });


        function openMenubar() {
          document.getElementById("myMenu").style.display = "block";
        }

        function closeMenubar() {
          document.getElementById("myMenu").style.display = "none";
        }
    </script>
>>;

//start of the body html
      <<#{header(my_name,scripts)}

      <nav class="menubar block card" id="myMenu">
        <div class="container light-blue">
          <span onclick="closeMenubar()" class="button show-topright small">X</span>
          <br>
          <div class="padding center">
            <h2>Menu</h2>
          </div>
        </div>
        <a class="bar-item button" href="#">Home</a>
        <a class="bar-item button" href="http://picos.byu.edu:8080/sky/event/#{meta:eci}/contactTest/contact/getter">Contacts</a>
        <a class="bar-item button" href="http://picos.byu.edu:8080/sky/event/#{meta:eci}/contactTest/contact/setter_ui">My Information</a>
      </nav>

      <!-- COMBINED NAME AND PHRASE AND PUT IN CARD-->
    <header class="bar card blue">
      <button class="bar-item button large w3-hover-theme" onclick="openMenubar()">&#9776;</button>
        #{export_button}
        <h1 class="bar-item">#{my_name}</h1>
    </header>
    <p>#{me:tag_line()}</p>
    <hr>
    <div class="row">
      <div class="center" style="width:100%">
        <div class="center" style="cursor:pointer;" id="cs"></div>
    </div>
      <hr>
      <div class="row">
        <h3>#{progress}</h3>
        <p>Your pin is #{me:pin()}</p>
        <hr>
        <p>
          Connections (#{connections.length()}#{possible}):
          <ul>
          #{li(connections)}</ul>
        </p>
        <br>
        <br>
        <br>
        <br>
        <br>
        <br>
        <br>
        <br>
        <br>
      </div>

      <footer class="container bottom blue" style="background:#D5ECF6">
        <div class="center"><h4 style="margin:0">Contact. Connect. Collect!</h4></div>
      </footer>

#{footer()}>>
    }
    my_page_link = function(pin) {
      url = <<#{pc_host}/OpenWest2018.collection/about_pin.html?pin=#{pin}>>;
      <<<a href="#{url}">my page</a>
>>
    }

    export_avail = function() {
      engine:listInstalledRIDs() >< "OpenWest2018.export"
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
    pre {pin = event:attr("scanner_pin");}
    send_directive("_html",{"content":<<

    <html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="http://picos.byu.edu:8080/css/picomobile.css">
    <link rel="stylesheet" href="https://use.typekit.net/miv2swc.css">
    <title>My Information</title>
  </head>
  <body>
    <header class="bar card blue">
        <h1 class="bar-item">Pico Created</h1>
    </header>
    <form action="#{pc_host}/OpenWest2018.collection/about_pin.html?pin=#{pin};>
      <input type="submit" value="My Page">
    </form>
    <footer class="container bottom blue">
      <div class="center"><h4>Contact. Connect. Collect!</h4></div>
    </footer>
  </body>
</html>
    >>});
  }
}
