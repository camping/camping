CAMPING_EXTRAS_DIR = File.expand_path(File.dirname(__FILE__))
require 'rdoc/generator/html'

module RDoc::Generator
[Class, File].each do |klass|
  old = klass.instance_method(:value_hash)
  klass.send(:define_method, :value_hash) {
    old.bind(self).call
    @values['root'] = @path.split("/").map { ".." }[1..-1].join("/")
    @values
  }
end

module HTML::FLIPBOOK
######################################################################
#
# The following is used for the -1 option
#

FONTS = "verdana,arial,'Bitstream Vera Sans',helvetica,sans-serif"

STYLE = %{
    body, th, td {
        font: normal 14px verdana,arial,'Bitstream Vera Sans',helvetica,sans-serif;
        line-height: 160%;
        padding: 0; margin: 0;
        margin-bottom: 30px;
        /* background-color: #402; */
        background-color: #694;
    }
    h1, h2, h3, h4 {
        font-family: Utopia, Georgia, serif;
        font-weight: bold;
        letter-spacing: -0.018em;
    }
    h1 { font-size: 24px; margin: .15em 1em 0 0 }
    h2 { font-size: 24px }
    h3 { font-size: 19px }
    h4 { font-size: 17px; font-weight: normal; }
    h4.ruled { border-bottom: solid 1px #CC9; }
    h2.ruled { padding-top: 35px; border-top: solid 1px #AA5; }

    /* Link styles */
    :link, :visited {
        color: #00b;
    }
    :link:hover, :visited:hover {
        background-color: #eee;
        color: #B22;
    }
    #fullpage {
        width: 720px;
        margin: 0 auto;
    }
    .page_shade, .page {
        padding: 0px 5px 5px 0px;
        background-color: #fcfcf9;
        border: solid 1px #983;
    }
    .page {
        margin-left: -5px;
        margin-top: -5px;
        padding: 20px 35px;
    }
    .page .header {
        float: right;
        color: #777;
        font-size: 10px;
    }
    .page h1, .page h2, .page h3 {
        clear: both;
        text-align: center;
    }
    #pager {
        padding: 10px 4px;
        color: white;
        font-size: 11px;
    }
    #pager :link, #pager :visited {
        color: #bfb;
        padding: 0px 5px;
    }
    #pager :link:hover, #pager :visited:hover {
        background-color: #262;
        color: white;
    }
    #logo { float: left; }
    #menu { background-color: #dfa; padding: 4px 12px; margin: 0; }
    #menu h3 { padding: 0; margin: 0; }
    #menu #links { float: right; }
    pre { font-weight: bold; color: #730; }
    tt { color: #703; font-size: 12pt; }
    .dyn-source { background-color: #775915; padding: 4px 8px; margin: 0; display: none; }
    .dyn-source pre  { color: #DDDDDD; font-size: 8pt; }
    .source-link     { text-align: right; font-size: 8pt; }
    .ruby-comment    { color: green; font-style: italic }
    .ruby-constant   { color: #CCDDFF; font-weight: bold; }
    .ruby-identifier { color: #CCCCCC;  }
    .ruby-ivar       { color: #BBCCFF; }
    .ruby-keyword    { color: #EEEEFF; font-weight: bold }
    .ruby-node       { color: #FFFFFF; }
    .ruby-operator   { color: #CCCCCC;  }
    .ruby-regexp     { color: #DDFFDD; }
    .ruby-value      { color: #FFAAAA; font-style: italic }
    .kw { color: #DDDDFF; font-weight: bold }
    .cmt { color: #CCFFCC; font-style: italic }
    .str { color: #EECCCC; font-style: italic }
    .re  { color: #EECCCC; }
}

CONTENTS_XML = %q{
<%= values['description'] if values['description'] %>

<% if values['requires'] %>
  <h4>Requires:</h4>
  <ul>
  <% values['requires'].each do |req| %>
    <li><%= href(req['aref'], req['name']) %></li>
  <% end %>
<% end %>

<% if values['attributes'] %>
  <h4>Attributes</h4>
  <table>
  <% values['attribtes'].each do |attr| %>
    <tr><td><%= attr['name'] %></td><td><%= attr['rw'] %></td><td><%= attr['a_desc'] %></td></tr>
  <% end %>
</table>
<% end %>

<% if values['includes'] %>
  <h4>Includes</h4>
  <ul>
  <% values['includes'].each do |i| %>
    <li><%= href i['aref'], i['name'] %></li>
  <% end %>
  </ul> 
<% end %>

<% values['sections'].each do |sec| %>
  <% if sec['method_list'] %>
    <h2 class="ruled">Methods</h2>
    <% sec['method_list'].each do |ml| %>
      <% if ml['methods'] %>
        <% ml['methods'].each do |m| %>
          <h4 class="ruled"><%= m['type'] %> <%= m['category'] %> method:
          <% c = m['callseq'] %>
          <strong id="<%= m['aref'] %>"><%= c ? c : m['name'] + m['params'] %></strong>
          <a href="#<%= m['aref'] %>"><img src="<%= values['root'] %>/permalink.gif" border="0" title="Permalink to <%= c ? c : "#{m['type']} #{m['category']} method: #{m['name']}" %>" /></a></h4> 
        
          <%= m['m_desc'] if m['m_desc'] %>
        
          <% if m['sourcecode'] %>
            <div class="sourcecode">
            <p class="source-link">[ <a href="javascript:toggleSource('<%= m['aref'] %>_source')" id="l_<%= m['aref'] %>_source">show source</a> ]</p>
            <div id="<%= m['aref'] %>_source" class="dyn-source">
            <pre>
            <%= m['sourcecode'] %>
            </pre>
            </div>
            </div>
          <% end %>
        <% end %>
      <% end %>
    <% end %>                
  <% end %>
<% end %>
}

############################################################################


BODY = %q{
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <title>
  <% if values['title'] %>
    <%= values['realtitle'] %> &raquo; <%= values['title'] %>
  <% else %>
    <%= values['realtitle'] %>
  <% end %>
  </title>
  <meta http-equiv="Content-Type" content="text/html; charset=<%= values['charset'] %>" />
  <link rel="stylesheet" href="<%= values['style_url'] %>" type="text/css" media="screen" />
    <script language="JavaScript" type="text/javascript">
    // <![CDATA[

    function toggleSource( id )
    {
    var elem
    var link

    if( document.getElementById )
    {
    elem = document.getElementById( id )
    link = document.getElementById( "l_" + id )
    }
    else if ( document.all )
    {
    elem = eval( "document.all." + id )
    link = eval( "document.all.l_" + id )
    }
    else
    return false;

    if( elem.style.display == "block" )
    {
    elem.style.display = "none"
    link.innerHTML = "show source"
    }
    else
    {
    elem.style.display = "block"
    link.innerHTML = "hide source"
    }
    }

    function openCode( url )
    {
    window.open( url, "SOURCE_CODE", "width=400,height=400,scrollbars=yes" )
    }
    // ]]>
    </script>
</head>
<body>
<div id="menu">
<div id="links">
    <a href="http://redhanded.hobix.com/bits/campingAMicroframework.html">backstory</a> |
    <a href="http://code.whytheluckystiff.net/camping/">wiki</a> |
    <a href="http://code.whytheluckystiff.net/camping/newticket">bugs</a> |
    <a href="http://code.whytheluckystiff.net/svn/camping/">svn</a>
</div>
<h3 class="title"><%= values['title'] %></h3>
</div>
<div id="fullpage">
<div id="logo"><img src="<%= values['root'] %>/Camping.gif" /></div>
<div id="pager">
<strong>Files:</strong>
<% values['file_list'].each do |file| %>
  <%= href "#{file['href']}", file['name'] %>
<% end %>
<% if values['class_list'] %>
  |
  <strong>classes:</strong>
  <% values['class_list'].each do |klass| %>
    <%= href "#{klass['href']}", klass['name'] %>
  <% end %>
<% end %>
</ul>
</div>

    <%= template_include %>

</div>
</body>
</html>
}

###############################################################################

FILE_PAGE = <<_FILE_PAGE_
<div id="<%= values['full_path'] %>" class="page_shade">
<div class="page">
<div class="header">
  <div class="path"><%= values['full_path'] %> / <%= values['dtm_modified'] %></div>
</div>
#{CONTENTS_XML}
</div>
</div>
_FILE_PAGE_

###################################################################

CLASS_PAGE = %{
<div id="<%= values['full_name'] %>" class="page_shade">
<div class="page">
<% if values['parent'] %>
  <h3><%= values['classmod'] %> <%= values['full_name'] %> &lt; <%= href values['par_url'], values['parent'] %></h3>
<% else %>
  <h3><%= values['classmod'] %> <%= values['full_name'] %></h3>
<% end %>

<% if values['infiles'] %>
  (in files
  <% values['infiles'].each do |file| %>
    <%= href file['full_path_url'], file['full_path'] %>
  <% end %>
  )
<% end %>
} + CONTENTS_XML + %{
</div>
</div>
}

METHOD_LIST = ""
########################## Index ################################

FR_INDEX_BODY = %{
<%= template_include %>
}

FILE_INDEX = %{
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=<%= values['charset'] %>">
<style>
<!--
  body {
background-color: #ddddff;
     font-family: #{FONTS}; 
       font-size: 11px; 
      font-style: normal;
     line-height: 14px; 
           color: #000040;
  }
div.banner {
  background: #0000aa;
  color:      white;
  padding: 1;
  margin: 0;
  font-size: 90%;
  font-weight: bold;
  line-height: 1.1;
  text-align: center;
  width: 100%;
}
  
-->
</style>
<base target="docwin">
</head>
<body>
<div class="banner"><%= values['list_title'] %></div>
<% values['entries'].each do |entry| %>
  <%= href entry['href'], entry['name'] %><br>
<% end %>
</body></html>
}

CLASS_INDEX = FILE_INDEX
METHOD_INDEX = FILE_INDEX

INDEX = %{
<HTML>
<HEAD>
<META HTTP-EQUIV="refresh" content="0;URL=<%= values['initial_page'] %>">
<TITLE><%= values['realtitle'] %></TITLE>
</HEAD>
<BODY>
Click <a href="<%= values['initial_page'] %>">here</a> to open the Camping docs.
</BODY>
</HTML>
}

end
end
