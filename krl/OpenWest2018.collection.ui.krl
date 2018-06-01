ruleset OpenWest2018.collection.ui {
  meta {
    use module OpenWest2018.collection alias all
    shares __testing, high_scores_page
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "high_scores_page" }
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
    scores_dd = function(v){
      label = all:attendee_designation(v);
      style = "white-space:nowrap;overflow:hidden";
      <<        <dd style="#{style}">#{label==v => v | "<!-- "+v+" --> "+label}</dd>
>>
    }
    scores_dt = function(scores_map) {
      scores_map.klog("scores_map")
        .map(function(v,k){
          <<      <dt>#{k.replace("count=","")}</dt>
#{v.map(scores_dd).join("")}>>}).values()
    }
    show_top = 5;
    high_scores_page = function() {
      all_scores = all:high_scores();
      need_slice = all_scores.length() >= show_top;
      high_score_keys = need_slice => all_scores.keys().slice(show_top-1)
                                    | all_scores.keys();
      high_scores = all_scores
        .filter(function(v,k){high_score_keys >< k});
      <<#{header("High Scores",css)}    <h1>Manifold Connection Collection</h1>
    <div style="margin-left:100px">
    <h2>Top Five Scores</h2>
    <dl>
#{scores_dt(high_scores).join("")}
    </dl>
    </div>
    <div id="logo">
      <img src="http://picos.byu.edu:8080/pico-logo-transparent-48x48.png" alt="Pico Labs logo">
      <p style="margin:0;font-family:sans-serif">
        <span style="color:#2DA2D9;margin-left:-10px">Pico Labs</span>
        <a href="http://picolabs.io">http://picolabs.io/</a>
      </p>
    </div>
#{footer()}>>
    }
    css = <<<style type="text/css">
body, html {
  height: 100%;
  width: 100%;
  margin: 0;
}
body {
  margin-left: 10px;
  background-color: #2DA2D9;
  background-image: linear-gradient(#2DA2D9, white);
}
h1 {
  color: white;
  text-transform: uppercase;
  font-family: arial;
}
div#logo {
  position: absolute;
  bottom: 0;
  left: 15px;
}
</style>
>>;
  }
}
