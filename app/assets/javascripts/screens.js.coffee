prepare_failure_buttons = ->
  $('#break-link').click (e) ->
    e.preventDefault()
    $('#failed-buttons').hide()
    $('#break-form').show()
  
  $('#bad-prep-link').click (e) ->
    e.preventDefault()
    $('#failed-buttons').hide()
    $('#bad-prep-form').show()
  
  $('.cancel-failure').click (e) ->
    $('#failed-buttons').show()
    e.preventDefault()
    $('#bad-prep-form').hide()
    $('#break-form').hide()

prepare_screen_id_input = ->
  if $('#screen-id').size() > 0
    $('#screen-id').val ''
    $('#screen-id').focus()

$ ->
  $('#contentModal').on 'hidden.bs.modal', ->
    prepare_screen_id_input()
    return
  $('#screen-id').click ->
    $(this).val ''
    return
  prepare_failure_buttons()
  prepare_screen_id_input()

  $(".js-screen-multiple-select").select2(
       width: "100%"
  )

  $(".js-screen-state-select").select2(
       width: "100%"
  )


    

  $("#screen-filters").submit (event) -> 
    event.preventDefault()
    attrs = {}
    $(this).find('select').each (o) ->
      unless $(this).val() == null
        attrs[$(this).attr('id')] = $(this).val()
    
    $('#screen-status-table tr.screen-row').each( ->
      $(this).show()
      row = $(this)
      $.each( attrs, (key, vals) ->
        if $.inArray(row.data(key), vals) == -1
          row.hide()
      )
    )

  $('.table-sortable').tablesorter()
  
