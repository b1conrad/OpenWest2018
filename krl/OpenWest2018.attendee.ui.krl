ruleset OpenWest2018.attendee.ui {
  meta {
    use module io.picolabs.wrangler alias wrangler
    use module OpenWest2018.attendee alias me
    shares __testing, about_me
  }
  global {
    __testing = { "queries": [ { "name": "__testing" }],
                  "events": [] }
    about_me = function() {
      my_name = me:name();
      intro_url = <</sky/event/#{me:intro_channel_id()}/none/intro/tag_scanned>>;
      <<<!DOCTYPE HTML>
<html>
  <head>
    <title>#{my_name}</title>
    <meta charset="UTF-8">
  </head>
  <body>
    <h1>#{my_name}</h1>
    <h2>#{me:tag_line()}</h2>
    <a href="#{intro_url}">#{me:intro_channel_id()}</a>
  </body>
</html>
>>
    }
  }
}
