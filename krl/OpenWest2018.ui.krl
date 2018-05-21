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
    html = function(id,pin) {
      scripts = <<<script src="#{pc_host}/js/jquery-3.1.0.min.js"></script>
<!-- thanks to Jerome Etienne http://jeromeetienne.github.io/jquery-qrcode/ -->
<script type="text/javascript" src="#{pc_host}/js/jquery.qrcode.js"></script>
<script type="text/javascript" src="#{pc_host}/js/qrcode.js"></script>
<script type="text/javascript">
$(function(){
      var url = "#{pc_host}/qr/tag/scanned?id=#{id}";
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
      <<#{header(pin,scripts)}<pre>id=#{id}</pre>
<p id="prelude"></p>
<div style="border:1px dashed silver;padding:5px;float:left"></div>
<br clear="all">
<p id="postlude"></p>
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
      html = <<#{header(pin)}<h1>Welcome #{scanned_by}</h1>#{footer()}>>;
    }
    send_directive("_html",{"content":html});
  }
}
