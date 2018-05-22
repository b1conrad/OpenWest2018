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
      <<        <dd>#{v}</dd>
>>
    }
    scores_dt = function(scores_map) {
      scores_map.klog("scores_map")
        .map(function(v,k){
          <<      <dt>#{k.replace("count=","")}</dt>
#{v.map(scores_dd).join("")}>>}).values()
    }
    high_scores_page = function() {
      <<#{header("High Scores")}    <h1>High Scores</h1>
    <dl>
#{scores_dt(all:high_scores()).join("")}
    </dl>
#{footer()}>>
    }
  }
}