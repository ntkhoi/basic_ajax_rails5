// $(function(){
//   $("form").submit(function(){
//     event.preventDefault();
//     var action = $(this).attr('action');
//     var method = $(this).attr('method');
//     var body = $(this).find('#message_body').val();
//      $.ajax({
//       method: method,
//       url: action,
//       data: { message: {body: body} },
//       dataType: 'script' // Make sure response is javascript not html
//     });
//   });
// });