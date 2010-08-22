// I know, I know.
$(function() {
    // #M0001 -> $(the section + the method body)
    function m(name) {
      var base = $(name);
      return base.parent().add(base.next());
    }
    
    // #class-something -> $(the section below)
    function s(name) {
      return $(name).next();
    }

  $('.source-link a').click(function() {
    var link = $(this);
    var code = link.parent().next();
    if (link.text() == 'show source') {
      code.show();
      link.text('hide source');
    } else {
      code.hide();
      link.text('show source');
    }
    return false;
  });
  
  if ($('.ref')[0]) {
    
    $('.mod').hide(); 
    $('.method').hide();
    
    var hash = window.location.hash.replace(/--$/, '');
    
    if (hash.substring(0, 2) == "#M") {
      // Show the method and the section
      m(hash).show();
    } else if (hash.substring(0, 7) == "#class-") {
      // Show the section.
      s(hash).show();
    } else {
      // Show the first section.
      s("h2:first").show();
    }
    
    // We need to scroll!
    if (hash != window.location.hash) {
      window.location.hash = hash;
    }
    
    $('a[href*="#class-"]').click(function() {
      var link = this.href;
      var id = link.substring(link.indexOf("#"));
      if ($(this).parent().is("h2")) {
        // We're in a headline
        s(id).toggle();
        window.location.hash = id + "--";
        return false;
      } else {
        // A normal link
        s(id).show();
      }
    });
    
    $('a[href*="#M"]').click(function() {
      var link = this.href;
      var id = link.substring(link.indexOf("#"));
      if ($(this).parent().is("h4")) {
        // We're in a headline
        window.location.hash = id + "--";
        s(id).toggle();
        return false;
      } else {
        // Normal link
        m(id).show();
      }
    });
    
  }
  
});