module Generators
  class ContextUser
    def as_href(from_path)
      "javascript:showPage('#{path}')"
    end
    def aref_to(target)
      "javascript:showPage('#{target}')"
    end
    def url(target)
      HTMLGenerator.gen_url(path, target)
    end
  end
end

module RDoc
module Page
######################################################################
#
# The following is used for the -1 option
#

CONTENTS_XML = %{
IF:description
%description%
ENDIF:description

IF:requires
<h4>Requires:</h4>
<ul>
START:requires
IF:aref
<li><a href="javascript:showPage('%full_name%)">%name%</a></li>
ENDIF:aref
IFNOT:aref
<li>%name%</li>
ENDIF:aref 
END:requires
</ul>
ENDIF:requires

IF:attributes
<h4>Attributes</h4>
<table>
START:attributes
<tr><td>%name%</td><td>%rw%</td><td>%a_desc%</td></tr>
END:attributes
</table>
ENDIF:attributes

IF:includes
<h4>Includes</h4>
<ul>
START:includes
IF:aref
<li><a href="javascript:showPage('%full_name%')">%name%</a></li>
ENDIF:aref
IFNOT:aref
<li>%name%</li>
ENDIF:aref 
END:includes
</ul>
ENDIF:includes

IF:method_list
<h3>Methods</h3>
START:method_list
IF:methods
START:methods
<h4>%type% %category% method: 
IF:callseq
<a name="%aref%">%callseq%</a>
ENDIF:callseq
IFNOT:callseq
<a name="%aref%">%name%%params%</a></h4>
ENDIF:callseq

IF:m_desc
%m_desc%
ENDIF:m_desc

IF:sourcecode
<blockquote><pre>
%sourcecode%
</pre></blockquote>
ENDIF:sourcecode
END:methods
ENDIF:methods
END:method_list
ENDIF:method_list
}

########################################################################

ONE_PAGE = %{
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <title>%title%</title>
  <meta http-equiv="Content-Type" content="text/html; charset=%charset%" />
  <style type="text/css">
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
    h4 { font-size: 17px }

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
    .page_shade {
        display: none;
    }
    #README {
        display: block;
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
  </style>
  <script type="text/javascript" language="JavaScript">
    var current = 'README';
    function showPage(id) {
        var ele = document.getElementById(id);
        var c = document.getElementById(current);
        c.style.display = 'none';
        ele.style.display = 'block';
        current = id;
    }
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
<h3 class="title">Camping, the Documentation</h3>
</div>
<div id="fullpage">
<div id="logo"><img src="/Camping.gif" /></div>
<div id="pager">
<strong>Files:</strong>
START:files
<a href="javascript:showPage('%full_path%')" value="%title%">%full_path%</a>
END:files
IF:classes
|
<strong>classes:</strong>
START:classes
<a href="javascript:showPage('%full_name%')" title="%title%">%full_name%</a>
END:classes
ENDIF:classes
</ul>
</div>

START:files
<div id="%full_path%" class="page_shade">
<div class="page">
<div class="header">
  <div class="path">%full_path% / %dtm_modified%</div>
</div>
} + CONTENTS_XML + %{
</div>
</div>
END:files

IF:classes
START:classes
<div id="%full_name%" class="page_shade">
<div class="page">
IF:parent
<h3>%classmod% %full_name% &lt; HREF:par_url:parent:</h3>
ENDIF:parent
IFNOT:parent
<h3>%classmod% %full_name%</h3>
ENDIF:parent

IF:infiles
(in files
START:infiles
HREF:full_path_url:full_path:
END:infiles
)
ENDIF:infiles
} + CONTENTS_XML + %{
</div>
</div>
END:classes
ENDIF:classes
</div>
</body>
</html>
}

end
end
