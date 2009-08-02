$(function() {
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
});