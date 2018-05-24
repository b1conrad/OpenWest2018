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
    li = function(array) {
      array.map(function(v){<<<li>#{v}</li>
>>})
    }
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
    about_me = function(placement) {
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
      $("p#prelude").empty().append($("<a>",{href:url,text:url}));
      $("div").qrcode(url);
      var canvas = $("div canvas").get(0);
      var context = canvas.getContext("2d");
      var logo = new Image();
      logo.src = "#{pc_host}/pico-logo-48x48.png";
      logo.onload = function(){
        context.drawImage(logo,104,104);
      }
      var pngUrl = canvas.toDataURL();
      $("p#postlude").append($("<a>",{href:pngUrl,text:"image link"}));
});
</script>
>>;
      <<#{header(my_name,scripts)}
    <h1>#{my_name}</h1>
    <h2>#{me:tag_line()}</h2>
<p id="prelude"></p>
<div style="border:1px dashed silver;padding:5px;float:left"></div>
<br clear="all">
<p id="postlude"></p>
<p>pin: #{me:pin()} #{progress}</p>
<p>Connections: <ul>
#{li(me:connections()).join("")}</ul></p>
#{footer()}>>
    }
  }
}
