et OpenWest2018.contact_info {
  meta {
    use module io.picolabs.pds alias store
    use module OpenWest2018.attendee alias Attendee
    use module io.picolabs.wrangler alias Wrangler
    shares __testing, returnInfo
  }
  
  global {
    __testing = {"events" : [{"domain" : "contact", "type" : "getter"}],
                 "queries" : [{"name" : "accordion"}]}
    
    returnInfo = function() {
      store:read_all()
    }
    
    setterUI = function() {
      pc_host = "http://picos.byu.edu:8080";
      pin = Attendee:pin();
      info = store:read_all();
      <<<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="http://picos.byu.edu:8080/css/picomobile.css">
    <link rel="stylesheet" href="https://use.typekit.net/miv2swc.css">

    <title>My Information</title>
    <script type="text/javascript">
    
    $(function(){closeMenubar();});
    
        function openMenubar() {
          document.getElementById("myMenu").style.display = "block";
        }

        function closeMenubar() {
          document.getElementById("myMenu").style.display = "none";
        }
    </script>

  </head>
  <body onload="closeMenubar()">

<!-- No Variables -->
      <nav class="menubar block card" id="myMenu">
        <div class="container light-blue">
          <span onclick="closeMenubar()" class="button show-topright small">X</span>
          <br>
          <div class="padding center">
            <h2>Menu</h2>
          </div>
        </div>
        <a class="bar-item button" href="#{pc_host}/OpenWest2018.collection/about_pin.html?pin=#{pin}">Home</a>
        <a class="bar-item button" href="http://picos.byu.edu:8080/sky/event/#{meta:eci}/contactTest/contact/getter">Contacts</a>
        <a class="bar-item button" href="#">My Information</a>
      </nav>
<!-- end no variables -->


    <!-- COMBINED NAME AND PHRASE AND PUT IN CARD-->
    <header class="bar card blue">
      <button class="bar-item button large blue-theme" onclick="openMenubar()">&#9776;</button>
        <h1 class="bar-item">My Information</h1>
    </header>
    <hr>
    <div class="row">
    <form action="http://picos.byu.edu:8080/sky/event/#{meta:eci}/contactTest/contact/setter">
      First Name:<br><input type="text" name="first name" required value=#{info{"first name"}.defaultsTo("")}>
      <br><br>
      Last Name:<br><input type="text" name="last name" required value=#{info{"last name"}.defaultsTo("")}>
      <br><br>
      *Home phone:<br><input type="text" name="home" value=#{info{"home"}.defaultsTo("")}>
      <br><br>
      *Work phone:<br><input type="text" name="work" value=#{info{"work"}.defaultsTo("")}>
      <br><br>
      *Cell phone:<br><input type="text" name="cell" value=#{info{"cell"}.defaultsTo("")}>
      <br><br>
      *Email:<br><input type="text" name="email" value=#{info{"email"}.defaultsTo("")}>
      <br><br>
      <input type="submit" value="Save Contact Information">
    </form>
    </div>

    <br>
    <br>
    <br>
    <br>
    <br>
    <br>
    <br>
    <br>
    <br>
    <br>

<!--    No variables here -->
  <footer class="container bottom blue">
    <div class="center"><h4>Contact. Connect. Collect!</h4></div>
  </footer>
  </body>
</html>
        >>
    }
    
    li = function(info) {
      noName = info.filter(function(v, k){not k.match(re#name#)});
      map = noName.map(function(v, k) {<<<li>#{k}: #{v}</li> >>});
      (map.values()[0].isnull()) => "No contact information available" | map.values().join("");
    }
    
    accordion = function(info) {
      contacts = Attendee:connections();
      
      contacts.map(function(x){
      ri = Wrangler:skyQuery(x{"eci"}, "OpenWest2018.contact_info", "returnInfo").klog("ri");
      line = <<<div class="panel"><h5>Name: #{ri.filter(function(v2, k2){k2 == "first name" || k2 == "last name"}).values().join(" ")}<br>#{ri.filter(function(v1, k1){k1 != "first name" && k1 != "last name" && v1 != ""}).map(function(v, k){<<#{k}: #{v}<br> >>}).values().join("")}</h5></div><hr> >>;
      generatePanel = ri{"error"} => <<<div class="panel"><h5>Contact information unavailable</h5></div><hr> >> | (ri{"first name"} => line | <<<div class="panel"><h5>No information available</h5></div><hr> >>);
      <<
      <button class="accordion">#{x{"designation"}}</button>
        #{generatePanel}
      >>}).join("")
    }
    
    getterUI = function(map) {
      pc_host = "http://picos.byu.edu:8080";
      pin = Attendee:pin();
      <<<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="http://picos.byu.edu:8080/css/picomobile.css">
    <link rel="stylesheet" href="https://use.typekit.net/miv2swc.css">

    <title>Contacts</title>
    <script type="text/javascript">
    
        function openMenubar() {
          document.getElementById("myMenu").style.display = "block";
        }

        function closeMenubar() {
          document.getElementById("myMenu").style.display = "none";
        }
    </script>

  </head>
  <body onload="closeMenubar()">

<!-- No Variables -->
      <nav class="menubar block card" id="myMenu">
        <div class="container light-blue">
          <span onclick="closeMenubar()" class="button show-topright small">X</span>
          <br>
          <div class="padding center">
            <h2>Menu</h2>
          </div>
        </div>
        <a class="bar-item button" href="#{pc_host}/OpenWest2018.collection/about_pin.html?pin=#{pin}">Home</a>
        <a class="bar-item button" href="#">Contacts</a>
        <a class="bar-item button" href="http://picos.byu.edu:8080/sky/event/#{meta:eci}/contactTest/contact/setter_ui">My Information</a>
      </nav>
<!-- end no variables -->


    <!-- COMBINED NAME AND PHRASE AND PUT IN CARD-->
    <header class="bar card blue">
      <button class="bar-item button large blue-theme" onclick="openMenubar()">&#9776;</button>
        <h1 class="bar-item">Contacts</h1>
    </header>
    


    #{accordion(info)}


    <br>
    <br>
    <br>
    <br>
    <br>
    <br>
    <br>
    <br>
    <br>
    <br>

<!--    No variables here -->
  <footer class="container bottom blue">
    <div class="center"><h4>Contact. Connect. Collect!</h4></div>
  </footer>
  
  <script>
  var acc = document.getElementsByClassName("accordion");
  var i;

  for (i = 0; i < acc.length; i++) {
    acc[i].addEventListener("click", function() {
      this.classList.toggle("active");
      var panel = this.nextElementSibling;
      if (panel.style.display === "block") {
      panel.style.display = "none";
      } else {
        panel.style.display = "block";
      }
    });
  }
  </script>
  
  </body>
</html>
        >>
    }
  }
  
  rule get_info {
    select when contact getter
    pre {
      info = store:read_all()
    }
    send_directive("_html", {"content" : getterUI(info)})
  }
  
  
  rule set_info {
    select when contact setter
    
    foreach event:attrs setting (v, k)
    
    if not k != "_headers" then send_directive("_html", {"content" : getterUI(store:read_all())})//noop();
      fired {
        raise store event "new_value" 
        attributes {"key" : k, "value" : v};
      }
  }
  
  rule set_info_ui {
    select when contact setter_ui
    pre {html = setterUI()}
    send_directive("_html", {"content" : html})
  }
  

}
