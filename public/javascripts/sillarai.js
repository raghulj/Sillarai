
          $(function () { $("#date_select").datepicker({
                  numberOfMonths: 3,
                  showButtonPanel: true,
                  altFormat: 'MM, DD, yy',
                  onSelect:  function(dateText, inst) {
                  document.getElementById('expense_data').value = document.getElementById('expense_data').value+ ' '+ $(this).val();
                  $('#date_select').hide();
                  document.getElementById('expense_data').focus();
                  }



            })
          });
    $(document).shortkeys({
          'Space+Z': function () { $('#date_select').show(); }

          });
          
          
          
          
   

	$(function() {

		$(".ui-widget-conten").draggable({
			//revert: 'invalid',
			containment:$('.demo'),
      optacity: 5,
		  cursor: 'move',	
      handle:'div#handle',
      cursorAt:{top: -3,left: -4},
			helper: function(event){
        return $('<div style="border: 1px solid #379E0E;background:#BFFEA5;float:right;">Move to </div>');
      }

		});
		$(".cat_drop").droppable({
      //tolerance: 'touch',
      hoverClass: 'ui-state-active',
			drop: function(event, ui) {
        $.ajax({
            url: "/expenses/add_category",
            type:'post',
            data: 'eid='+ui.draggable.attr('id')+'&cid='+$(this).attr('id'),
            success: function(resp){
              document.getElementById('expense_colour_'+resp.id).style.background = '#'+resp.color;
              document.getElementById('expense_colour_'+resp.id).style.border = '1px solid #'+resp.color; 
              notify('Updated successfully');
            }
          })
				

			}
		});

    $('div').disableSelection();
	});

function addCategory(){
  var itemsDiv = document.getElementById("items");
  itemsDiv.innerHTML += 

   ' <div id="drop3" style="border:1px solid #ccc;width: 150px; height: 30px; padding: 1px; float: left; margin: 10px;" class ="dropppp">' +
      document.getElementById("category_name").value + 
     ' </div>';

}

