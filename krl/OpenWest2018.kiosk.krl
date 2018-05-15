ruleset OpenWest2018.web {
  meta {
    provides header, footer
    shares __testing, index, lcars
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ ] }
    lcars_url = "https://raw.githubusercontent.com/joernweissenborn/lcars/master/lcars/css/lcars.min.css";
    lcars = function() {
      http:get(lcars_url){"content"}
    }
    header = function(title,bg_color) {
      the_css = meta:host + "/sky/cloud/" + meta:eci + "/" + meta:rid + "/lcars.css";
      bg = "lcars-" + (bg_color || "tan") +"-bg";
      <<<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>#{title}</title>
  <link rel="stylesheet" href="#{the_css}">
  <style>
  html, body { background: black; }
  body { overflow: hidden; }
  .lcars-byu-blue-bg { background-color: #002255 !important; }
  .lcars-byu-tan-bg { background-color: #c5af7d !important; }
  </style>
</head>
<body>
<div class="lcars-app-container">
<div id="header" class="lcars-row header">
<div class="lcars-elbow left-bottom #{bg}"></div>
<div class="lcars-bar horizontal #{bg}">
<div class="lcars-title right">#{title}</div>
</div>
<div class="lcars-bar horizontal right-end decorated #{bg}"></div>
</div>
<div id="left-menu" class="lcars-column start-space lcars-u-l">
<div class="lcars-bar lcars-u-1 #{bg}"></div>
</div>
<div id="footer" class="lcars-row">
<div class="lcars-elbow left-top #{bg}"></div>
<div class="lcars-bar horizontal both-divider bottom #{bg}"></div>
<div class="lcars-bar horizontal right-end left-divider bottom #{bg}"></div>
</div>
<div id="container">
<div class="lcars-column lcars-u-5">
>>
    }
    footer = function() {
      <<
</div>
</div>
</div>
</body>
</html>
>>
    }
    index = function(bg_color) {
      pc_host = meta:host; // personal cloud host; for now the same

      img_host = "https://upload.wikimedia.org/wikipedia/en/thumb/2/27/";
      img_name = "Flag_of_the_United_Federation_of_Planets.svg";
      img_link = <<#{img_host}#{img_name}/640px-#{img_name}.png>>;

      img_qrid = <<#{meta:host}/qrcode.html?#{pc_host}/qr/tag/scanned?id=>>;

      <<#{header("OpenWest 2018",bg_color)}
<a href="#{img_qrid+"1387"}"><img src="#{img_link}" alt="#{img_name}"></a>
#{footer()}>>
    }
  }
}
