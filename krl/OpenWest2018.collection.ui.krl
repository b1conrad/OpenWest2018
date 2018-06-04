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

    as_ordinal = function(n) {
      n == 1 => "First"  |
      n == 2 => "Second" |
      n == 3 => "Third"  |
                n+"th"
    }
    scores_dd = function(v){
      label = all:attendee_designation(v);
      style = "white-space:nowrap;overflow:hidden";
      <<#{label==v => v | "<!-- "+v+" --> "+label}>>
    }
    scores_row = function(scores_map) {
      scores_map.keys()
        .map(function(k,n){
          v = scores_map{k};
          tied = v.length() > 1 => "<br>(tie)" | "";
          <<        <td>#{as_ordinal(n+1)}#{tied}</td>
        <td class="ra">#{k.replace("count=","")}</td>
        <td>#{v.map(scores_dd).join("<br>")}</td>
>>
        }).values()
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
    <div style="margin-left:100px;width:100%">
    <h2>Top Five Scores</h2>
    <table style="max-width:100%">
      <tr>
        <th>place</th>
        <th class="ra">connections
          <br>(#{all:connections_possible()} possible)
        </th>
        <th>winner</th></tr>
      <tr>
#{scores_row(high_scores).join("      </tr>
      <tr>
")}      </tr>
    </table>
    </div>
    <div id="logo">
      <img src="http://picos.byu.edu:8080/pico-logo-transparent-48x48.png" alt="Pico Labs logo">
      <p style="margin:0;font-family:sans-serif">
        <span style="color:#2DA2D9;margin-left:-10px">Pico Labs</span>
        <a href="http://picolabs.io"> http://picolabs.io/</a>
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
p a {
  text-decoration: none;
  text-transform: uppercase;
  font-family: arial;
  font-size: 80%;
}
table {
  border-spacing: 5px 10px;
}
th {
  text-align: left;
  vertical-align: top;
  white-space:nowrap;
}
td {
  vertical-align: top;
  max-width:100%;
  white-space:nowrap;
  overflow:hidden;
  text-overflow: ellipsis;
}
th.ra, td.ra {
  text-align: right;
}
</style>
>>;
  }
}
