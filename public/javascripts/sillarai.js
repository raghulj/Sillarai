
          $(function () { $("#date_select").datepicker({
                  numberOfMonths: 3,
                  showButtonPanel: true,
                  altFormat: 'MM, DD, yy',
                  onSelect:  function(dateText, inst) {
                  document.getElementById('expense_data').value = document.getElementById('expense_data').value+ ' '+ $(this).val();
                  $('#date_select').hide();
                  document.getElementById('expense_data').focus();
                  }
                  
                  });
          });
    $(document).shortkeys({
          'Space+Z': function () { $('#date_select').show(); }

          });
          
          
          
          
 

	$(function() {
   $("#upload_file_dialog").dialog({
//bgiframe: true, 
             autoOpen: false, 
             height: 300, 
             width: 400,
             modal: true/*,
             buttons: {
               'Upload': function(){
                      $(this).dialog('close');
                  },
               'Cancel': function(){
                      $(this).dialog('close');
                  }
             }*/

        });
      addDraggableProperty();

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

function addDraggableProperty(){
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

}

function addCategory(){
  var itemsDiv = document.getElementById("items");
  itemsDiv.innerHTML += 

   ' <div id="drop3" style="border:1px solid #ccc;width: 150px; height: 30px; padding: 1px; float: left; margin: 10px;" class ="dropppp">' +
      document.getElementById("category_name").value + 
     ' </div>';

}
function addExpenseDiv(exp_id,description,amount,dt,color){
  var str = '<div id="'+exp_id+'" class="ui-widget-conten ui-draggable" style="border:1px solid #ccc;height: 20px; width: 90%; padding: 2px; float: left; ">';
      str += ' <div id="handle" style="float:left;cursor:move;margin-right:8px;" >';
      //str += ' <% colr = get_category_colour(exp)%> ';
      str += '  <div id= "expense_colour_'+exp_id+'" style="border:1px solid #'+color+';float:right;height:17px;width:2px;margin-left:2px;background:#'+color+';"></div>';
      str += '  <div style="float:left"><img src="/images/icons/arrow_out.png"></div>';
      str += ' </div>';

      str += ' <div class="editable" style="float:left" id="'+exp_id+'">'+description+'</div>';
      str += '<p style="text-align:right">'+amount+'</p>';
      str += ' </div>';
      str += '<div id="delete'+exp_id+'" style="height:20px;padding:3px;">';
      str += '<a href="javascript:void(null);" onClick="ajaxRequest(\'/expenses/destroy\', '+exp_id+');"><img src="/images/icons/delete.png"></a>  </div>';
      return str;
}

function addExpenseDataOnly(dt,str){

      $("#date_"+dt).prepend(str);
      addDraggableProperty();
}

function saveExpense(){
  
  if($('#expense_data').val() == ""){
      notify(" Enter the expense amount");
  }else{
    $('progress_image').show('fast');
    $('#add_button').attr('disabled', 'disabled')
    $.ajax({
      url:'/expenses',
      type:'POST',
      data:{'expense' :document.getElementById('expense_data').value,'category[id]':document.getElementById('category_id').value},
      success: function(data){
        document.getElementById('expense_data').value ="";
        document.getElementById('expense_data').focus();
        checkThisMonthDiv(data);
        $('#add_button').removeAttr('disabled')
        notify('Expense saved!' );
        $('progress_image').hide(1);
      },
      error:function(jj){
         $('#add_button').removeAttr('disabled')
        document.getElementById('expense_data').focus();
        $('progress_image').hide(1);
        notify(' failed to update category.' );
      },
      dataType: "json"

    });
  }
}
function checkThisMonthDiv(data){
  if(data.this_month == true){
      if($.find('#day_expense_div_'+data.dt)[0]){
         var str =  addExpenseDiv(data.id,data.desc,data.amount,data.dt,data.color);
         addExpenseDataOnly(data.dt,str);
      }else{
         addThisMonthDateDiv(data);
      }
        refreshTotal(data.total_date,data.total);
  }else{

  }
}
function addThisMonthDateDiv(data){
  
    var htmlstr = '<br>';
    htmlstr += '<div id="day_expense_div_'+data.dt+'">';
    htmlstr += ' <p style="font-size:17px;padding:6px;font-weight:bold;">'+data.disp_date+'<hr><br>';
    htmlstr += '<div id="date_'+data.dt+'">';
    htmlstr +=  addExpenseDiv(data.id,data.desc,data.amount,data.dt,data.color);
    htmlstr += '</div>';
    htmlstr += '<div style="width:90%;">';
    htmlstr += '<div style="float:left"></div>';
    htmlstr += '<div style="float:right"> Total : <span id="total_'+data.total_date+'">'+data.total+'</span></div>';
    htmlstr += '<div id="spacer"></div>';
    htmlstr += '</div>';
   
    $('#month_expenses_data').prepend(htmlstr);
      addDraggableProperty();
}
function uploadDialogBox(){

   $("#upload_file_dialog").dialog('open');

  
}

function uploadFile(){

 /* new AjaxUpload('button4', {
        action: 'do-nothing.htm',
        onSubmit : function(file , ext){
              $('#button4').text('Uploading ' + file);
              this.disable(); 
        },
        onComplete : function(file){
              $('#button4').text('Uploaded ' + file);       
        }   
        }); */
}
