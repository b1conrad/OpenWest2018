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
    about_me = function() {
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
<p>pin: #{me:pin()}</p>
<p>Connections: <ul>
#{li(me:connections()).join("")}</ul></p>
#{footer()}>>
    }
  }
}
